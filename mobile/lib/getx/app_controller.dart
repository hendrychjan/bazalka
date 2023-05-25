import 'package:get/get.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  RxString serverUrlHome = "".obs;
  RxString serverUrlAway = "".obs;
  RxBool isHome = true.obs;
}
