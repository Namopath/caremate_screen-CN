import 'package:camera/camera.dart';
import 'package:caremate_screen/pages/control_page.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../models.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:caremate_screen/pages/on_display_screen.dart';
import 'dart:async';
import 'package:caremate_screen/games/Games_pages.dart';
import '../bluetooth/bluetooth_page.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'video_call.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // List<dynamic> _recognitions = [];
  // int _imageHeight = 0;
  // int _imageWidth = 0;
  // String _model = "";
  late List<CameraDescription> cameras;
  Timer? timer;
  String txt = "";
  FlutterTts tts = FlutterTts();
  String cleanedTxt = "";
  OverlayEntry? entry;
  // CollectionReference cam = FirebaseFirestore.instance.collection('cam');
  var bleController = Get.find<BleController>();
  late FlutterTts flutterTts = FlutterTts();
  String handMsg = "Your hand command message has been sent";

  @override
  void initState() {
    super.initState();
    print("HOME PAGE INIT");
    ListenBLE();
    WidgetsBinding.instance.addPostFrameCallback((_) => resetTime());

  }



  void resetTime(){
    timer?.cancel();
    timer = Timer(Duration(seconds: 10), (){
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => VideoPage()),
      );
    });
}

void dispose(){
    timer?.cancel();
    super.dispose();
}

  void ListenBLE() async{
    if(bleController.connectedDevice != null){
      if (bleController.deviceServices != null) {
        for (BluetoothService service in bleController
            .deviceServices!) {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            if (characteristic.properties.notify ) {
              if(!characteristic.isNotifying){
                try {
                  await characteristic.setNotifyValue(true);
                  characteristic.value.listen((data) async {
                    print("Main Received: ${utf8.decode(data)}");
                    if(utf8.decode(data) == "H1" || utf8.decode(data) == "H2" || utf8.decode(data) == "H3") {
                      speakHandMsg();
                    }
                    if(utf8.decode(data) == "VC"){
                      timer?.cancel();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => VidCall()));
                    }
                    if(utf8.decode(data) == "CT"){
                      timer?.cancel();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ControlPage()));
                    }
                  });
                } catch(e){
                  print("Error: $e");
                }
              }
              // else if(characteristic.properties.read) {
              //   try{
              //   var data = characteristic.read();
              //   print("Read: $data");
              // } catch(e){
              //     print("Error: $e");
              //   }
              // }
            }
          }
        }
      }
      print("There is a device connected");
    }else{
      print("No devices detected");
    }
  }

  void speakHandMsg() async {
    var voice = await flutterTts.setVoice({"name" : "en-us-x-sfg#female_1-local"});
    await flutterTts.speak(handMsg);
  }

 void cleanText(String text){
    final symbols = RegExp(r'[$*.{}\[\]?\"!@#%&/\\,><:;_~`+=]');
    var cleaned = text.replaceAll(symbols, " ");
    cleanedTxt = cleaned.toString();
    print(cleanedTxt);
 }

 makeCall() async{
    var phoneNumber = "0956264860";
    var url = Uri.parse("tel:$phoneNumber");
    if (await canLaunchUrl((url))) {
      await launchUrl(url);
    } else {
      print("Could not launch URL");
    }
 }


  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(800,360),
      minTextAdapt: true,
      builder: (_, child) {
        return GestureDetector(
          onTap: (){
            resetTime();
          },
          child: Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w,20.h,0,0),
                  child: IconButton(onPressed: (){
                    Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Ble_page()),
                    );
                  },
                      icon: Icon(Icons.bluetooth,
                        size: 30.w,
                        color: Colors.white,
                      )
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 50.h),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 200.w),
                        child: GestureDetector(
                          onTap: (){
                            Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Games_menu()),
                            );
                          },
                          child: Container(
                          width: 150.w,
                          height: 150.h,
                          decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HexColor('#367CFE')
                          ),
                          child: Icon(Icons.videogame_asset_rounded,
                          color: Colors.white,
                          size: 50.w,
                                    ),
                                      ),
                                  ),
                            ),
                  Padding(
                     padding:  EdgeInsets.only(left: 125.w),
                      child: GestureDetector(
                        onTap: () async{
                          Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => VidCall()),
                          );
                        },
                        child: Container(
                            width: 150.w,
                            height: 150.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: HexColor('#367CFE')
                            ),
                            child: Icon(Icons.video_call,
                            color: Colors.white,
                            size: 50.w,
                            ),
                            ),
                      ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
        );
      }
    );
  }
}