import 'dart:io';
import 'package:get/get.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:caremate_screen/AIConfig.dart';
import 'package:caremate_screen/games/Games_pages.dart';
import 'package:caremate_screen/configs/configurations.dart';
import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;

  late CameraController cameraController;
  bool isCameraInitialized = false;
  bool canProcess = true;
  bool isBusy = false;
  final PoseDetector poseDetector = PoseDetector(options: PoseDetectorOptions());
  int width = 0;
  int height = 0;
  double Lshoulder = 0;
   double prevLshoulderY = 0;
   double prevRshoulderY = 0;
   double prevLhipY = 0;
   double prevRhipY = 0;
   int timeNow = DateTime.now().millisecond;
   int prevTime = 0;
   int timeDiff = 0;
  double Ldiff = 0;
  double Rdiff = 0;
  double LshoulderY = 0;
  double RshoulderY = 0;
  double LhipY = 0;
  double RhipY = 0;
  double Velocity = 0;
  double hipThresh = 0.5;
  double vThresh = -1;
  double angleThresh = 45;
  double avgHipHeight =0.0;
  double totalHipVal = 0.0;
  bool hasShoulder = false;
  bool hasHip = false;
  OverlayEntry? entry;
  Timer? timer;

  bool imageSaved = false;

  List desiredLandmarks = [
  PoseLandmarkType.leftShoulder,
  PoseLandmarkType.leftHip
  ];

  List<double> prevHipData = [];
  final AIStatusController AI_Status = Get.find<AIStatusController>();
  bool isThresh = false;

  void initState(){
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
    );
    isCameraInitialized = true;
    cameraController?.initialize().then((_){
      if (!mounted){
        return;
      }
      if(AI_Status.isOn.value){
        cameraController.startImageStream(processImg);
      } else{
        print("AI is off");
      }
      setState(() {

      });
    });
  }


  Future<void> poseModel(InputImage inputImage) async{
    if(!canProcess) return;
    if(isBusy) return;
    isBusy = true;
    // final desiredLandmarks = [
    //   PoseLandmarkType.leftShoulder,
    //   PoseLandmarkType.rightShoulder,
    //   PoseLandmarkType.leftKnee,
    //   PoseLandmarkType.rightKnee,
    // ];
    // final poses = await poseDetector.processImage(inputImage);
    try {
      final poses = await poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        // Get the first pose (assuming single person detection)
        final pose = poses.first;


        // Loop through all landmarks and print their coordinates
        for (final pose in poses) {
          for (final entry in pose.landmarks.entries){
            final landmarkType = entry.key;
            final landmark = entry.value;
            final screenX = landmark.x;
            final screenY = landmark.y;
            timeNow = DateTime.now().millisecond;
            timeDiff  = timeNow - prevTime;
            if(landmarkType == PoseLandmarkType.leftShoulder){
              LshoulderY = screenY;
              hasShoulder = true;
              print('Left shoulder Y: $LshoulderY');
              // print('Thresh calculations: ${LhipY/avgHipHeight}');
              prevTime = timeNow;

              // if (avgHipHeight == 0.0 && avgHipHeight != null){
              //   // prevHipData.add(avgHipHeight);
              //   avgHipHeight = LhipY;
              //   print("Avg hip height: $avgHipHeight");
              // }
              //
              // if(LhipY < avgHipHeight){
              //   setState(() {
              //     isThresh = true;
              //   });
              // }
            }
            else if(landmarkType == PoseLandmarkType.leftHip){
              LhipY = screenY;
              hasHip = true;
              print('Left hip Y: $LhipY');
            }

            if(hasHip && hasShoulder){
              if((LshoulderY - LhipY).abs() != 0){
                Ldiff = (LshoulderY - LhipY).abs();
                print("Difference: $Ldiff");
              }
              if(Ldiff < 10){
                canProcess = false;
                // ShowSetEvent1();
                showAlertDialog();
                setState(() {

                });
                hasHip = false;
                hasShoulder = false;
                avgHipHeight = 0.0;
              }
            }
          }

        }
      } else {
        print('No pose detected in the image.');
      }
    } catch (error) {
      print('Error processing pose: $error');
    } finally {
      isBusy = false;
    }
  }

  Future processImg(CameraImage image) async{
    var cameras = await availableCameras();
    final camera = cameras[1];
    width = image.width.toInt();
    height = image.height.toInt();
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes){
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();
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

    // if(!imageSaved && bytes != null){
    //   saveImage(bytes);
    //   setState(() {
    //     imageSaved = true;
    //   });
    // }

    poseModel(inputImage);

  }

  void showAlertDialog(){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text("We've detected a fall!",
          style: TextStyle(
              fontFamily: "Montserrat_bold",
              fontSize: 14.sp,
              color: Colors.red
          ),
        ),
        content: Text("If you are okay, please press the button below to dismiss this alert."),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop(); // Close the dialog
            timer?.cancel();
            // canProcess = true;
          }, child: Text("I'm Okay")),
        ],
      );
    });
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

            Center(
              child: _controller.value.isInitialized
                  ? Container(
                width: 800.w,
                    height: 360.h,
                    // aspectRatio: _controller.value.aspectRatio,

                  child: VideoPlayer(_controller),
                            )
                  : CircularProgressIndicator(), // Show loading indicator while video is initializing
            ),
          ],
        ),
      ),
    );
  }
}