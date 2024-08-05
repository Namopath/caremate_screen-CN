import 'package:caremate_screen/games/Games_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'games_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class SmileDetection extends StatefulWidget{
  SmileDetection({super.key});

  @override
  State<SmileDetection> createState() => _SmileDetectionState();
}

class _SmileDetectionState extends State<SmileDetection> {
  int score = 0;
  late CameraController cameraController;
  bool isCameraInitialized = false;
  bool canProcess = true;
  bool isBusy = false;
  // final options = ;
  final FaceDetector faceDetector = FaceDetector(options: FaceDetectorOptions(enableClassification: true,enableTracking: true, enableLandmarks: true));
  int width = 0;
  int height = 0;

  void initState(){
    super.initState();
    startLiveFeed();
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

    faceModel(inputImage);
  }

  Future<void> faceModel(InputImage input) async {
    if(!canProcess) return;
    if(isBusy) return;
    isBusy = true;
    final faces = await faceDetector.processImage(input);

    if(faces.isNotEmpty){
      print("Face detected");
      // final face = faces.first();

      try{
        for (Face face in faces){
          final Rect boundingBox = face.boundingBox;
          if (face.smilingProbability != null) {
            final double? smileProb = face.smilingProbability;
            print("Smile probability: $smileProb");
            if(smileProb! >= 0.7){
              setState(() {
                score += 1;
              });
            }

          } else{
            print("No smile detected");
          }
        }
      }catch(e){
        print("Error: $e");
      } finally{
        isBusy = false;
      }
    } else{
      print("No face detected");
    }
    isBusy = false;

  }

  @override
  dispose(){
    cameraController.stopImageStream();
    faceDetector.close();
    cameraController.dispose();
    super.dispose();
  }


  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        print('Score: $score');
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => Games_menu()),
        );
      },
      child: Scaffold(
        backgroundColor: HexColor("#D7E5FF"),
        body: Stack(
          children: [
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
                      "Smile for the\ncamera to earn points!",
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