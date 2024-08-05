// Flutter web plugin registrant file.
//
// Generated file. Do not edit.
//

// @dart = 2.13
// ignore_for_file: type=lint

import 'package:agora_rtc_engine/agora_rtc_engine_web.dart';
import 'package:camera_web/camera_web.dart';
import 'package:cloud_firestore_web/cloud_firestore_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter_tts/flutter_tts_web.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:iris_method_channel/iris_method_channel_web.dart';
import 'package:permission_handler_html/permission_handler_html.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:video_player_web/video_player_web.dart';
import 'package:wakelock_web/wakelock_web.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void registerPlugins([final Registrar? pluginRegistrar]) {
  final Registrar registrar = pluginRegistrar ?? webPluginRegistrar;
  AgoraRtcEngineWeb.registerWith(registrar);
  CameraPlugin.registerWith(registrar);
  FirebaseFirestoreWeb.registerWith(registrar);
  FirebaseCoreWeb.registerWith(registrar);
  FlutterTtsPlugin.registerWith(registrar);
  ImagePickerPlugin.registerWith(registrar);
  IrisMethodChannelWeb.registerWith(registrar);
  WebPermissionHandler.registerWith(registrar);
  UrlLauncherPlugin.registerWith(registrar);
  VideoPlayerPlugin.registerWith(registrar);
  WakelockWeb.registerWith(registrar);
  registrar.registerMessageHandler();
}
