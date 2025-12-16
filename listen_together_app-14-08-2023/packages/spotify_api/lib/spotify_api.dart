import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SpotifyAPI {
  static String client_id = dotenv.env['SPOTIFY_CLIENT_ID'].toString();
  static String redirect_uri = dotenv.env['SERVER_URL'].toString() +
      dotenv.env['SPOTIFY_REDIRECT_URL'].toString();
  static Map<String, dynamic> url_map = {
    'login': 'https://accounts.spotify.com/authorize?'
  };
  static var client = http.Client();

  static Future<bool> SignIn(uid) async {
    var scope =
        'user-read-private user-read-playback-state user-modify-playback-state user-read-currently-playing app-remote-control';
    final params = {
      'client_id': client_id,
      'scope': scope,
      'redirect_uri': redirect_uri,
      'state': uid,
      'response_type': 'code',
    };

    final Uri url = Uri.http('accounts.spotify.com', 'authorize', params);
    try {
      var resp = await launchUrl(url);
      return resp;
    } on Exception catch (_) {
      return false;
    }
  }

  static Future<Map> GetPlayingSong(username, password, accessToken) async {
    String serverUrl = dotenv.env['SERVER_URL'].toString();
    String url = '${serverUrl}api/playback/playing_song/';
    try {
      String encodedBody =
          jsonEncode({"password": password, "username": username});
      var playingSong = await client.post(Uri.parse(url),
          body: encodedBody, headers: {"Authorization": "Bearer $accessToken"});
      var decPlayingSong = jsonDecode(utf8.decode(playingSong.bodyBytes));
      if (decPlayingSong['success'] == true) {
        return {'data': decPlayingSong, 'error_message': '', 'success': true};
      } else if (decPlayingSong['error'] == 'spotify_not_connected') {
        return {'error_message': 'spotify_not_connected', 'success': false};
      }
      return {'error_message': 'Something went wrong', 'success': false};
    } on Exception catch (_) {
      return {'error_message': 'No connection to Spotify', 'success': false};
    }
  }
}
