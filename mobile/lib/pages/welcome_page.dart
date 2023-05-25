import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/getx/app_controller.dart';
import 'package:mobile/pages/main_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Text(
                "Bazalka",
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.green,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: IconButton(
                    onPressed: () {
                      AppController.to.isHome.value = true;
                      Get.off(() => const MainPage());
                    },
                    icon: const Icon(
                      Icons.home_rounded,
                      color: Colors.green,
                    ),
                    iconSize: 60,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: IconButton(
                    onPressed: () {
                      AppController.to.isHome.value = false;
                      Get.off(() => const MainPage());
                    },
                    icon: const Icon(
                      Icons.flight_rounded,
                      color: Colors.green,
                    ),
                    iconSize: 60,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
