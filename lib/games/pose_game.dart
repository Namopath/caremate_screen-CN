import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image/image.dart';
import '../pose_painter.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'games_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class PosturePerfect extends StatefulWidget{
  PosturePerfect({super.key});

  @override
  State<PosturePerfect> createState() => _PosturePerfectState();
}

class _PosturePerfectState extends State<PosturePerfect> {
  late VideoPlayerController controller;
  late CameraController cameraController;
  bool isCameraInitialized = false;
  bool canProcess = true;
  bool isBusy = false;
  final PoseDetector poseDetector = PoseDetector(options: PoseDetectorOptions());
  int width = 0;
  int height = 0;
  CustomPaint? customPaint;
  int timeNow = DateTime.now().millisecond;
  int prevTime = 0;
  double Lknee = 0.0;
  double Rknee = 0.0;
  double Lankle = 0.0;
  double Rankle = 0.0;
  double Lhip = 0.0;
  double Ldiff = 0.0;
  double Rdiff = 0.0;
  double prevLknee = 0.0;
  double prevLankle = 0.0;
  double hipDiff = 0.0;
  int timeDiff = 0;
  int score = 0;
  bool kneeChanged = false;
  bool ankleChanged = false;
  bool hipChanged = false;
  double avgKnee = 0.0;
  double thresh = 1.15;
  bool isVid = false;
  String displayImg = '';
  DateTime today = DateTime.now();


  void initState(){
    startLiveFeed();
    super.initState();
    controller = VideoPlayerController.asset('assets/Leg_lifts.mp4')
      ..initialize().then((_) {
        controller.setLooping(true);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
        // Start playing the video
        controller.play();
      });
    Lknee = 0.0;
    Lankle = 0.0;
    Lhip = 0.0;
  }

   playVid() async{
    if (controller != null) {
      await controller!.play();
      // setState(() {
      //   isVid = true;
      //   displayImg = 'assets/placeholder.png';
      // });

      // Remove the listener from here

      await controller!.setLooping(true); // Ensure video doesn't loop
      await controller!.play(); // Start playing the video
      // Update state after video ends
      // Call randomImg after video ends
    }
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
      cameraController.startImageStream(processImg);
      setState(() {

      });
    });
  }


  Future<void> poseModel(InputImage inputImage) async{
    if(!canProcess) return;
    if(isBusy) return;
    isBusy = true;
    final desiredLandmarks = [
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
      PoseLandmarkType.leftHip,
    ];

    try {

      final poses = await poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
      //   // Get the first pose (assuming single person detection)
      //   final pose = poses.first;
      //
      //
      //   // Loop through all landmarks and print their coordinates
        for (final pose in poses) {
          kneeChanged = false;
          ankleChanged = false;
          hipChanged = false;
          for (final entry in pose.landmarks.entries){
            final landmarkType = entry.key;
            final landmark = entry.value;
            final screenX = landmark.x;
            final screenY = landmark.y;
            if(landmarkType == desiredLandmarks[0]){
              // timeNow = DateTime.now().millisecond;
              // timeDiff = timeNow-prevTime;
              if (Lknee != 0.0){
                Lknee = screenY;
              }
              else{
                Lknee = screenY;
                avgKnee = Lknee;
                print('average: $avgKnee');
              }
              print('Left knee: $Lknee, Time diff: $timeDiff');
              kneeChanged = true;
              // prevTime = timeNow;
            }
            // else{
            //   continue;
            // }
           if(landmarkType == desiredLandmarks[1]){
              // timeNow = DateTime.now().millisecond;
              // timeDiff = timeNow-prevTime;
              Rknee = screenY;
              print('Right knee: $Rknee, Time diff: $timeDiff');
            }
            // else{
            //   continue;
            // }
           if(landmarkType == desiredLandmarks[2]){
              // timeNow = DateTime.now().millisecond;
              // timeDiff = timeNow-prevTime;
              Lankle = screenY;
              print('Left ankle: $Lankle, Time diff: $timeDiff');
              ankleChanged = true;

            }
            // else{
            //   continue;
            // }
           if(landmarkType == desiredLandmarks[3]){
              // timeNow = DateTime.now().millisecond;
              // timeDiff = timeNow-prevTime;
              Rankle = screenY;
              print('Right ankle: $Rankle, Time diff: $timeDiff');
            }
            // else{
            //   continue;
            // }
           if(landmarkType == desiredLandmarks[4]){
              Lhip = screenY;
              print('Left hip: $Lhip');
              hipChanged = true;
            }
            // else{

            //   continue;
            // }

            if((Lknee != 0.0 && Lankle != 0.0) && (kneeChanged == true  && ankleChanged == true)){
              // print("Thresh calculations: ${Lankle/avgKnee}");
              Ldiff = Lknee - Lankle;
              hipDiff = Lhip - Lknee;
              print('Thresh calculations: ${Lankle / avgKnee}');
              print('Hip diff: ${hipDiff.abs()}');
              if((Ldiff.abs()) <= 15 && ((hipDiff.abs()) <= 50
              )
                  // && ((Lankle/avgKnee) < 1.15)
              ){
                setState(() {
                  score += 1;
                  print("Score updated");
                });
                break;
              }
              print('Left difference: ${Ldiff.abs()}');
              kneeChanged = false;
              ankleChanged = false;
            }

          }
      //
        }
      //   if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null){
      //     final painter = PosePainter(poses, inputImage.metadata!.size, inputImage.metadata!.rotation);
      //     setState(() {
      //       customPaint = CustomPaint(painter: painter,);
      //     });

        // } else{
        //   print('Size or rotation is null');
        // }

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

    poseModel(inputImage);
  }

  @override
  void dispose(){
    // sendGameData();
    super.dispose();
    cameraController.dispose();
  }

  // void sendGameData(){
  //   var db = FirebaseFirestore.instance.collection("games").doc("Posture game");
  //   String todayFormat = DateFormat("dd-MM-yyyy").format(today);
  //   db.set({
  //     "$todayFormat" : "$score"
  //   });
  // }

  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        print('Score: $score');
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => Games_menu1()),
        );
      },
      child: Scaffold(
        backgroundColor: HexColor("#D7E5FF"),
        body: Stack(
          children: [
            // Padding(
            //   padding:  EdgeInsets.only(right: 20.w),
            //   child: Center(
            //     child:
            //     controller.value.isInitialized
            //         ? Container(
            //       width: 400.w,
            //       height: 250.h,
            //       // aspectRatio: _controller.value.aspectRatio,
            //
            //       child: VideoPlayer(controller),
            //     )
            //         : CircularProgressIndicator(), // Show loading indicator while video is initializing
            //   ),
            // ),
            Container(
              width: 800.w,
              height:  360.h,
              child: isCameraInitialized
                  ? ClipRect(child: CameraPreview(cameraController))
                  : CircularProgressIndicator(),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(600.w,40.h,0,0),
              child: Container(
                width: 200.w,
                height: 100.h,
                decoration: BoxDecoration(
                    color: HexColor('#367CFE'),
                    borderRadius: BorderRadius.circular(12.r)
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text("Score: $score",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Montserrat_bold",
                        fontSize: 14.sp,
                      ),
                      ),
                    ),Text(
                        "The pose detection algorithm will detect movement",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontFamily: "Montserrat_semibold",
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}