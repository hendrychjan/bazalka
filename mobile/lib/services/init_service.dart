import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/getx/app_controller.dart';

class InitService {
  static Future<void> onStartInit() async {
    await GetStorage.init();

    GetStorage().writeIfNull("server_url_home", "");
    GetStorage().writeIfNull("server_url_away", "");

    AppController.to.serverUrlHome.value = GetStorage().read("server_url_home");
    AppController.to.serverUrlAway.value = GetStorage().read("server_url_away");

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent, // Set the status bar color to transparent
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
}
