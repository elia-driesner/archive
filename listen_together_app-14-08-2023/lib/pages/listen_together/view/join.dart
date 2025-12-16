import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listen_together_app/widgets/widgets.dart';

class JoinListenTogether extends StatefulWidget {
  const JoinListenTogether({super.key});

  @override
  State<JoinListenTogether> createState() => _JoinListenTogetherState();
}

class _JoinListenTogetherState extends State<JoinListenTogether> {
  TextEditingController idController = TextEditingController();
  double name_margin = 0.1;
  List<double> name_size = [0.8, 0.1];
  String errorMessage = '';
  Widget? loadingIndicator;

  void moveName() async {
    setState(() => {
          name_margin = 0.02,
          name_size = [0.6, 0.09]
        });
  }

  void moveNameBack() async {
    setState(() => {
          name_margin = 0.1,
          name_size = [0.8, 0.1]
        });
  }

  void join(roomId) async {
    roomId = roomId.toString();
    if (roomId == '') {
      setState(() => {errorMessage = 'Please enter the ID'});
      moveNameBack();
    } else if (roomId.length >= 5 || roomId.length <= 3) {
      setState(() => {errorMessage = 'Please enter the 4 digit code'});
      moveNameBack();
    } else {
      setState(() => {errorMessage = ''});
      moveName();
      if (Platform.isAndroid) {
        loadingIndicator = const CircularProgressIndicator();
      } else {
        loadingIndicator = const CupertinoActivityIndicator(radius: 18);
      }
      setState(() => loadingIndicator);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Row(children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 40, 0),
                    child: IconButton(
                        onPressed: () => {Navigator.pop(context)},
                        alignment: Alignment.centerLeft,
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                ),
                Text(
                  'Join Listen Together',
                  style: TextStyle(
                      color: Theme.of(context).primaryColorLight, fontSize: 23),
                ),
                const Spacer(),
              ]),
            ),
            AnimatedContainer(
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 120),
              margin: EdgeInsets.fromLTRB(
                  0, (MediaQuery.of(context).size.height * name_margin), 0, 0),
              child: AnimatedSize(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 100),
                child: BigInput(
                  size: [
                    (MediaQuery.of(context).size.width * name_size[0])
                        .toDouble(),
                    (MediaQuery.of(context).size.height * name_size[1])
                        .toDouble()
                  ],
                  text: "Room ID",
                  controller: idController,
                  obscureText: false,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(
                    0, (MediaQuery.of(context).size.height * 0.08), 0, 0),
                child:
                    loadingIndicator != null ? loadingIndicator : Container()),
            const Spacer(),
            Container(
                margin: EdgeInsets.fromLTRB(
                    0, 0, 0, (MediaQuery.of(context).size.height * 0.02)),
                child: errorMessage != ''
                    ? Text(errorMessage,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.error,
                            fontSize:
                                (MediaQuery.of(context).size.width * 0.042)))
                    : Text('',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize:
                                (MediaQuery.of(context).size.width * 0.042)))),
            Container(
                margin: EdgeInsets.fromLTRB(
                    0, 0, 0, MediaQuery.of(context).size.height * 0.035),
                child: AccentButton(
                  [
                    (MediaQuery.of(context).size.width * 0.8).toDouble(),
                    (MediaQuery.of(context).size.height * 0.062).toDouble()
                  ],
                  'Join Listen Together',
                  () => join(idController.text),
                )),
          ],
        )));
  }
}
