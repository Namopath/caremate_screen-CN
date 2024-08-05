import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:video_player/video_player.dart';
import 'main.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Kean extends StatefulWidget{
  Kean({super.key});

  @override
  State<Kean> createState() => _KeanState();
}

class _KeanState extends State<Kean> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/keanee.mp4')
      ..initialize().then((_) {
        _controller.setLooping(false);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
        // Start playing the video
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // Navigate back to the home page when the video ends
        Get.off(HomePage());
      }
    });

  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }



  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        width: 800.w,
        height: 360.h,
        child: ClipRect(child: VideoPlayer(_controller)),
      )
    );
  }
}