import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:listen_together_app/services/secure_storage.dart';

class Websocket {
  static String serverApiUrl = dotenv.env['SERVER_URL'].toString();
  static String serverUrl = dotenv.env['WEBSOCKETS_URL'].toString();
  static String playingSongUrl = dotenv.env['PLAYING_SONG_URL'].toString();
  static var channel;

  static Future<Map> getTicket(tokens) async {
    String refreshToken;
    if (tokens['refresh'] != null) {
      refreshToken = tokens['refresh'];
    } else {
      refreshToken = tokens['refresh_token'];
    }
    try {
      var ticketResp = await http.post(
        Uri.parse('${serverApiUrl}api/playback/get_ticket/'),
        headers: {"Authorization": "Bearer " + tokens['access_token']},
      );
      Map decodedTicket = jsonDecode(utf8.decode(ticketResp.bodyBytes));
      if (decodedTicket['code'] == 'token_not_valid') {
        var tokenResp = await http.post(
            Uri.parse('${serverApiUrl}api/token/refresh/'),
            body: {'refresh': refreshToken});
        var decodedTokenResp =
            jsonDecode(utf8.decode(tokenResp.bodyBytes)) as Map;
        return {
          'success': false,
          'data': null,
          'code': 'token_expired',
          'tokens': {
            'refresh_token': refreshToken,
            'access_token': decodedTokenResp['access']
          }
        };
      } else {
        return {'data': decodedTicket['data'], 'success': true};
      }
    } on Exception catch (_) {
      return {'success': false, 'data': null};
    }
  }

  static Future renewConnection(tokens) async {
    if (channel != null) channel.sink.close();
    Map ticket = await getTicket(tokens);
    if (ticket['success'] == true) {
      channel = await WebSocketChannel.connect(
        Uri.parse('$serverUrl$playingSongUrl?ticket=' + ticket['data']),
      );
    } else {
      if (ticket['tokens'] != null) {
        Map newTicket = await getTicket(ticket['tokens']);
        if (newTicket['success'] == true) {
          channel = await WebSocketChannel.connect(
            Uri.parse('$serverUrl$playingSongUrl?ticket=' + newTicket['data']),
          );
        }
      }
    }
  }

  static void send(data) => channel.sink.add(data);

  static void disconnect() => channel.sink.close();
}
