import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'dart:io' show Platform;
import 'package:listen_together_app/services/functions/functions.dart';
import 'package:listen_together_app/pages/auth/auth.dart';

class UsernamePage extends StatefulWidget {
  const UsernamePage({super.key});

  @override
  State<UsernamePage> createState() => _UsernamePageState();
}

class _UsernamePageState extends State<UsernamePage> {
  final usernameController = TextEditingController();
  final auth = Authentication();

  Widget? loadingIndicator;
  String errorMessage = "";

  void checkAccount(String username) async {
    if (username.isEmpty) {
      errorMessage = "Please enter a valid username";
      setState(() => errorMessage = errorMessage);
    } else {
      errorMessage = '';
      setState(() => {loadingIndicator = getLoadingIndicator(), errorMessage});
    }
    if (errorMessage == '') {
      String userExists = await Authentication.checkUsername(username);
      if (userExists == 'Server not found, try later again') {
        setState(() => {
              errorMessage = 'Server not found, try later again',
              loadingIndicator = null
            });
      } else if (userExists == 'User found') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(username: username)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RegisterPage(username: username)));
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
                    'First off, please enter your name',
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
                text: "Your Name",
                controller: usernameController,
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
                                color: Theme.of(context).colorScheme.error,
                                fontSize: (MediaQuery.of(context).size.width *
                                    0.042)))),
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, MediaQuery.of(context).size.height * 0.035),
                    child: loadingIndicator ??
                        AccentButton([
                          (MediaQuery.of(context).size.width * 0.8).toDouble(),
                          (MediaQuery.of(context).size.height * 0.062)
                              .toDouble()
                        ], 'Continue',
                            () => checkAccount(usernameController.text))),
              ],
            ),
          ],
        )));
  }
}


// change size dynamically on text