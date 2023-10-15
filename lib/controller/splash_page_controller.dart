import 'package:get/get.dart';

class SplashPageController extends GetxController {
  @override
  void onInit() {
    Future.delayed(Duration(seconds: 1), () {
      Get.offAllNamed("/home");
    });
    super.onInit();
  }
}
