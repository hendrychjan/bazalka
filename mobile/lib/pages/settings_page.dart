import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mobile/getx/app_controller.dart';

class SettingsPage extends StatefulWidget {
  final Function redirectCallback;
  const SettingsPage({super.key, required this.redirectCallback});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverUrlHomeController =
      TextEditingController(text: AppController.to.serverUrlHome.value);
  final _serverUrlAwayController =
      TextEditingController(text: AppController.to.serverUrlAway.value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Form(
        key: _formKey,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
            child: TextFormField(
              controller: _serverUrlHomeController,
              decoration: const InputDecoration(
                labelText: 'Local server URL',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 30),
            child: TextFormField(
              controller: _serverUrlAwayController,
              decoration: const InputDecoration(
                labelText: 'Remote server URL',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'This field cannot be empty';
                }
                return null;
              },
            ),
          ),
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }

              AppController.to.serverUrlHome.value =
                  _serverUrlHomeController.text;
              AppController.to.serverUrlAway.value =
                  _serverUrlAwayController.text;

              await GetStorage().write(
                'server_url_home',
                _serverUrlHomeController.text,
              );

              await GetStorage().write(
                'server_url_away',
                _serverUrlAwayController.text,
              );

              widget.redirectCallback();
            },
          ),
        ]),
      ),
    );
  }
}
