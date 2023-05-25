import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/getx/app_controller.dart';
import 'package:mobile/pages/settings_page.dart';
import 'package:mobile/pages/welcome_page.dart';
import 'package:mobile/services/init_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await InitService.onStartInit();
      if (AppController.to.serverUrlHome.value.isEmpty ||
          AppController.to.serverUrlAway.value.isEmpty) {
        await Get.off(
          () => SettingsPage(
            redirectCallback: () => Get.off(
              () => const WelcomePage(),
            ),
          ),
        );
        return;
      }
      await Get.off(() => const WelcomePage());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
