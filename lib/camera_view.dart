import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {

  CameraView(
      {Key? key,
        required this.title,
        required this.customPaint,
        this.text,
        required this.onImage,
        this.onScreenModeChanged,
        this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint? customPaint;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function(ScreenMode mode)? onScreenModeChanged;
  final CameraLensDirection initialDirection;

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {

  late CameraController cameraController;

  void initState(){
    super.initState();
    startLiveFeed();
  }

  Future startLiveFeed() async{
    var cameras = await availableCameras();
    final camera = cameras[1];
    cameraController = CameraController(camera, ResolutionPreset.high,
    enableAudio: false,
    );
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

    return inputImage;
  }

  Widget build(BuildContext context){
   return Container(
     width: 800.w,
     height: 360.h,

   );
  }
}