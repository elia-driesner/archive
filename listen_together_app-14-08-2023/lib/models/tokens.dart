import 'package:flutter/material.dart';

class AuthTokens {
  AuthTokens(this.userTokens);

  Map userTokens;
  static var _storage;
  static Map userTokenKeys = {
    "access_token": "user_acccess_token",
    "refresh_token": "user_refresh_token"
  };

  static Future init(storage) async => _storage = storage;

  static Future<void> saveToStorage(userTokenValues) async {
    try {
      if (userTokenValues != null) {
        if (userTokenValues['access_token'] != null) {
          await _storage.write(
              key: userTokenKeys['access_token'],
              value: userTokenValues['access_token']);
          await _storage.write(
              key: userTokenKeys['refresh_token'],
              value: userTokenValues['refresh_token']);
        } else if (userTokenValues['access'] != null) {
          await _storage.write(
              key: userTokenKeys['access_token'],
              value: userTokenValues['access']);
          await _storage.write(
              key: userTokenKeys['refresh_token'],
              value: userTokenValues['refresh']);
        }
      }
    } catch (e) {
      debugPrint('token write exception:');
    }
  }

  static Future<AuthTokens?> readFromStorage() async {
    Map userTokens = {};
    userTokens['access_token'] =
        await _storage.read(key: userTokenKeys['access_token']);
    userTokens['refresh_token'] =
        await _storage.read(key: userTokenKeys['refresh_token']);
    if (userTokens['access_token'] == null ||
        userTokens['refresh_token'] == null) return null;

    return AuthTokens(userTokens);
  }

  static Future<Map?> readJWT() async {
    Map userTokens = {};
    userTokens['access_token'] =
        await _storage.read(key: userTokenKeys['access_token']);
    userTokens['refresh_token'] =
        await _storage.read(key: userTokenKeys['refresh_token']);
    if (userTokens['access_token'] == null ||
        userTokens['refresh_token'] == null) return null;

    return userTokens;
  }

  static Future<void> clearStorage() async {
    await _storage.delete(
      key: userTokenKeys['access_token'],
    );
    await _storage.delete(
      key: userTokenKeys['refresh_token'],
    );
  }
}
