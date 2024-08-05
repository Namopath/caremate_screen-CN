import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:camera/camera.dart';
import '../configs/configurations.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:caremate_screen/bluetooth/bluetooth_page.dart';
import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class ControlPage extends StatefulWidget{
  ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  late int remoteUid;
  late RtcEngine engine;
  late bool userJoined;
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool cam_isInit = false;
  BleController bleController = Get.find<BleController>();
  String stopCall = "CTR";

  // CollectionReference cam = FirebaseFirestore.instance.collection('cam');


  void initState(){
    super.initState();
    initAgora();
    ListenBLE();
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
                    if(utf8.decode(data) == "CTR"){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
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


  void initAgora() async{
    // List<CameraDescription> cameras = await availableCameras();
    // String camId = cameras[1].getDeviceId();
    if(await Permission.camera.request().isGranted){
      engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: appid,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
      await engine.enableVideo();
      await engine.enableLocalVideo(true);
      await engine.disableAudio();
      await engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
      engine.registerEventHandler(
          RtcEngineEventHandler(
            onJoinChannelSuccess: (RtcConnection connection, int elapsed){
              print('User ${connection.localUid} joined');
              setState(() {
                userJoined = true;
                print('User joined channel successfully');
              });
            },
            onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
              print('Remote user $remoteUid joined');
            },
          )
      );
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      // await engine.enableAudio();

      await engine.joinChannel(
          token: tkn,
          channelId: chan,
          uid: 5141,
          options: const ChannelMediaOptions(
          )
      );

      await engine.startPreview();



      // await engine.muteLocalAudioStream(true);

      // await engine.startLocalVideo(ChannelMediaOptions(videoCompositingMode: VideoCompositingMode.RENDER_MODE_HIDDEN));
    } else{
      print('Cam permission error');
    }
  }


  void initCam() async{
    cameras = await availableCameras();
    await controller.initialize();

    // await engine.startLocalVideoTranscoder();
    setState(() {
      cam_isInit = true;
    });
  }

  void disposeAgora() async{
    await engine.leaveChannel();
    await engine.release();
  }

  void dispose(){
    disposeAgora();

    super.dispose();
  }


  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        Navigator.pop(context);
      },
      child: Container(
        width: 800.w,
        height: 360.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/CMF_img.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}