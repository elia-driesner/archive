import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:listen_together_app/models/tokens.dart';
import 'package:listen_together_app/models/user.dart';

class SecureStorage {
  static late var storage;

  static Future init() async {
    storage = const FlutterSecureStorage();
    await AuthTokens.init(storage);
    await UserData.init(storage);
  }

  static Future<void> clearData() async {
    await UserData.clearStorage();
    await AuthTokens.clearStorage();
  }

  // Tokens

  static Future<Map?> getTokens() async {
    return await AuthTokens.readJWT();
  }

  static Future<void> setTokens(userTokens) async {
    await AuthTokens.saveToStorage(userTokens);
  }

  static Future<void> clearTokens() async {
    await AuthTokens.clearStorage();
  }

  // User data

  static Future<Map?> getUserData() async {
    return await UserData.readFromStorage();
  }

  static Future<void> setUserData(userData) async {
    await UserData.saveToStorage(userData);
  }

  static Future<void> clearUserData() async {
    await UserData.clearStorage();
  }
}
