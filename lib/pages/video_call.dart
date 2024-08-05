import 'package:caremate_screen/bluetooth/bluetooth_page.dart';
import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../configs/configurations.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert';

class VidCall extends StatefulWidget{
  VidCall({super.key});

  @override
  State<VidCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VidCall> {
  int remoteuid = 0;
  late RtcEngine engine;
  late bool userJoined;
  late List<CameraDescription> cameras;
  late CameraController controller;
  bool cam_isInit = false;
  // CollectionReference cam = FirebaseFirestore.instance.collection('cam');
  BleController bleController = Get.find<BleController>();
  String startCall = "VC";
  String stopCall = "NVC";

  void initState(){
    super.initState();
    sendCall();
    initAgora();
  }

  void sendCall() async{
      // await cam.doc("cam_status").update({'isCall': 'false'});
      if(bleController.connectedDevice != null){
        if (bleController.deviceServices != null) {
          for (BluetoothService service in bleController
              .deviceServices!) {
            for (BluetoothCharacteristic characteristic in service
                .characteristics) {
              if (characteristic.properties.write) {
                if(!characteristic.isNotifying){
                  try {
                    await characteristic.write(startCall.codeUnits);
                    print("Sent");
                    // await characteristic.write("X".codeUnits);
                  } catch (e) {
                    print("Failed to write characteristic: $e");
                  }
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

  void notCall() async{
    // await cam.doc("cam_status").update({'isCall': 'false'});
    if(bleController.connectedDevice != null){
      if (bleController.deviceServices != null) {
        for (BluetoothService service in bleController
            .deviceServices!) {
          for (BluetoothCharacteristic characteristic in service
              .characteristics) {
            if (characteristic.properties.write) {
              if(!characteristic.isNotifying){
                try {
                  await characteristic.write(stopCall.codeUnits);
                  print("Sent");
                } catch (e) {
                  print("Failed to write characteristic: $e");
                  // Handle the error gracefully
                }
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
              setState(() {
                remoteuid = remoteUid;
              });
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

  @override
  void dispose(){
    // notCall();
    disposeAgora();
    super.dispose();
  }


  Widget build(BuildContext context){
    return GestureDetector(
      onTap: (){
        print("Tapped");
        notCall();
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      child: Container(
        width: 800.w,
        height: 360.h,
        child: remoteuid != 0?
          ClipRect(
          child: AgoraVideoView(controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteuid),
          connection: RtcConnection(channelId: chan),
          )),) : CircularProgressIndicator()
      ),
    );
  }
}