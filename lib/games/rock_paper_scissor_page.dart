import 'dart:math';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'Games_pages.dart';
import '../bluetooth/bluetooth_page.dart';
import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:caremate_screen/bluetooth/bluetooth_page.dart';
import 'package:get/get.dart';

class RPS_game extends StatefulWidget{
  RPS_game({super.key});

  @override
  State<RPS_game> createState() => _RPS_gameState();
}

class _RPS_gameState extends State<RPS_game> {
  final bleController = Get.find<BleController>();
  int cycles = 0;
  VideoPlayerController? controller;
  bool isVid = false;
  String displayImg = 'assets/start-button.png';
  int i = 0;
  String move_arm = 'R-1';
  String stop = 'R-0';
  OverlayEntry? entry;
  bool valueSent = false;
  bool connected = false;
  String mode = 'RP';
  String modeExit = "O";

  @override
  void initState(){
    super.initState();
    controller = VideoPlayerController.asset('assets/rps_withbg_cropped.mp4')
    ..initialize().then((_){
      setState(() {

      });

    });
    sendMode();
  }

  void playVid() async{
    if (controller != null) {
      await controller!.play();
      setState(() {
        isVid = true;
        displayImg = 'assets/placeholder.png';
      });

      // Remove the listener from here

      await controller!.setLooping(false); // Ensure video doesn't loop
      await controller!.play(); // Start playing the video
      await Future.delayed(controller!.value.duration); // Wait for the video to finish
      isVid = false; // Update state after video ends
      randomImg(); // Call randomImg after video ends
    }
  }

  void ShowSetEvent1(){
    final overlay = Overlay.of(context);

    entry = OverlayEntry(builder: (context) =>
        SetEvent1()
    );
    overlay.insert(entry!);
  }

  Widget SetEvent1() => Material(
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
              Text('Failed to send message'),
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

  @override
  void dispose(){
    sendOver();
    super.dispose();
    controller?.dispose();
  }

  void randomImg() async {
    valueSent = false;
    List<String> assets = [
      'assets/rock.png',
      'assets/rock.png',
      'assets/scissor.png',
      'assets/paper.png'
    ];
    final randomImg = assets[Random().nextInt(assets.length)];
    setState(() {
      displayImg = randomImg;

    });
    if(bleController.connectedDevice != null){
      if (bleController.deviceServices != null) {
        for (BluetoothService service in bleController
            .deviceServices!) {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            if (characteristic.properties.write && !valueSent) {
              try {
                await characteristic.write(move_arm.codeUnits);
                await characteristic.write(stop.codeUnits);
                valueSent = true;
                print("Sent");
              } catch (e) {
                ShowSetEvent1();
                print("Failed to write characteristic: $e");
                // Handle the error gracefully
              }
              break;
            }
          }
        }
      }
      print("There is a device connected");
    }else{
      print("No devices detected");
    }
  }


  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        playVid();
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/screen_bg.png"
            ),
            fit: BoxFit.cover
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.fromLTRB(20.w,20.h,0,0),
            child: Column(
              children: [
                Row(
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
                Center(
                  child: Container(
                    width: 200.w,
                    height: 200.h,
                    // color: Colors.white,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(displayImg,
                          width: 200.w,
                            height: 200.h,
                          ),
                        ),
                        isVid? Center(
                          child: Container(
                            width: 600.w,
                            height: 100.h,
                            child: AspectRatio(
                              aspectRatio: 200/200,
                              child: VideoPlayer(
                                  controller!
                              ),
                            ),
                          ),
                        ) : Container(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}