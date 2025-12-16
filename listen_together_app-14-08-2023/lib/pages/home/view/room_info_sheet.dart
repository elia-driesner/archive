import 'package:flutter/material.dart';
import './../services/listener.dart';
import '../room_info.dart';

class RoomView {
  static bool hasInfo = false;
  static late var homeContext;

  static Map roomInfo = roomInfoVar;

  static void addInfo(setInfoState, info) {
    debugPrint(info.toString());
    setInfoState(() => {roomInfo = info, hasInfo = true});
  }

  static List<Widget> showListeners(context) {
    List<Widget> listenerWidgets = [];
    roomInfo['listeners'].forEach((listener) => {
          listenerWidgets.add(Container(
              margin: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.07,
                  0,
                  0,
                  MediaQuery.of(context).size.height * 0.006),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(listener,
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 18)),
              )))
        });
    return listenerWidgets;
  }

  static Widget showHost(context) {
    return Container(
        margin: EdgeInsets.fromLTRB(
            0, 0, MediaQuery.of(context).size.width * 0.07, 0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(roomInfo['host_name'],
              style: TextStyle(
                  color: Theme.of(context).primaryColorLight, fontSize: 18)),
        ));
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
              builder: (BuildContext context, StateSetter setInfoState) {
            SocketListener.initInfoSheet(setInfoState, addInfo);
            if (roomInfo != null) {
              setInfoState(() => hasInfo = true);
            }
            return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: hasInfo == true
                    ? SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0,
                              MediaQuery.of(context).size.height * 0.05, 0, 0),
                          child: Container(
                            margin: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width * 0.03,
                                0,
                                MediaQuery.of(context).size.width * 0.03,
                                0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        MediaQuery.of(context).size.height *
                                            0.01),
                                    child: Text(roomInfo['room_name'],
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .primaryColorLight,
                                            fontSize: 30))),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0,
                                                  0,
                                                  0,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              child: Text('Listeners',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                      fontSize: 23))),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: showListeners(context)),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0,
                                                  0,
                                                  0,
                                                  MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.01),
                                              child: Text('Host',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColorLight,
                                                      fontSize: 23))),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [showHost(context)]),
                                        ],
                                      ),
                                    ]),
                                Container(child: Row(children: [])),
                                Container(
                                    margin: EdgeInsets.fromLTRB(
                                        0,
                                        0,
                                        0,
                                        MediaQuery.of(context).size.height *
                                            0.05)),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 1, width: MediaQuery.of(context).size.width));
          });
        });
  }
}
