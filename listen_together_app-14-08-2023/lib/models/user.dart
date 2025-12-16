import 'dart:convert';

class UserData {
  UserData(this.userData);

  Map userData;
  static var _storage;
  static String userDataKey = 'user_data';

  static Future init(storage) async => _storage = storage;

  static String serialize(userData) {
    return (json.encode(userData));
  }

  static Map? deserialize(userData) {
    if (userData == null) {
      return (null);
    }
    return (json.decode(userData));
  }

  static Future<void> saveToStorage(userData) async {
    try {
      await _storage.write(key: userDataKey, value: serialize(userData));
    } catch (e) {
      print(e);
    }
  }

  static Future<Map?> readFromStorage() async {
    var userData;
    userData = await _storage.read(key: userDataKey);
    userData = deserialize(userData);
    if (userData == null) return null;

    return userData;
  }

  static Future<void> clearStorage() async {
    await _storage.delete(
      key: userDataKey,
    );
  }

  Future<void> updateUserData() async {
    final savedTokens = await readFromStorage();
    if (savedTokens == null) throw Exception("No saved token found");

    // final tokens =
    //     await SpotifyAuthApi.getNewTokens(originalTokens: savedTokens);
    const tokens = true;
    if (tokens) {
      await saveToStorage(tokens);
    }
  }
}
