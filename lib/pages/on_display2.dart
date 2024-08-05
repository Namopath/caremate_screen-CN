import 'package:agora_uikit/agora_uikit.dart';
import 'package:caremate_screen/games/Games_pages.dart';
import 'package:caremate_screen/configs/configurations.dart';
import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image/image.dart';

class VideoPage2 extends StatefulWidget {
  @override
  _VideoPageState2 createState() => _VideoPageState2();
}

class _VideoPageState2 extends State<VideoPage2> {
  late VideoPlayerController _controller;

  late CameraController cameraController;
  bool isCameraInitialized = false;
  bool canProcess = true;
  bool isBusy = false;
  int width = 0;
  int height = 0;
  OverlayEntry? entry;
  Timer? timer;

  final ObjectDetector objectDetector = ObjectDetector(options: ObjectDetectorOptions(mode: DetectionMode.stream, classifyObjects: true, multipleObjects: true));
  late WebSocketChannel channel;


  void initState() {
    initTf();
    initSocket();
    startLiveFeed();
    super.initState();
    _controller = VideoPlayerController.asset('assets/CMF.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
        // Start playing the video
        _controller.play();
      });

    // final options = ObjectDetectorOptions(mode: mode, classifyObjects: true, multipleObjects: true);
    // final objectDetector = ObjectDetector(options: options);
  }

   initSocket() async {
    String serverIp = "192.168.1.47";
     channel = await WebSocketChannel.connect(Uri.parse('ws://$serverIp:80'));
     print("Connected to channel");
    try{
      await channel.ready;
      channel.sink.add("Client has been connected");
      print("Init message sent");
    } catch(e){
      print("Error sending init msg: $e");
    }
    channel.stream.listen((message) {
      channel.sink.add('received!');
      channel.sink.close(status.goingAway);
    }, onError: (error){
      print("Socket error: $error");
    }
    );


  }

  fallTimer(){
    timer = Timer(Duration(seconds: 20), (){
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });
  }

  startLiveFeed() async{
    var cameras = await availableCameras();
    final camera = cameras[1];
    cameraController = await CameraController(camera, ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    isCameraInitialized = true;
    cameraController?.initialize().then((_){
      if (!mounted){
        return;
      }
      cameraController.startImageStream(processImg);
      setState(() {

      });
    });
  }



  Future processImg(CameraImage image) async{
    var cameras = await availableCameras();
    final camera = cameras[1];
    width = image.width.toInt();
    height = image.height.toInt();
    final WriteBuffer allBytes = WriteBuffer();
    // for (final Plane plane in image.planes){
    //   allBytes.putUint8List(plane.bytes);
    // }
    List<Uint8List> bytesList = image.planes.map((Plane plane) => plane.bytes).toList();
    final bytes = allBytes.done().buffer.asUint8List();
    // print(bytes);
    // channel.sink.add(bytes);
    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());


    final imageRotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if(imageRotation == null){
      print('Rotation is null');
      return;
    }
    final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null){
      print('Format is null');
      return;
    }

    final inputImageData =
    InputImageMetadata(size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes[0].bytesPerRow);

    final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData);

    // objModel(bytesList, width, height);
  }

  void initTf() async {
    // await Tflite.close();
    try{
      String? res = await Tflite.loadModel(model: "assets/pose_detection.tflite",
        isAsset: true,
        numThreads: 1,
      );
      if (res == 'success') {
        print("Model loaded successfully");
      } else {
        print("Failed to load model: $res");
      }
    } catch(e){
      print("Error loading model: $e");
    }
    // setState(() {
    //   canProcess = true;
    // });
    print("Model loaded successfully");
  }

  void objModel(List<Uint8List> bytearray, int width, int height) async{
    if(!canProcess) return;
    if(isBusy) return;
    isBusy = true;
    // canProcess = false;

    try{
      final objectModel = await Tflite.runModelOnFrame(bytesList: bytearray,
      imageWidth: width, imageHeight: height, imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.6,
        asynch: true,
      );
      if (objectModel != null){
        print("Result: $objectModel");
      } else{
        print("Obj model is null");
      }
    } catch(e){
      print("Model error: $e");
    } finally{
      isBusy = false;
      // canProcess = true;
    }

  }

  void ShowSetEvent1(){
    fallTimer();
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
        SetEvent1()
    );
    overlay.insert(entry!);
  }

  Widget SetEvent1() => Material(
    color: Colors.black.withOpacity(0.25),
    child: Center(
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  width: 2,
                  color: Colors.black
              )
          ),
          width: 200.w,
          height: 300.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Text("We've detected a fall!",
                  style: TextStyle(
                      fontFamily: "Montserrat_bold",
                      fontSize: 14.sp,
                      color: Colors.red
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10.w,20.h,10.w,0),
                child: Text("If you are okay, please press the button down below to dismiss this pop up",
                  style: TextStyle(
                    fontFamily: "Montserrat_bold",
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: (){
                  timer?.cancel();
                  entry!.remove();
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 30.h),
                  child: Container(
                    width: 150.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text("I'm Okay",
                        style: TextStyle(
                          fontFamily: "Montserrat_semibold",
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
      ),
    ),
  );

  @override
  void dispose(){
    channel.sink.close;
    super.dispose();
    cameraController.dispose();
    _controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        // Navigator.pop(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            isCameraInitialized
                ? CameraPreview(cameraController)
                : CircularProgressIndicator(),

            // Center(
            //   child: _controller.value.isInitialized
            //       ? Container(
            //     width: 800.w,
            //     height: 360.h,
            //     // aspectRatio: _controller.value.aspectRatio,
            //
            //     child: VideoPlayer(_controller),
            //   )
            //       : CircularProgressIndicator(), // Show loading indicator while video is initializing
            // ),
          ],
        ),
      ),
    );
  }
}