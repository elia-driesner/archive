import 'dart:async';
import 'package:flutter/material.dart';
import 'package:listen_together_app/services/data/secure_storage.dart';
import 'package:listen_together_app/services/data/storage.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'package:listen_together_app/pages/settings/settings.dart';
import 'package:listen_together_app/services/functions/functions.dart';
import 'bottom_sheet.dart';
import 'room_info_sheet.dart';
import './../services/listener.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Map safeUserData;
  late Map safeTokens;
  Map song_data = {
    'cover': '',
    'title': 'Spotify not playing',
    'artist': '',
    'fade_colors': [
      const Color.fromRGBO(0, 0, 0, 1),
      const Color.fromRGBO(0, 0, 0, 1),
    ]
  };
  String errorMessage = '';
  Widget? loadingIndicator;
  bool stopListening = false;
  bool isInRoom = false;
  Map roomInfo = {'room_name': ''};

  void setFadeColors(colors) {
    setState(() => song_data['fade_colors'] = colors);
  }

  void setRoomWidgets([state]) {
    if (state == null) {
      setState(() => isInRoom = true);
    } else {
      setState(() => {
            isInRoom = false,
            {'room_name': ''}
          });
    }
  }

  void setLoadingIndicator(state) {
    if (state == true) {
      setState(() => loadingIndicator = getLoadingIndicator());
    } else {
      setState(() => loadingIndicator = null);
    }
  }

  void showSongData(playingSong) {
    setState(() {
      song_data['fade_colors'] = playingSong['item']['dominant_cover_colors'];
      if (playingSong['item']['is_local'] == false) {
        song_data['cover'] = playingSong['item']['album']['images'][1]['url'];
      } else {
        song_data['cover'] = '';
      }
      song_data['title'] = playingSong['item']['name'];
      song_data['artist'] = playingSong['item']['artist_names'];
    });
  }

  void removeSongData([title]) {
    if (title == null) {
      loadingIndicator = getLoadingIndicator();
      title = 'No Connection';
    } else {
      loadingIndicator = null;
    }
    setState(() => {
          loadingIndicator = loadingIndicator,
          song_data['title'] = title,
          song_data['artist'] = '',
          song_data['cover'] = '',
          song_data['fade_colors'] = [
            const Color.fromRGBO(0, 0, 0, 1),
            const Color.fromRGBO(0, 0, 0, 1),
          ]
        });
  }

  void showRoomInfo(room_info) {
    setState(() {
      roomInfo = room_info;
    });
  }

  void checkLogin(context) async {
    await SocketListener.initHome(setFadeColors, setLoadingIndicator,
        showSongData, removeSongData, setRoomWidgets, showRoomInfo);
    var userData = await SecureStorage.getUserData();
    var _tokens = await SecureStorage.getTokens();
    Map tokens = {};
    if (_tokens != null) {
      tokens = _tokens;
      safeTokens = tokens;
    }
    if (userData != null) {
      safeUserData = userData;
    }
    // debugPrint(user_data.toString());
    var playing_song = Storage.getData('playing_song');
    Map playingSong;
    if (playing_song != null) {
      playingSong = playing_song;
      setState(() {
        userData = userData;

        song_data['fade_colors'] = playingSong['item']['dominant_cover_colors'];
        if (playingSong['item']['is_local'] == false) {
          song_data['cover'] = playingSong['item']['album']['images'][1]['url'];
        }
        song_data['title'] = playingSong['item']['name'];
        song_data['artist'] = playingSong['item']['artist_names'];
      });
      SocketListener.extractColors(playingSong);
    } else {
      if (userData != null) {
        setState(() {
          userData = userData;
        });
      }
    }
    SocketListener.listen(userData?['username'], tokens);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => checkLogin(context));
  }

  @override
  void dispose() {
    super.dispose();
    setState(() {
      stopListening = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Stack(
          children: [
            song_data['fade_colors'] != []
                ? Stack(
                    children: [
                      Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: song_data['fade_colors']))),
                      Opacity(
                        opacity: 0.08,
                        child: Image.asset(
                          'assets/background/noise.png',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ],
                  )
                : Container(),
            SafeArea(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: isInRoom == true
                            ? IconButton(
                                onPressed: () => {
                                      SocketListener.leaveRoom(),
                                      setState(() => isInRoom = false)
                                    },
                                icon: Icon(
                                  Icons.exit_to_app,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.error,
                                ))
                            : const SizedBox(width: 1, height: 1),
                      ),
                      Container(
                          child: isInRoom == true
                              ? Text(roomInfo['room_name'],
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontSize: 22))
                              : const SizedBox(
                                  width: 1,
                                  height: 1,
                                )),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                        child: IconButton(
                            onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SettingsPage(),
                                    ),
                                  )
                                },
                            icon: const Icon(
                              Icons.more_horiz,
                              size: 30,
                              color: Colors.grey,
                            )),
                      ),
                    ]),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: MediaQuery.of(context).size.width),
                  const Spacer(),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, (MediaQuery.of(context).size.height * 0), 0, 0),
                    child: loadingIndicator == null
                        ? Container(
                            margin: EdgeInsets.fromLTRB(0,
                                MediaQuery.of(context).size.width * 0.05, 0, 0),
                            child: SizedBox(
                              width: (MediaQuery.of(context).size.width * 0.60),
                              height:
                                  (MediaQuery.of(context).size.width * 0.60),
                              child: song_data['cover'] != ''
                                  ? Image.network(
                                      fit: BoxFit.cover,
                                      song_data['cover'].toString())
                                  : Image.asset(
                                      fit: BoxFit.cover,
                                      'assets/icons/music_icon.png'),
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.fromLTRB(0,
                                MediaQuery.of(context).size.width * 0.05, 0, 0),
                            width: (MediaQuery.of(context).size.width * 0.60),
                            height: (MediaQuery.of(context).size.width * 0.60),
                            child: loadingIndicator),
                  ),
                  Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      child: Text(
                        song_data['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 30),
                      )),
                  Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        song_data['artist'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 23),
                      )),
                  const Spacer(),
                  Container(
                      margin: EdgeInsets.fromLTRB(
                          0,
                          MediaQuery.of(context).size.height * 0.05,
                          0,
                          MediaQuery.of(context).size.height * 0.02),
                      child: AccentButton(
                          [
                            (MediaQuery.of(context).size.width * 0.8)
                                .toDouble(),
                            (MediaQuery.of(context).size.height * 0.062)
                                .toDouble()
                          ],
                          isInRoom == false ? 'Listen Together' : 'Room Info',
                          () => {
                                if (isInRoom == false)
                                  {CustomBottomSheet.build(context)}
                                else
                                  {RoomView.build(context)}
                              })),
                ],
              ),
            ),
          ],
        ));
  }
}
