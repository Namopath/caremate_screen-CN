import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../pages/home_screen.dart';
import 'smile_detection.dart';


class Games_menu2 extends StatefulWidget{
  Games_menu2({super.key});

  @override
  State<Games_menu2> createState() => _Games_menu2State();
}

class _Games_menu2State extends State<Games_menu2> {
  @override
  Widget build(BuildContext context){
    Timer? timer;
    OverlayEntry? entry;
    String timeLeft = "20";
    int TimeLeft = 20;
    Timer? displayTime;

    // fallTimer(){
    //   displayTime = Timer(Duration(seconds: 1), (){
    //     setState(() {
    //       timeLeft = (TimeLeft - 1).toString();
    //     });
    //   });
    //   timer = Timer(Duration(seconds: 20), (){
    //     entry!.remove();
    //     Navigator.pushReplacement(context,
    //       MaterialPageRoute(builder: (context) => HomePage()),
    //     );
    //   });
    // }

    dispose(){
      super.dispose();
    }

    // Widget SetEvent1() => Material(
    //   color: Colors.black.withOpacity(0.25),
    //   child: Center(
    //     child: Container(
    //         decoration: BoxDecoration(
    //             color: Colors.white,
    //             borderRadius: BorderRadius.circular(20.r),
    //             border: Border.all(
    //                 width: 2,
    //                 color: Colors.black
    //             )
    //         ),
    //         width: 200.w,
    //         height: 300.h,
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Padding(
    //               padding: EdgeInsets.only(top: 20.h),
    //               child: Text("We've detected a fall!",
    //                 style: TextStyle(
    //                     fontFamily: "Montserrat_bold",
    //                     fontSize: 14.sp,
    //                     color: Colors.red
    //                 ),
    //               ),
    //             ),
    //             Padding(
    //               padding: EdgeInsets.fromLTRB(10.w,20.h,10.w,0),
    //               child: Text("If you are okay, please press the button down below to dismiss this pop up",
    //                 style: TextStyle(
    //                   fontFamily: "Montserrat_bold",
    //                   fontSize: 14.sp,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //             ),
    //             GestureDetector(
    //               onTap: (){
    //                 timer?.cancel();
    //                 entry!.remove();
    //               },
    //               child: Padding(
    //                 padding: EdgeInsets.only(top: 30.h),
    //                 child: Container(
    //                   width: 150.w,
    //                   height: 40.h,
    //                   decoration: BoxDecoration(
    //                     color: Colors.lightBlue,
    //                     borderRadius: BorderRadius.circular(12.r),
    //                   ),
    //                   child: Center(
    //                     child: Text("I'm Okay",
    //                       style: TextStyle(
    //                         fontFamily: "Montserrat_semibold",
    //                         fontSize: 14.sp,
    //                         color: Colors.white,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //             // Padding(
    //             //   padding: EdgeInsets.only(top: 20.h),
    //             //   child: Text("$timeLeft",
    //             //   style: TextStyle(
    //             //     fontFamily: "Montserrat_semibold",
    //             //     fontSize: 14.sp
    //             //   ),
    //             //   ),
    //             // ),
    //           ],
    //         )
    //     ),
    //   ),
    // );
    //
    // void ShowSetEvent1(){
    //   fallTimer();
    //   final overlay = Overlay.of(context);
    //
    //   entry = OverlayEntry(builder: (context) =>
    //       SetEvent1()
    //   );
    //   overlay.insert(entry!);
    // }


    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  'assets/screen_bg.png'
              ),
              fit: BoxFit.cover
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding:  EdgeInsets.fromLTRB(55.w,55.h,0,0),
          child: GestureDetector(
            onTap: (){
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => SmileDetection()),
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
                          child: Text('Smile!',
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
                            child: Text("Smile for the camera to earn points!",
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
                        Icons.face,
                        size: 90.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
    );
  }
}