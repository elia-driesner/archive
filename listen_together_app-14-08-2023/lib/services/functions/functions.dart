import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:spotify_api/spotify_api.dart';
import 'package:listen_together_app/services/data/storage.dart';

Widget getLoadingIndicator() {
  Widget loadingIndicator;
  if (Platform.isAndroid) {
    loadingIndicator = const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
  } else {
    loadingIndicator = const CupertinoActivityIndicator(radius: 18);
  }
  return loadingIndicator;
}

Future formatPlayingSong(userData, tokens) async {
  var spotifyData = await SpotifyAPI.GetPlayingSong(
      userData['username'], userData['password'], tokens['access_token']);
  if (spotifyData['success'] == true) {
    if (spotifyData['data']['success'] == true) {
      if (spotifyData['data']['code'] != 'not_playing') {
        spotifyData = spotifyData['data']['data'];
        await Storage.deleteData('playing_song');
        await Storage.saveData(spotifyData, 'playing_song');
      }
    }
  } else {
    if (spotifyData['error'] == 'spotify_not_connected') {
      await Storage.deleteData('playing_song');
    }
  }
}
