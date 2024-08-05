import 'package:caremate_screen/bluetooth/bluetooth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Games_pages.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ColorGame extends StatefulWidget{
  ColorGame({super.key});

  @override
  State<ColorGame> createState() => _ColorGameState();
}

class _ColorGameState extends State<ColorGame> {
  int red = 0;
  int green = 0;
  int blue = 0;
  DateTime today = DateTime.now();
  OverlayEntry? entry;
  final bleController = Get.find<BleController>();
  String mode = "CC";
  String modeExit = "O";

  @override
  void initState() {
    super.initState();
    // sendMode();
    listen();
    WidgetsBinding.instance.addPostFrameCallback((_){
      checkConnect();
    });
  }

  void checkConnect(){
    if(bleController.connectedDevice != null){
      ShowConnected();
    } else{
      ShowNotConnect();
    }
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
            }
            if (characteristic.properties.notify ) {
              try {
                await characteristic.setNotifyValue(true);
                characteristic.value.listen((data) {
                  print("Received: ${utf8.decode(data)}");
                  if(utf8.decode(data) == 'C-1'){
                    setState(() {
                      red+=1;
                    });
                    // Future.delayed(Duration(seconds: 2));
                    // Lpressed = false;
                  }
                  if(utf8.decode(data) == 'C-2'){
                    setState(() {
                      green+=1;
                    });
                    // Future.delayed(Duration(seconds: 2));
                    // Lpressed = false;
                  }
                  if(utf8.decode(data) == 'C-3'){
                    setState(() {
                      blue+=1;
                    });
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

  void dispose(){
    sendOver();
    super.dispose();
    // sendGameData();
    
  }

  // void sendGameData(){
  //   var db = FirebaseFirestore.instance.collection("games").doc("color_game");
  //   String todayFormat = DateFormat("dd-MM-yyyy").format(today);
  //   db.set({
  //     "$todayFormat" : "${red+green+blue}"
  //   });
  // }

  Widget build(BuildContext context){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
                'assets/screen_bg.png'
            ),
            fit: BoxFit.cover
        ),
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
            ),
            Padding(
              padding:  EdgeInsets.only(top: 15.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  Center(
                    child: Container(
                      width: 200.w,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text("${red.toString()}",
                        style: TextStyle(
                          fontSize: 34.sp,
                          fontFamily: "Montserrat_bold",
                          color: Colors.white
                        ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 200.w,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child:  Center(
                      child: Text("${green.toString()}",
                        style: TextStyle(
                            fontSize: 34.sp,
                            fontFamily: "Montserrat_bold",
                            color: Colors.white
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    width: 200.w,
                    height: 200.h,
                    child:  Center(
                      child: Text("${blue.toString()}",
                        style: TextStyle(
                            fontSize: 34.sp,
                            fontFamily: "Montserrat_bold",
                            color: Colors.white
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
    );
  }
}