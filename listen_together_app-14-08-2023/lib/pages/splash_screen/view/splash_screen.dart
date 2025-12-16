import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:listen_together_app/services/functions/functions.dart';
import 'package:listen_together_app/services/data/storage.dart';
import 'package:listen_together_app/services/data/data.dart';
import 'package:spotify_api/spotify_api.dart';
import 'package:listen_together_app/pages/home/home.dart';
import 'package:listen_together_app/pages/auth/auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  Widget? loadingIndicator;
  String errorMessage = '';

  void loadApp() async {
    while (true) {
      bool connection = await Authentication.checkConnection();
      debugPrint(connection.toString());
      if (connection) {
        break;
      } else {
        setState(() {
          errorMessage = 'No Connection to the Server';
          loadingIndicator = null;
        });
      }
      Future.delayed(const Duration(milliseconds: 200));
    }
    setState(() {
      loadingIndicator = getLoadingIndicator();
      errorMessage = '';
    });

    // ignore: use_build_context_synchronously
    await Data.initApp(context);

    var data = await Data.readData();
    var tokens = data['tokens'];
    var userData = data['user_data'];

    if (userData != null) {
      await formatPlayingSong(userData, tokens);
      if (userData['spotify_refresh_token'] == "") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SpotifyConnectPage(
                    username: userData['username'],
                    password: userData['password'],
                    uid: userData['uid'])));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Homepage(),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, (MediaQuery.of(context).size.height * 0), 0, 0),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width * 0.45),
                      child: Image.asset(
                          fit: BoxFit.cover, 'assets/icons/logo/ios.png'),
                    )),
                Container(
                  margin: EdgeInsets.fromLTRB(
                      0, (MediaQuery.of(context).size.height * 0), 0, 0),
                  child: Text(
                    'By Elia Driesner',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: loadingIndicator),
          const Spacer(),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Text(errorMessage,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.error,
                    fontSize: (MediaQuery.of(context).size.width * 0.042))),
          ),
          Text(
            'V0.1 Beta Test',
            style: TextStyle(
                color: Theme.of(context).primaryColorLight, fontSize: 14),
          ),
        ],
      )),
    );
  }
}
