import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static late SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future saveData(Map data, String key) async {
    String encodedData = json.encode(data);
    await _preferences.setString(key, encodedData);
  }

  static Map? getData(String key) {
    String? encodedData = _preferences.getString(key);
    if (encodedData == null) {
      return null;
    } else {
      Map data = json.decode(encodedData);
      return (data);
    }
  }

  static Future deleteData(key) async {
    await _preferences.remove(key);
  }
}
