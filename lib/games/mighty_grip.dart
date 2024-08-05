import 'dart:convert';
import 'package:caremate_screen/bluetooth/bluetooth_page.dart';
import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart';
import 'Games_pages.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';


class MightyGrip extends StatefulWidget{
  MightyGrip({super.key});

  @override
  State<MightyGrip> createState() => _MightyGripState();
}

class _MightyGripState extends State<MightyGrip> {
  bool Lpressed = false;
  bool Rpressed = false;
  String cmd = "";
  int points = 0;
  final bleController = Get.find<BleController>();
  DateTime today = DateTime.now();
  OverlayEntry? entry;
  String mode = "MG";
  String modeExit = "O";

  void initState(){
    super.initState();
    // sendMode();
    listen();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkConnect();
    });

  }

  void checkConnect(){
    if(bleController.connectedDevice != null && BluetoothDeviceState.connected == true){
      ShowConnected();
    } else if (BluetoothDeviceState.disconnected == true){
      ShowNotConnect();
    }
  }

  // void sendGameData(){
  //   var db = FirebaseFirestore.instance.collection("games").doc("Squeeze game");
  //   String todayFormat = DateFormat("dd-MM-yyyy").format(today);
  //   db.set({
  //     "$todayFormat" : "$points"
  //   });
  // }

  void sendMode() async{
    if(bleController.connectedDevice != null){
      if (bleController.deviceServices != null) {
        for (BluetoothService service in bleController
            .deviceServices!) {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            if (characteristic.properties.write ) {
              try {
                await characteristic.write(mode.codeUnits);
                print("Mode value has been written");
                // ShowConnected();
              } catch(e){
                print("Error: $e");
              }
            } else{
              // ShowNotConnect();
              print("No write char");
            }
          }
        }
      }
      print("There is a device connected");
    }else{
      print("No devices detected");
    }
  }

  void listen() async{
    if(bleController.connectedDevice != null){
      if (bleController.deviceServices != null) {
        for (BluetoothService service in bleController
            .deviceServices!) {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            if (characteristic.properties.write ) {
              try {
                await characteristic.write(mode.codeUnits);
                print("Mode value has been written");
              } catch(e){
                print("Error: $e");
              }
            } else{
              print("No write char");
            }
            if (characteristic.properties.notify ) {
              try {
                await characteristic.setNotifyValue(true);
                characteristic.value.listen((data) {
                  print("Received: ${utf8.decode(data)}");
                  if(utf8.decode(data) == 'F-1'){ //Left
                    left();
                    if(mounted){
                      setState(() {
                        points += 1;
                      });
                    }

                    // Future.delayed(Duration(seconds: 2));
                    // Lpressed = false;
                  }
                  if(utf8.decode(data) == 'F-2') { //Right
                    right();
                    if(mounted){
                      setState(() {
                        points += 1;
                      });
                    }

                    // Future.delayed(Duration(seconds: 2));
                    // Lpressed = false;
                  }
                });
              } catch(e){
                print("Error: $e");
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

  left() async {
    setState(() {
      Lpressed = true;
    });

    await Future.delayed(Duration(seconds: 2));
    if(mounted){
      setState(() {
        Lpressed = false;
      });
    }

  }

  right() async{
    setState(() {
      Rpressed = true;
    });

    await Future.delayed(Duration(seconds: 2));
    if(mounted){
      setState(() {
        Rpressed = false;
      });
    }

  }

  void sendOver()async{
    if(bleController.connectedDevice != null){
      if (bleController.deviceServices != null) {
        for (BluetoothService service in bleController
            .deviceServices!) {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            if (characteristic.properties.write ) {
              try {
                await characteristic.write(modeExit.codeUnits);
                print("Mode exit value has been written");
              } catch(e){
                print("Error: $e");
              }
            }
          }
        }
      }
      print("There is a device connected");
    }else{
      print("No devices detected");
    }
  }

  void dispose(){
    sendOver();
    // sendGameData();
    // bleController.dispose();
    super.dispose();
  }

  void ShowNotConnect(){
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
        NotConnect()
    );
    overlay.insert(entry!);
  }

  Widget NotConnect() => Material(
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('No device connected'),
              FloatingActionButton(onPressed: (){
                entry!.remove();
              },
                child: Text("Dismiss "),
              )
            ],
          )
      ),
    ),
  );

  void ShowConnected(){
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
       Connected()
    );
    overlay.insert(entry!);
  }

  Widget Connected() => Material(
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Device is connected'),
              FloatingActionButton(onPressed: (){
                entry!.remove();
              },
                child: Text("Dismiss "),
              )
            ],
          )
      ),
    ),
  );

  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image:  AssetImage(
                  'assets/screen_bg.png'
              ),
              fit: BoxFit.cover
          )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w,20.h,0,0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // IconButton(
                  //   onPressed: (){
                  //     Navigator.pushReplacement(context,
                  //       MaterialPageRoute(builder: (context) => Games_menu()),
                  //     );
                  //   },
                  //   icon: Icon(
                  //     Icons.arrow_back,
                  //     color: Colors.white,
                  //     size: 40.w,
                  //   ),
                  // ),
                  Text('Score: $points',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontFamily: 'Montserrat_bold'
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.h),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  Padding(
                    padding:  EdgeInsets.only(left: 200.w),
                    child: AvatarGlow(
                      // glowBorderRadius: BorderRadius.circular(30.r),
                      animate: Lpressed,
                      glowColor: HexColor('#F2935C'),
                      duration: Duration(
                        milliseconds: 2000
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HexColor('#F2935C'),

                        ),
                        width: 150.w,
                        height: 150.h,
                        child: Center(
                          child: Text('L',
                          style: TextStyle(
                            fontFamily: 'Montserrat_bold',
                            fontWeight: FontWeight.bold,
                            fontSize: 60.sp,
                            color: Colors.white
                          ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left: 125.w),
                    child: AvatarGlow(
                      // glowBorderRadius: BorderRadius.circular(30.r),
                      animate: Rpressed,
                      glowColor: HexColor('#367CFE'),
                      duration: Duration(
                        milliseconds: 2000,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HexColor('#367CFE'),

                        ),
                        width: 150.w,
                        height: 150.h,
                        child: Center(
                          child: Text('R',
                            style: TextStyle(
                                fontFamily: 'Montserrat_bold',
                                fontWeight: FontWeight.bold,
                                fontSize: 60.sp,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: IconButton(onPressed: (){
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => Games_menu()),
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

