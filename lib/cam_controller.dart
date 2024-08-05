import 'package:agora_uikit/agora_uikit.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:semaphore/semaphore.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

class CamController extends GetxController {
  final poseDetector = PoseDetector(options: PoseDetectorOptions(
      model: PoseDetectionModel.accurate,
      mode: PoseDetectionMode.stream
  ));

  void onInit() {
    super.onInit();
    initCam();

  }

  late List<CameraDescription> cameras;
  late CameraImage cameraImage;

  var cameraCount = 0;
  late CameraController controller;
  var cam_initialized = false.obs;

  final _frameSemaphore = LocalSemaphore(1);
  late InputImage img;

  initCam() async {

    if(await Permission.camera.request().isGranted){
      cameras = await availableCameras();
      controller = CameraController(cameras[1], ResolutionPreset.high,
          enableAudio: false,
          // imageFormatGroup: ImageFormatGroup.nv21
      );
      await controller.initialize().then((value) {
        cam_initialized(true);
        controller.startImageStream((image) {
          final width = image.width;
          final height = image.height;
          processImage(image as InputImage);
        });
      });

    }else{
      print('No perm');
    }
  }



  // InputImage _convertYUV420(CameraImage image) {
  //   var img = imglib.Image(image.width, image.height); // Create Image buffer
  //
  //   Plane plane = image.planes[0];
  //   const int shift = (0xFF << 24);
  //
  //   // Fill image buffer with plane[0] from YUV420_888
  //   for (int x = 0; x < image.width; x++) {
  //     for (int planeOffset = 0;
  //     planeOffset < image.height * image.width;
  //     planeOffset += image.width) {
  //       final pixelColor = plane.bytes[planeOffset + x];
  //       // color: 0x FF  FF  FF  FF
  //       //           A   B   G   R
  //       // Calculate pixel color
  //       var newVal = shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;
  //
  //       img.data[planeOffset + x] = newVal;
  //     }
  //   }
  //   img = InputImage.fromBytes(bytes: bytes, metadata: metadata)
  // }

  Future<void> processImage(InputImage image) async{
    final poses = await poseDetector.processImage(image);
    for (final pose in poses) {
      final landmarks = pose.landmarks;
      landmarks.forEach((landmarkType, landmark) {
        if (landmarkType == PoseLandmarkType.leftShoulder) {
          final X = landmark.x;
          final Y = landmark.y;
         print('Coordinates x:$X y: $Y');
        }
      });
      }
}




  // Future<void> pose_est(CameraImage image) async {
  //   // Acquire semaphore before processing
  //   await _frameSemaphore.acquire();
  //
  //   var detector;
  //   try {
  //     detector = await tflite.Tflite.runModelOnFrame(
  //         bytesList: image.planes.map(
  //                 (e){
  //                   return e.bytes;
  //                 }
  //             ).toList(),
  //               asynch: true,
  //               imageHeight: 172,
  //               imageWidth: 172,
  //               imageMean: 172,
  //               imageStd: 172,
  //               numResults: 1,
  //     );
  //   } catch (error) {
  //     print('Error running model: $error');
  //   } finally {
  //     // Release semaphore after processing
  //     _frameSemaphore.release();
  //   }
  //
  //   if (detector != null) {
  //     print(detector);
  //   } else {
  //     print('Detector is null...');
  //     print('Plane 0 length: ${image.planes[0].bytes.length}');
  //     print('Plane 1 length: ${image.planes[1].bytes.length}');
  //     print('Plane 2 length: ${image.planes[2].bytes.length}');
  //
  //   }
  // }

}
