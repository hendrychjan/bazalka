import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/getx/app_controller.dart';
import 'package:mobile/pages/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Socket? _socket;
  int? _moisture;
  bool _connecting = true;
  bool _connected = false;

  Future<void> _connectTCP() async {
    try {
      List<String> url = (AppController.to.isHome.value)
          ? AppController.to.serverUrlHome.value.split(":")
          : AppController.to.serverUrlAway.value.split(":");

      _socket = await Socket.connect(url[0], int.parse(url[1]));

      _socket!.listen(
        (List<int> data) {
          String packet = utf8.decode(data);
          int? sensorValue = int.tryParse(packet);
          if (sensorValue != null) {
            setState(() {
              _moisture = sensorValue;
            });
          }
          // Perform your desired action with the received data
        },
        onError: (error) {
          print('Socket error: $error');
          // Handle any socket errors
        },
        onDone: () {
          setState(() {
            _connected = false;
          });
          print('Socket closed');
          // Perform actions when the socket is closed
        },
      );

      setState(() {
        _connecting = false;
        _connected = true;
      });
    } catch (e) {
      setState(() {
        _connecting = false;
        _connected = false;
      });
    }
  }

  Future<void> _moduleUpdate() async {
    _socket?.write("update");
  }

  void _moduleWaterAuto() {
    _socket?.write("water_auto");
  }

  void _modulePumpOn() {
    _socket?.write("pump_on");
  }

  void _modulePumpOff() {
    _socket?.write("pump_off");
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _connectTCP);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazalka'),
        actions: [
          Container(
            width: 20, // Adjust the size as needed
            height: 20, // Adjust the size as needed
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _connected ? Colors.green : Colors.red,
              boxShadow: [
                BoxShadow(
                  color: _connected ? Colors.green : Colors.red,
                  blurRadius: 10,
                  spreadRadius: 1,
                  blurStyle: BlurStyle.normal,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.grey,
            ),
            onPressed: () {
              Get.to(() => SettingsPage(redirectCallback: Get.back));
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _connectTCP,
        child: (_connecting)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      (_connected)
                          ? const Text('Connected!',
                              style: TextStyle(color: Colors.green))
                          : const Text('Not connected!',
                              style: TextStyle(color: Colors.red)),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30, top: 50),
                        child: Text(
                          "$_moisture%",
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 40),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30, right: 30, bottom: 50),
                        child: LinearProgressIndicator(
                          color: Colors.blue,
                          backgroundColor: Colors.blue[100],
                          minHeight: 15,
                          value: ((_moisture ?? 0) + .0) / 100,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: _connected ? _moduleUpdate : null,
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.green,
                            ),
                            iconSize: 50,
                          ),
                          IconButton(
                            onPressed: _connected ? _moduleWaterAuto : null,
                            icon: const Icon(
                              Icons.water_drop,
                              color: Colors.green,
                            ),
                            iconSize: 50,
                          ),
                          GestureDetector(
                            onTapDown: (d) {
                              _modulePumpOn();
                            },
                            onTapCancel: () {
                              _modulePumpOff();
                            },
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.flash_on,
                                color: Colors.green,
                              ),
                              iconSize: 50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
