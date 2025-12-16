import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:listen_together_app/services/secure_storage.dart';

class Authentication {
  static var serverUrl = dotenv.env['SERVER_URL'].toString();
  static String errorMessage = '';

  static Future<Map> SignIn(username, password) async {
    var client = http.Client();
    Map decodedToken;
    var decodedUserData;
    var errorMessage = '';
    try {
      await client.get(
        Uri.parse(serverUrl),
      );
    } on Exception catch (_) {
      errorMessage = 'Server not found, try later again';
    }
    if (errorMessage == 'Server not found, try later again') {
      return {'error_message': errorMessage};
    }
    try {
      var tokenResp = await client.post(Uri.parse('${serverUrl}api/token/'),
          body: {'username': username, 'password': password});
      decodedToken = jsonDecode(utf8.decode(tokenResp.bodyBytes)) as Map;
      if (decodedToken['access'] != null) {
        var userDataResp = await client.post(
          Uri.parse('${serverUrl}api/db/login/'),
          headers: {"Authorization": "Bearer " + decodedToken["access"]},
          body: json.encode({'username': username, 'password': password}),
        );
        decodedUserData =
            jsonDecode(utf8.decode(userDataResp.bodyBytes)) as Map;
        decodedUserData['password'] = password;
      } else if (decodedToken['detail'] ==
          'No active account found with the given credentials') {
        var validationResp = await client
            .get(Uri.parse('${serverUrl}api/db/userExists/' + username));
        var decodedValidation =
            jsonDecode(utf8.decode(validationResp.bodyBytes)) as Map;
        if (decodedValidation['detail'] == 'User found') {
          errorMessage = 'Wrong password';
        } else {
          errorMessage = 'User not found';
        }
      }
    } finally {
      client.close();
    }
    if (errorMessage == '') {
      return {
        'error_message': '',
        'tokens': decodedToken,
        'user_data': decodedUserData,
      };
    } else {
      return {'error_message': errorMessage};
    }
  }

  static Future<Map> SignUp(username, password) async {
    username = username;
    var client = http.Client();
    var errorMessage = '';
    var createUserRequest;
    var decodedUserRequest;
    var tokenRequest;
    var decodedToken = {};
    try {
      var serverResp = await client.get(
        Uri.parse(serverUrl),
      );
    } on Exception catch (_) {
      errorMessage = 'Server not found, try later again';
    }
    if (errorMessage == 'Server not found, try later again') {
      return {'error_message': errorMessage};
    }
    try {
      var body = {
        "username": username,
        "password": password,
      };
      String encodedBody = jsonEncode(body);
      createUserRequest = await client
          .post(Uri.parse('${serverUrl}api/db/register/'), body: encodedBody);
      decodedUserRequest =
          jsonDecode(utf8.decode(createUserRequest.bodyBytes)) as Map;
      if (decodedUserRequest['error'] == '') {
        await Future.delayed(const Duration(seconds: 1));
        int iteration = 0;
        while (decodedToken['access'] == null) {
          if (iteration == 20) {
            errorMessage = 'Server timeout';
            break;
          }
          iteration++;
          tokenRequest = await client.post(Uri.parse('${serverUrl}api/token/'),
              body: {'username': username, 'password': password});
          decodedToken = jsonDecode(utf8.decode(tokenRequest.bodyBytes)) as Map;
          await Future.delayed(const Duration(seconds: 1));
        }
        return {
          'error_message': '',
          'user_data': decodedUserRequest,
          'tokens': decodedToken
        };
      } else {
        return {'error_message': decodedUserRequest['error']};
      }
    } finally {
      client.close();
    }
  }

  static Future<String> checkUsername(username) async {
    var client = http.Client();
    var validationResp;
    var decodedValidation;
    try {
      try {
        validationResp = await client
            .get(Uri.parse('${serverUrl}api/db/userExists/' + username));
        errorMessage = '';
      } on Exception catch (_) {
        errorMessage = 'Server not found, try later again';
      }
      if (errorMessage == 'Server not found, try later again') {
        debugPrint(errorMessage);
        return errorMessage;
      }
      decodedValidation =
          jsonDecode(utf8.decode(validationResp.bodyBytes)) as Map;
      if (decodedValidation['detail'] == 'User found') {
        return ('User found');
      } else {
        return ('User not found');
      }
    } finally {
      client.close();
    }
  }

  static Future<Map> RenewData(userData, tokens) async {
    String refreshToken = tokens['refresh_token'];
    http.Client client = http.Client();

    if (userData != null) {
      var accessToken = await client.post(
          Uri.parse('${serverUrl}api/token/refresh/'),
          body: {'refresh': refreshToken});
      var decodedAccessToken = jsonDecode(utf8.decode(accessToken.bodyBytes));
      if (decodedAccessToken['code'] == 'token_not_valid') {
        var tokenResp = await client.post(Uri.parse('${serverUrl}api/token/'),
            body: {
              'username': userData['username'],
              'password': userData['password']
            });
        var decodedResp = jsonDecode(utf8.decode(tokenResp.bodyBytes)) as Map;
        decodedAccessToken = decodedResp['access'];
      } else {
        decodedAccessToken = decodedAccessToken['access'];
      }

      Map<String, String> tokens = {
        'access_token': decodedAccessToken,
        'refresh_token': refreshToken
      };
      var userDataResp = await client.post(
        Uri.parse('${serverUrl}api/db/login/'),
        headers: {'Authorization': 'Bearer $decodedAccessToken'},
        body: json.encode({
          'username': userData['username'],
          'password': userData['password']
        }),
      );
      Map decodedUserData = jsonDecode(utf8.decode(userDataResp.bodyBytes));
      decodedUserData['data']['password'] = userData['password'];
      return {
        'error_message': '',
        'success': true,
        'user_data': decodedUserData,
        'tokens': tokens
      };
    } else {
      return {'error_message': 'No Connection', 'success': false};
    }
  }

  static Future<bool> checkConnection() async {
    await http.get(
      Uri.parse(serverUrl),
    );

    return (true);
  }
}
