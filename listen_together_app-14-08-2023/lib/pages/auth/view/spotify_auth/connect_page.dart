import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:authentication/authentication.dart';
import 'package:listen_together_app/pages/splash_screen/view/splash_screen.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'package:spotify_api/spotify_api.dart';
import 'package:listen_together_app/services/data/secure_storage.dart';
import 'package:listen_together_app/pages/home/home.dart';
import '/pages/auth/auth.dart';

class SpotifyConnectPage extends StatefulWidget {
  late String username;
  late String password;
  late String uid;
  SpotifyConnectPage(
      {super.key,
      required this.username,
      required this.password,
      required this.uid});

  @override
  State<SpotifyConnectPage> createState() => _SpotifyConnectPageState();
}

class _SpotifyConnectPageState extends State<SpotifyConnectPage> {
  String errorMessage = "";
  Widget? loadingIndicator;
  final auth = Authentication();

  logout() async {
    await SecureStorage.clearData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => UsernamePage(),
      ),
    );
  }

  void connectSpotify() async {
    if (Platform.isAndroid) {
      loadingIndicator = const CircularProgressIndicator();
    } else {
      loadingIndicator = const CupertinoActivityIndicator(radius: 18);
    }
    setState(() => {loadingIndicator});

    bool success = await SpotifyAPI.SignIn(widget.uid);
    if (success) {
      Future.delayed(const Duration(seconds: 1));
      Map apiReturn =
          await Authentication.SignIn(widget.username, widget.password);
      if (apiReturn['error_message'] == '') {
        var user_data = apiReturn['user_data'] as Map;
        user_data['data']['password'] = widget.password;
        await SecureStorage.setUserData(user_data['data']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      } else {
        setState(() {
          errorMessage = 'Something went wrong';
          loadingIndicator = null;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Something went wrong';
        loadingIndicator = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
            child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 40, 0),
                    child: IconButton(
                        onPressed: () => {logout()},
                        alignment: Alignment.centerLeft,
                        icon: const Icon(
                          Icons.logout,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                ),
                Text(
                  'Listen Together',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight, fontSize: 23),
                ),
                const Spacer(),
              ]),
            ),
            Stack(children: []),
            Container(
                margin: EdgeInsets.fromLTRB(
                    0, (MediaQuery.of(context).size.height * 0.08), 0, 0),
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width * 1),
                  child: Image.asset(
                      fit: BoxFit.cover,
                      'assets/artworks/spotify_connect_page_art.png'),
                )),
            const Spacer(),
            SizedBox(
              width: (MediaQuery.of(context).size.width * 0.8).toDouble(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect your',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: (MediaQuery.of(context).size.width * 0.09)),
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(
                          0, (MediaQuery.of(context).size.height * 0.0), 0, 0),
                      child: Text(
                        'Spotify Account',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color(0xff1db954),
                            fontSize:
                                (MediaQuery.of(context).size.width * 0.09)),
                      )),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, (MediaQuery.of(context).size.height * 0.02)),
                    child: errorMessage != ''
                        ? Text('$errorMessage',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.error,
                                fontSize: (MediaQuery.of(context).size.width *
                                    0.042)))
                        : Text('',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: (MediaQuery.of(context).size.width *
                                    0.042)))),
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, MediaQuery.of(context).size.height * 0.05),
                    child: loadingIndicator ??
                        AccentButton(
                          [
                            (MediaQuery.of(context).size.width * 0.8)
                                .toDouble(),
                            (MediaQuery.of(context).size.height * 0.062)
                                .toDouble()
                          ],
                          'Connect Spotify',
                          () => connectSpotify(),
                        )),
              ],
            ),
          ],
        )));
    ;
  }
}
