import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/flame.dart';
import 'package:flame/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:xlive_switch/xlive_switch.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'project-299241045837',
    options: const FirebaseOptions(
      googleAppID: '1:299241045837:android:89c533766a1ab46e128104',
      apiKey: 'AIzaSyBI6yfiC3fVHvLPSGkEIDzbCt1BppsA6d4',
      databaseURL: 'https://smart-home-iot-9c53c.firebaseio.com',
    ),
  );
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Home Automation',
    home: MyHomePage(app: app),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.app});

  final FirebaseApp app;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference motionLedRef;
  DatabaseReference normalLedRef;
  DatabaseReference tempRef;

  bool motion_led_state = true;
  bool normal_led_state = true;

  StreamSubscription<Event> motionsLedListener;
  StreamSubscription<Event> normalLedListener;
  StreamSubscription<Event> tempListener;

  StreamSubscription<Event> dataRef;

  var temp_value = "";
  DatabaseError _error;

  @override
  void initState() {
    super.initState();

    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);

    normalLedRef = database.reference().child('NORMAL_LED');
    motionLedRef = database.reference().child('MOTION_LED');
    tempRef = database.reference().child('TEMP');

    normalLedRef.keepSynced(true);
    motionLedRef.keepSynced(true);
    tempRef.keepSynced(true);

    motionsLedListener = motionLedRef.onValue.listen((Event event) {
      print(event.snapshot.value.toString());
      setState(() {
        this.motion_led_state = event.snapshot.value == 0 ? false : true;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
    });

    tempListener = tempRef.onValue.listen((Event event) {
      print(event.snapshot.value.toString());
      int temp = event.snapshot.value;
      if (temp > 50) {
        play();
        print('played!');
      }
      setState(() {
        this.temp_value = event.snapshot.value.toString() + "°";
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
    });

    normalLedListener = normalLedRef.onValue.listen((Event event) {
      print(event.snapshot.value.toString());
      setState(() {
        this.normal_led_state = event.snapshot.value == 0 ? false : true;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      print('Error: ${error.code} ${error.message}');
    });
  }

  @override
  void dispose() {
    super.dispose();
//    normalLedListener.cancel();
//    motionsLedListener.cancel();
  }

  Future<void> toggleNormalLed(bool state) async {
    normalLedRef.set(state ? 1 : 0);
  }

  Future<void> toggleMotionLed(bool state) async {
    motionLedRef.set(state ? 1 : 0);
  }

  Future<void> setTemp(var temp) async {
    tempRef.set(temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          elevation: 10,
          title: Text("Home Automation"),
          centerTitle: true),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 50, right: 16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 20,
            color: Colors.blueGrey[800],
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.cloud, color: Colors.white, size: 25),
                          SizedBox(
                            width: 20,
                          ),
                          Text("Temperature",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                      Text(temp_value,
                          style: TextStyle(fontSize: 20, color: Colors.white))
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Normal Led",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      getMotionSwitch()
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text("Motion Led",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      getNormalLedSwitch()
                    ],
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  SizedBox(
                    height: 18,
                  ),
//                  RaisedButton(
//                      color: Colors.blueGrey[700],
//                      child: Text("Toggle"),
//                      textColor: Colors.white,
//                      onPressed: () {
//                        setState(() {
//                          this.normal_led_state = !normal_led_state;
//                          this.motion_led_state = !motion_led_state;
//                          print(normal_led_state);
//                          print(motion_led_state);
//                        });
//                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getNormalLedSwitch() {
    return XlivSwitch(
      value: normal_led_state,
      onChanged: (bool state) {
        normal_led_state = state;
        toggleNormalLed(state);
      },
    );
  }

  Widget getMotionSwitch() {
    return XlivSwitch(
      value: motion_led_state,
      onChanged: (bool state) {
        motion_led_state = state;
        toggleMotionLed(state);
      },
    );
  }

  void play() {
    // ignore: unnecessary_statements
    Flame.audio.audioCache.respectSilence = false;
    Flame.audio.playLongAudio('alarm.mp3');
  }



  static void addSoundName(String name, {int count = 1}) {
    for (var i = 0; i < count; i++) {
//      AudioPlayer.addSound('assets/' + name);
    }
  }

  static void removeAllSound() {
//    AudioPlayer.removeAllSound();
  }
}
