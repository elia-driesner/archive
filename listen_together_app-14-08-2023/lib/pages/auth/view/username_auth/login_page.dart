import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:listen_together_app/models/tokens.dart';
import 'package:listen_together_app/pages/splash_screen/view/splash_screen.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'dart:io' show Platform;
import 'package:listen_together_app/services/functions/functions.dart';

import 'package:listen_together_app/pages/home/home.dart';
import 'package:listen_together_app/services/data/secure_storage.dart';

class LoginPage extends StatefulWidget {
  String username = '';
  LoginPage({super.key, required this.username});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();

  Widget? loadingIndicator;
  String errorMessage = "";

  void login({required String username, required String password}) async {
    errorMessage = "";

    if (username.isEmpty) {
      errorMessage = "Please enter a valid username";
      setState(() => {errorMessage = errorMessage});
    } else if (password.length <= 5) {
      errorMessage = "Password too short";
      setState(() => {errorMessage = errorMessage});
    } else {
      setState(() => loadingIndicator = getLoadingIndicator());
      Map apiReturn = await Authentication.SignIn(username, password);
      if (apiReturn['error_message'] == '') {
        var user_data = apiReturn['user_data'] as Map;
        user_data['data']['password'] = password;
        var jwt = apiReturn['tokens'];
        await SecureStorage.setUserData(user_data['data']);
        await SecureStorage.setTokens(jwt);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SplashScreen(),
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
                    'To Login please enter your password',
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
            Spacer(),
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
                                color: Theme.of(context).colorScheme.error,
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
                          'Login',
                          () => login(
                              username: widget.username,
                              password: passwordController.text),
                        )),
              ],
            ),
          ],
        )));
  }
}
