import 'dart:convert';
import 'package:caremate_screen/AIConfig.dart';
import 'package:flutter/material.dart';
import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'bluetooth/bluetooth_page.dart';
import 'package:get/get.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:video_player/video_player.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  Wakelock.enable();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,);
  // try{
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  // }catch(e){
  //   print('Firebase initialization error $e');
  // }
  runApp(MyApp());

  BleController bleController = BleController();
  // Add BleController to the GetX dependency injection system
  Get.put<BleController>(bleController);
  Get.put(AIStatusController());

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
String fieldVal = '';
FlutterTts TTS = FlutterTts();
String cleaned_text = "";
bool initMsg = false;
final bleController = Get.find<BleController>();
String med1 = "M-1";
String med2 = "M-2";
String med3 = "M-3";
OverlayEntry? entry;
late VideoPlayerController _controller;
String medState = 'null';

void initState(){
  super.initState();
  // initTTS();
  initMsg = false;
  // ListenForAI();
  ListenBLE();
  // checkMedState();
}

// void initTTS(){
//
// }

void dispose(){
  // setState(() {
  //   initMsg = false;
  // });
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
              try {
                await characteristic.setNotifyValue(true);
                characteristic.value.listen((data) {
                  print("Main Received: ${utf8.decode(data)}");
                  List data_content = utf8.decode(data).split(' ');
                  for(String item in data_content){
                    print("Item in data: $item");
                  }
                  if(utf8.decode(data) == 'L-1'){
                    setState(() {
                      medState = "not taken";
                    });
                  }
                  if(utf8.decode(data) == 'L-0'){
                    setState(() {
                      medState = "taken";
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



  String cleanText(String text){
    final symbols = RegExp(r'[$*.{}\[\]?\"!@#%&/\\,><:;_~`+=]');
    var cleaned = text.replaceAll(symbols, " ");
    cleaned_text = cleaned.toString();
    return cleaned_text;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(

      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
