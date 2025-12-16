import 'dart:math';

import 'package:flutter/material.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:listen_together_app/services/data/secure_storage.dart';
import 'package:listen_together_app/pages/auth/auth.dart';
import 'package:websockets/websockets.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Widget> children = [];
  Map user_data = {};

  logout() async {
    await SecureStorage.clearData();
    Websocket.disconnect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UsernamePage(),
      ),
    );
  }

  void getUserData() async {
    var _user_data = await SecureStorage.getUserData();
    if (_user_data != null) {
      setState(() {
        user_data = _user_data;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) => create_widgets());
  }

  late Map settings = {
    'Account': [
      ['Remove Spotify Data', () => {}],
      ['Change Password', () => {}],
      ['Delete Account', () => {}],
      [
        'Logout',
        () => {logout()}
      ]
    ],
    'About': [
      ['About us', () => {}],
      [
        'Website',
        () => {
              launchUrl(Uri.parse(dotenv.env['SERVER_URL'].toString()),
                  webOnlyWindowName: '_blank')
            }
      ]
    ]
  };

  void create_widgets() async {
    settings.forEach((key, value) {
      children.add(
        Container(
          margin: const EdgeInsets.fromLTRB(40, 20, 50, 0),
          alignment: Alignment.bottomLeft,
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: Text(
                  key,
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight, fontSize: 17),
                ),
              ),
              const Expanded(child: Divider(color: Colors.grey)),
            ],
          ),
        ),
      );
      var part = settings[key];
      part.forEach((value) {
        children.add(SettingsButton([
          (MediaQuery.of(context).size.width * 1).toDouble(),
          (MediaQuery.of(context).size.height * 0.062).toDouble()
        ], value[0], value[1]));
      });
    });
    setState(() {
      children = children;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
            child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 40, 0),
                    child: IconButton(
                        onPressed: () => {Navigator.pop(context)},
                        alignment: Alignment.centerLeft,
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight, fontSize: 23),
                ),
                const Spacer(),
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                user_data['username'] != null
                    ? Text(
                        user_data['username'],
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 23),
                      )
                    : Text(''),
              ],
            ),
            Column(
              children: children,
            )
          ],
        )));
  }
}
