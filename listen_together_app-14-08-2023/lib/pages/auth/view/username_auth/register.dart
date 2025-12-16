import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:listen_together_app/models/tokens.dart';
import 'package:listen_together_app/pages/auth/view/spotify_auth/connect_page.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'dart:io' show Platform;
import 'package:listen_together_app/pages/auth/auth.dart';
import 'package:listen_together_app/services/functions/functions.dart';
import 'package:listen_together_app/pages/home/home.dart';
import 'package:listen_together_app/services/data/secure_storage.dart';

class RegisterPage extends StatefulWidget {
  String username = '';
  RegisterPage({super.key, required this.username});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final passwordController = TextEditingController();
  final auth = Authentication();

  Widget? loadingIndicator;
  String errorMessage = "";

  void createAccount({username, password}) async {
    errorMessage = "";
    Map apiReturn = {};
    if (username.length == 0) {
      errorMessage = "Please enter a valid username";
      setState(() => errorMessage = errorMessage);
    } else if (password.length <= 5) {
      errorMessage = "Password too short";
      setState(() => errorMessage = errorMessage);
    } else {
      setState(() => loadingIndicator = getLoadingIndicator());
      apiReturn = await Authentication.SignUp(username, password);
      if (apiReturn['error_message'] == '') {
        debugPrint(apiReturn.toString());
        var user_data = apiReturn['user_data'] as Map;
        var jwt = apiReturn['tokens'];
        user_data['data']['password'] = password;
        await SecureStorage.setUserData(user_data['data']);
        await SecureStorage.setTokens(jwt);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SpotifyConnectPage(
                username: username,
                password: password,
                uid: user_data['data']['uid']),
          ),
        );
      } else {
        setState(() => {
              errorMessage = apiReturn['error_message'],
              loadingIndicator = null
            });
      }
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
              margin: EdgeInsets.fromLTRB(
                  0, (MediaQuery.of(context).size.height * 0.02), 0, 0),
              child: Center(
                  child: Text('Listen Together',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize:
                              (MediaQuery.of(context).size.width * 0.06)))),
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width * 0.8).toDouble(),
              child: Container(
                  margin: EdgeInsets.fromLTRB(
                      5, (MediaQuery.of(context).size.height * 0.09), 0, 0),
                  child: Text(
                    'To create your account please enter a password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: (MediaQuery.of(context).size.width * 0.055)),
                  )),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  0, (MediaQuery.of(context).size.height * 0.03), 0, 0),
              child: BigInput(
                size: [
                  (MediaQuery.of(context).size.width * 0.8).toDouble(),
                  (MediaQuery.of(context).size.height * 0.1).toDouble()
                ],
                text: "Your Password",
                controller: passwordController,
                obscureText: true,
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, (MediaQuery.of(context).size.height * 0.02)),
                    child: errorMessage != ''
                        ? Text(errorMessage,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.error,
                                fontSize: (MediaQuery.of(context).size.width *
                                    0.042)))
                        : Text('',
                            style: TextStyle(
                                // ignore: deprecated_member_use
                                color: Theme.of(context).errorColor,
                                fontSize: (MediaQuery.of(context).size.width *
                                    0.042)))),
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, MediaQuery.of(context).size.height * 0.035),
                    child: loadingIndicator ??
                        AccentButton(
                          [
                            (MediaQuery.of(context).size.width * 0.8)
                                .toDouble(),
                            (MediaQuery.of(context).size.height * 0.062)
                                .toDouble()
                          ],
                          'Create Account',
                          () => createAccount(
                              username: widget.username,
                              password: passwordController.text),
                        )),
              ],
            ),
          ],
        )));
  }
}
