import 'package:caremate_screen/pages/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:caremate_screen/AIConfig.dart';

class BleController extends GetxController{
  FlutterBlue ble_scan = FlutterBlue.instance;
  Stream<List<ScanResult>>? scanResultsStream;
  BluetoothDevice? connectedDevice;
  List<BluetoothService>? deviceServices;
  var connectionStatus = ''.obs;


  // BleController(){
  //   scanDevices();
  // }

  Future scanDevices() async{
    if(await Permission.bluetoothScan.request().isGranted){
      if(await Permission.bluetoothConnect.request().isGranted){
        ble_scan.startScan(
        );
        // await Future.delayed(Duration(seconds: 10));
        scanResultsStream = ble_scan.scanResults;
        // ble_scan.stopScan();
      }
    }
  }
  Future? connectDevice(BluetoothDevice device) async{
    connectionStatus.value = 'connecting';
      await device?.connect(timeout: Duration(seconds: 15));
    connectedDevice = device;
    await discoverServices(device);
    update();
    String device_name = device.name;
    device?.state.listen((isConnected) {
      if(isConnected == BluetoothDeviceState.connecting){
        print('Connecting...');
        connectionStatus.value = 'connecting';
      }
      if(isConnected == BluetoothDeviceState.connected){
        connectionStatus.value = '';
        print('Connected to $device_name');
      }else if (isConnected == BluetoothDeviceState.disconnected){
        connectionStatus.value = '';
        print('Disconnected');
      }
    });

    print('Device info: $device');
  }

  Future<void> discoverServices(BluetoothDevice device) async{
    List<BluetoothService> services = await device.discoverServices();
    deviceServices = services;
    update();
  }

  Stream<List<ScanResult>> get ScanResults => ble_scan.scanResults;

}

class Ble_page extends StatefulWidget{
  Ble_page({super.key});

  @override
  State<Ble_page> createState() => _Ble_pageState();
}

class _Ble_pageState extends State<Ble_page> {
  OverlayEntry? entry;
  AIStatusController AI_Status = Get.find<AIStatusController>();

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
              Text('Bluetooth connected'),
              FloatingActionButton(onPressed: (){
                entry!.remove();
              },
                child: Text("OK"),
              )
            ],
          )
      ),
    ),
  );

  String connectionStatus = '';
  late BleController controller;

  void initState() {
    super.initState();
    controller = Get.find<BleController>();
    // Start the scan when the page is initialized
    controller.scanDevices();
  }

  void dispose() {
    // Stop the Bluetooth scan when the page is disposed
    BleController().ble_scan.stopScan();
    print("Scan disposed");
    super.dispose();
  }

  void showErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override

  Widget build(BuildContext context){
    return GetBuilder<BleController>(
        init: BleController(),
        builder: (BleController controller){
          return Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/screen_bg.png'),
                    fit: BoxFit.cover
                )
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if(controller.connectionStatus.value == 'connecting')
                    CircularProgressIndicator(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: (){
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                          icon: Icon(Icons.home)),
                      Obx((){
                        return Switch(
                            value: AI_Status.isOn.value,
                            activeColor: Colors.lightBlueAccent,
                            onChanged: (value) {
                              // if (!AI_Status.isOn.value) {
                              //   AI_Status.isOn = true.obs;
                              //   print("AI is on");
                              // } else {
                              //   AI_Status.isOn = false.obs;
                              //   print("AI turned off");
                              // }
                              AI_Status.setAIStatus(value);
                              print("AI is ${value ? 'on' : 'off'}");
                            });
                      })
                    ],
                  ),
                  Container(
                    width: 635.w,
                    height: 340.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: Colors.white,
                    ),
                    child: StreamBuilder<List<ScanResult>>(
                            stream: controller.ScanResults,
                            builder: (context,snapshot){
                              if(snapshot.hasData){
                                final filteredResults = snapshot.data!.where(
                                        (result) => result.device.name.contains("CareMate")
                                ).toList();
                                if(filteredResults.isEmpty){
                                  return Center(
                                    child: Text("We are unable to find CareMate"),
                                  );
                                }
                                return ListView.builder(
                                    itemCount: filteredResults.length,
                                    itemBuilder: (context, index){
                                      final data = filteredResults[index];
                                      return Padding(
                                        padding: EdgeInsets.fromLTRB(20.w,10.h,20.w,0),
                                        child: GestureDetector(
                                          onTap: () async{
                                            await controller.connectDevice(data.device);
                                            if(controller.connectedDevice != null){
                                              ShowSetEvent1();
                                            }
                                          },
                                          child: Container(
                                            width: 300.w,
                                            height: 62.h,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12.r),
                                              color: HexColor('#5490FE'),
                                            ),
                                            child: ListTile(
                                              title: Text(data.device.name.isNotEmpty
                                                  ? data.device.name
                                                  : "Unknown Device",
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Montserrat_bold',
                                                    color: Colors.white
                                                ),
                                              ),
                                              subtitle: Text(data.device.id.id,
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontFamily: 'Montserrat_bold',
                                                    color: Colors.white
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                );
                              }else{
                                return Center(
                                  child: Text('No nearby devices'),
                                );
                              }
                            }),

                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}