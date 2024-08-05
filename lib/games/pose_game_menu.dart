import 'package:camera/camera.dart';
import 'package:caremate_screen/cam_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:caremate_screen/games/Games_pages.dart';
import '../bluetooth/bluetooth_page.dart';
import 'pose_game.dart';


class PoseMenu extends StatefulWidget {

  @override
  _PoseMenu createState() => new _PoseMenu();
}

class _PoseMenu extends State<PoseMenu> {
  // List<dynamic> _recognitions = [];
  // int _imageHeight = 0;
  // int _imageWidth = 0;
  // String _model = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/screen_bg.png'),
            fit: BoxFit.cover
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start ,
                children: [
                  IconButton(
                    onPressed: (){
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => Games_menu()),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 40.w,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top:80.h),
                child: Center(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PosturePerfect()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.white,
                      ),
                      width: 325.w,
                      height: 110.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.w),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: Text('Motion game',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat_bold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5.w,3.h,0,0),
                                  child: Container(
                                    width: 190.w,
                                    height: 60.h,
                                    child: Text('Tap to start a live video feed that will detect your actions.',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat_semibold',
                                          fontSize: 12.sp
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Container(
                              width: 90.w,
                              height: 90.h,
                              child: Icon(
                                Icons.fitness_center,
                                size: 80.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}