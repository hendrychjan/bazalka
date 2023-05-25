import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/getx/app_controller.dart';
import 'package:mobile/pages/splash_page.dart';

void main() {
  Get.put(AppController());

  runApp(
    GetMaterialApp(
      title: 'Bazalka',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.green,
          elevation: 0,
        ),
      ),
      home: const SplashPage(),
    ),
  );
}
