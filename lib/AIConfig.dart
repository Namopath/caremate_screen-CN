import 'package:get/get.dart';

class AIStatusController extends GetxController {
  var isOn = false.obs;

  void toggleAIStatus() {
    isOn.value = !isOn.value;
  }

  void setAIStatus(bool value) {
    isOn.value = value;
  }
}