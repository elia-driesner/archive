import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:listen_together_app/widgets/widgets.dart';
import 'package:listen_together_app/services/functions/functions.dart';
import 'package:websockets/websockets.dart';
import './../services/listener.dart';
import 'package:listen_together_app/services/data/storage.dart';

class CustomBottomSheet {
  static TextEditingController idController = TextEditingController();
  static double nameMargin = 0.05;
  static List<double> nameSize = [0.8, 0.1];

  static String errorMessage = '';
  static Widget? loadingIndicator;
  static String roomID = '';
  static bool shouldReloadTextField = true;

  static late var homeContext;

  static void moveName(setModalState) async {
    setModalState(() => {
          loadingIndicator = getLoadingIndicator(),
          nameMargin = 0.02,
          nameSize = [0.6, 0.09]
        });
  }

  static void moveNameBack(setModalState) async {
    setModalState(() => {
          loadingIndicator = null,
          nameMargin = 0.05,
          nameSize = [0.8, 0.1]
        });
  }

  static bool checkID(id) {
    List<String> allowedChars = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '0'
    ];
    if (id.length == 4) {
      for (int i = 0; i < 4; i++) {
        if (allowedChars.contains(id[i]) == false) {
          return false;
        }
      }
      Storage.saveData({'id': id.toString()}, 'lastUsedRoomID');
      return true;
    }
    return false;
  }

  static void start(setModalState, id) async {
    id = id.toString();
    if (checkID(id) == true) {
      moveName(setModalState);
      Future.delayed(const Duration(milliseconds: 1000));
      Websocket.channel.sink
          .add(jsonEncode({'request': 'start_listen_together', 'id': id}));
    } else {
      setModalState(
          () => {loadingIndicator = null, errorMessage = 'Invalid ID'});
    }
  }

  static void join(setModalState, id) async {
    id = id.toString();
    if (checkID(id) == true) {
      moveName(setModalState);
      Future.delayed(const Duration(milliseconds: 1000));
      Websocket.channel.sink
          .add(jsonEncode({'request': 'join_listen_together', 'id': id}));
    } else {
      setModalState(
          () => {loadingIndicator = null, errorMessage = 'Invalid ID'});
    }
  }

  static void showError(setModalState, message) {
    setModalState(() => {errorMessage = message, loadingIndicator = null});
  }

  static void setSheetLoadingIndicator(setModalState, state) {
    if (state == true) {
      setModalState(() => loadingIndicator = getLoadingIndicator());
    } else {
      setModalState(() => loadingIndicator = null);
    }
  }

  static void close() {
    shouldReloadTextField = true;
    Navigator.pop(homeContext);
  }

  static void setInitalValue(setModalState) {
    if (shouldReloadTextField == true) {
      var data = Storage.getData('lastUsedRoomID');
      if (data != null) {
        setModalState(() => idController.text = data['id']);
      }
      shouldReloadTextField = false;
    }
  }

  static Future build(BuildContext context) {
    homeContext = context;
    return showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Theme.of(context).primaryColorDark,
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            SocketListener.initSheet(
                showError, moveNameBack, setModalState, close);
            setInitalValue(setModalState);
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 120),
                      margin: EdgeInsets.fromLTRB(
                          0,
                          (MediaQuery.of(context).size.height * nameMargin),
                          0,
                          0),
                      child: AnimatedSize(
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 100),
                        child: BigInput(
                          size: [
                            (MediaQuery.of(context).size.width * nameSize[0])
                                .toDouble(),
                            (MediaQuery.of(context).size.height * nameSize[1])
                                .toDouble()
                          ],
                          text: "Room ID",
                          controller: idController,
                          obscureText: false,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    loadingIndicator == null
                        ? Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0,
                                MediaQuery.of(context).size.height * 0.01),
                            child: errorMessage != ''
                                ? Text(
                                    errorMessage,
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 18),
                                  )
                                : Text(
                                    '',
                                    style: TextStyle(fontSize: 18),
                                  ))
                        : Container(),
                    Container(
                      margin: EdgeInsets.fromLTRB(
                          0, 0, 0, MediaQuery.of(context).size.height * 0.05),
                      child: Column(
                        children: [
                          if (loadingIndicator == null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                    child: AccentButton(
                                      [
                                        (MediaQuery.of(context).size.width *
                                                0.4)
                                            .toDouble(),
                                        (MediaQuery.of(context).size.height *
                                                0.062)
                                            .toDouble()
                                      ],
                                      'Start',
                                      () => start(
                                          setModalState, idController.text),
                                    )),
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                        0,
                                        0,
                                        0),
                                    child: AccentButton(
                                      [
                                        (MediaQuery.of(context).size.width *
                                                0.4)
                                            .toDouble(),
                                        (MediaQuery.of(context).size.height *
                                                0.062)
                                            .toDouble()
                                      ],
                                      'Join',
                                      () => join(
                                          setModalState, idController.text),
                                    )),
                              ],
                            )
                          else
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: loadingIndicator)
                                ])
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
