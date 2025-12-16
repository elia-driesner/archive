import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:listen_together_app/services/data/secure_storage.dart';
import 'package:listen_together_app/services/data/storage.dart';
import 'package:websockets/websockets.dart';
import '/pages/auth/auth.dart';

class Data {
  static Future<void> init() async {
    await SecureStorage.init();
    await Storage.init();
    await Storage.deleteData('playing_song');
  }

  static Future<Map> readData() async {
    var userData = await SecureStorage.getUserData();
    var tokens = await SecureStorage.getTokens();

    return {'user_data': userData, 'tokens': tokens};
  }

  static Future<void> initApp(context) async {
    await init();
    // SecureStorage.clearData();
    var data = await readData();
    var userData = data['user_data'];
    var tokens = data['tokens'];

    if (userData == null || tokens == null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) =>
              const UsernamePage(),
          transitionDuration: Duration.zero,
        ),
      );
    } else {
      await updateData(userData, tokens);
    }
  }

  static Future<void> updateData(userData, tokens) async {
    var newData = await Authentication.RenewData(userData, tokens);
    if (newData['success']) {
      await SecureStorage.setTokens(newData['tokens']);
      await SecureStorage.setUserData(newData['user_data']['data']);
    } else {
      debugPrint('no connection data.dart:58');
      await SecureStorage.setTokens(userData);
      await SecureStorage.setUserData(tokens);
    }
  }
}
