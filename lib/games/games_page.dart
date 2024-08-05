import 'package:caremate_screen/pages/home_screen.dart';
import 'package:caremate_screen/games/pose_game.dart';
import 'package:caremate_screen/games/pose_game_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'rock_paper_scissor_page.dart';
import 'balls_game.dart';
import 'mighty_grip.dart';

class Games_menu1 extends StatefulWidget{
  Games_menu1({super.key});

  @override
  State<Games_menu1> createState() => _Games_menuState1();
}

class _Games_menuState1 extends State<Games_menu1> {


  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/screen_bg.png'),
          fit: BoxFit.cover
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding:  EdgeInsets.fromLTRB(55.w,55.h,0,0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => RPS_game()),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.w),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: Text('Rock,Paper,Scissors',
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
                                    height: 30.h,
                                    child: Text('Battle Caremate in a classic game!',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat_semibold',
                                          fontSize: 12.sp
                                      ),
                                      textAlign: TextAlign.left,
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
                                  Icons.back_hand,
                                size: 90.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.fromLTRB(40.w,55.h,0,0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => MightyGrip()),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: Text('Mighty Grip',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat_bold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0,3.h,0,0),
                                  child: Container(
                                    width: 190.w,
                                    height: 30.h,
                                    child: Text("Squeeze Caremate hands for muscle training",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat_semibold',
                                          fontSize: 12.sp
                                      ),
                                      textAlign: TextAlign.left,
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
                                Icons.handshake,
                                size: 90.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding:  EdgeInsets.fromLTRB(55.w,30.h,0,0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => PoseMenu()),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: Text('Posture Perfect',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat_bold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0,3.h,0,0),
                                  child: Container(
                                    width: 190.w,
                                    height: 30.h,
                                    child: Text("Mimic Caremate's movements for better posture",
                                      style: TextStyle(
                                          fontFamily: 'Montserrat_semibold',
                                          fontSize: 12.sp
                                      ),
                                      textAlign: TextAlign.left,
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
                Padding(
                  padding:  EdgeInsets.fromLTRB(40.w,30.h,0,0),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => ColorGame()),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: Text('Color Catcher Challenge',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat_bold',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0,3.h,0,0),
                                  child: Container(
                                    width: 190.w,
                                    height: 30.h,
                                    child: Text('Get some colorful objects and show them to Caremate',
                                      style: TextStyle(
                                          fontFamily: 'Montserrat_semibold',
                                          fontSize: 12.sp
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: Container(
                              width: 70.w,
                              height: 70.h,
                              child: Icon(
                                Icons.color_lens,
                                size: 70.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: IconButton(onPressed: (){
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
                icon: Icon(Icons.home),
              ),
            ),
          ],
        ),
      ),
    );
  }
}