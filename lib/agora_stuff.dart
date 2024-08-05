import 'package:agora_uikit/agora_uikit.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';


// late RtcEngine engine;
// bool localUserJoined = false;
// int? remoteUid ;
// AgoraClient? client;
//
// @override
// void initState() {
//   super.initState();
//   initAgora();
// }
//
// Future<void> initAgora() async {
//   await [Permission.camera].request();
//   engine = createAgoraRtcEngine();
//   await engine.initialize(const RtcEngineContext(
//       appId: appId,
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting
//   ));
//   engine.registerEventHandler(RtcEngineEventHandler(
//     onJoinChannelSuccess: (RtcConnection connection, int elapsed){
//       print('user ${connection.localUid} joined');
//       setState(() {
//         localUserJoined = true;
//       });
//     },
//     onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//       debugPrint("remote user $remoteUid joined");
//       setState(() {
//         remoteUid = remoteUid;
//       });
//     },
//     onUserOffline: (RtcConnection connection, int remoteUid,
//         UserOfflineReasonType reason) {
//       debugPrint("remote user $remoteUid left channel");
//       setState(() {
//         remoteUid = 0;
//       });
//     },
//     onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//       debugPrint(
//           '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//     },
//   ));
//
//   await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//   await engine.enableVideo();
//   await engine.startPreview();
//
//   await engine.joinChannel(
//     token: token,
//     channelId: channel,
//     uid: 0,
//     options: const ChannelMediaOptions(),
//   );
// }
//
// @override
// void dispose() {
//   super.dispose();
//
//   _dispose();
// }
//
// Future<void> _dispose() async {
//   await engine.leaveChannel();
//   await engine.release();
// }