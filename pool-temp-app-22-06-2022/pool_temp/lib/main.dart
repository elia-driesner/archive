import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'dart:async';

import 'thermometer_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pool Temperature',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: const Color(0xFFFFFFFF)),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String temp = '0.0';
  String serverStatus = 'Verbinde';
  var waveColor = Color.fromARGB(255, 124, 124, 124).withOpacity(0.3);

  void getPoolTemp() async {
    try {
      final response = await http
          .get(Uri.parse('https://drmainserver.pagekite.me//poolTemp'));
      final decoded = json.decode(response.body) as Map<String, dynamic>;

      if (decoded['tC'] != '0.0') {
        setState(() {
          temp = decoded['tC'];
          serverStatus = 'Verbunden';
          waveColor = Colors.blueAccent.withOpacity(0.3);
        });
      } else {
        setState(() {
          serverStatus = 'Sensor Offline';
          waveColor = Color.fromARGB(255, 124, 124, 124).withOpacity(0.3);
        });
      }
    } catch (e) {
      if (temp != '0.0') {
        setState(() {
          serverStatus = 'Server Offline';
          waveColor = Color.fromARGB(255, 124, 124, 124).withOpacity(0.3);
        });
      } else {
        setState(() {
          temp = '0.0';
          serverStatus = 'Server Offline';
          waveColor = Color.fromARGB(255, 124, 124, 124).withOpacity(0.3);
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      getPoolTemp();
      Timer mytimer = Timer.periodic(Duration(seconds: 10), (timer) {
        getPoolTemp();
      });
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 300,
          child: WaveWidget(
            config: CustomConfig(
              colors: [
                waveColor, waveColor, waveColor,
                //the more colors here, the more wave will be
              ],
              durations: [10000, 9000, 80000],
              //durations of animations for each colors,
              // make numbers equal to numbers of colors
              heightPercentages: [0.01, 0.01, 0.03],
              //height percentage for each colors.
              blur: MaskFilter.blur(BlurStyle.solid, 5),
              //blur intensity for waves
            ),
            waveAmplitude: 5.00, //depth of curves
            waveFrequency: 3, //number of curves in waves
            backgroundColor: Colors.white, //background colors
            size: Size(
              double.infinity,
              double.infinity,
            ),
          ),
        ),
      ),
      Container(
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Center(
            child: CustomPaint(
              foregroundPainter: CircleProgress(double.parse(temp), true),
              child: Container(
                width: 200,
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Temperatur'),
                      Text(
                        '$temp',
                        style: TextStyle(
                            fontSize: 43, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '°C',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
              child: Column(
            children: [
              Text('Server Status:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              serverStatus == 'Verbunden'
                  ? Text(serverStatus,
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 105, 244, 110)))
                  : Text(serverStatus,
                      style: TextStyle(fontSize: 20, color: Colors.red))
            ],
          ))
        ]),
      ),
    ]));
  }
}
