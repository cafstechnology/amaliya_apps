import 'dart:convert';
import 'dart:io';

import 'package:amaliya/helper/chat.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerchatnew.dart';
import 'package:amaliya/worker/workerprofile.dart';
import 'package:amaliya/worker/workerspl.dart';
import 'package:android_intent/android_intent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:amaliya/worker/workercalendar.dart';
import 'package:amaliya/worker/workerhome.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerDashboard extends StatefulWidget {
  @override
  final int index;
  final int page;
  const WorkerDashboard({Key key, this.index, this.page}) : super(key: key);
  _WorkerDashboardState createState() => _WorkerDashboardState(index, page);
}

String token = "",
    email = "-",
    name = "-",
    phone = "-",
    gender = "-",
    edu = "-",
    imgPP = "-",
    uuid = "-";
final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    new FlutterLocalNotificationsPlugin();
List<Widget> _optionWidget = [];

class _WorkerDashboardState extends State<WorkerDashboard> {
  int index;
  int page;
  _WorkerDashboardState(this.index, this.page);
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString("email");
      name = preferences.getString("name");
      token = preferences.getString("token");
      imgPP = preferences.getString("imgPP");
      phone = preferences.getString("phone");
      uuid = preferences.getString("uuid");
    });
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      showNotification(message['notification'], message['data']);

      //return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      runApp(MaterialApp(
        home: message['data'] != null
            ? ChatScreen(
                peerAvatar: AppConfig.SERVER + imgPP,
                peerId: message['data']['peer_id'].toString(),
              )
            : WorkerDashboard(
                index: 0,
                page: 0,
              ),
      ));

      //return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      runApp(MaterialApp(
        home: message['data'] != null
            ? ChatScreen(
                peerAvatar: AppConfig.SERVER + imgPP,
                peerId: message['data']['peer_id'].toString(),
              )
            : WorkerDashboard(
                index: 0,
                page: 0,
              ),
      ));
      //return;
    });

    firebaseMessaging.getToken().then((_fcmToken) async {
      print('token: $_fcmToken');
      Firestore.instance
          .collection('users')
          .document(uuid)
          .updateData({'pushToken': _fcmToken});
      //update user fcm token
      FormData formData = new FormData.fromMap({"token": _fcmToken});
      Response response = await Dio().post(
          AppConfig.API + "v1/update-fcm-token",
          data: formData,
          options: new Options(
              headers: {HttpHeaders.authorizationHeader: "Bearer " + token}));
      if (response.statusCode == 200) {
        print(response.statusMessage);
      } else {
        print(response.statusMessage);
      }
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message, data) async {
    print("data : " + data["peer_id"].toString());
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid
          ? 'technology.cafs.amaliya'
          : 'technology.cafs.amaliya',
      'Amaliya Chat Apps',
      'worker channel',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Tidak bisa mendapatkan lokasi saat ini"),
              content:
                  const Text('Pastikan Anda mengaktifkan GPS dan coba lagi'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    final AndroidIntent intent = AndroidIntent(
                        action: 'android.settings.LOCATION_SOURCE_SETTINGS');

                    intent.launch();
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    imageCache.clear();
    _checkGps();
    Future.delayed(new Duration(seconds: 5), () {
      getPref();
      registerNotification();
      configLocalNotification();
    });

    _optionWidget = <Widget>[
      WorkerHome(),
      WorkerCalendar(),
      WorkerChat(),
      WorkerSpl()
    ];

    //countTaskRemain();
    //countTaskDone();
  }

  GlobalKey _bottomNavigationKey = GlobalKey();

  Widget _buildStories({Widget body}) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                    Color.fromRGBO(0, 4, 40, 1),
                    Color.fromRGBO(0, 78, 146, 1),
                  ])),
            ),
            automaticallyImplyLeading: false,
            title: Image.asset(
              'assets/images/logo-alphabet-amaliya.png',
              height: 45.0,
            ),
            actions: <Widget>[
              //_myAlert(),
              PopupMenuButton<ToolbarAction>(
                onSelected: _onSelectedToolbar,
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                ),
                itemBuilder: (BuildContext context) {
                  return action.skip(0).map((ToolbarAction action) {
                    return PopupMenuItem<ToolbarAction>(
                      value: action,
                      child: ListTile(
                        leading: Icon(action.icon),
                        title: Text(action.title,
                            style: Theme.of(context).textTheme.body1),
                      ),
                    );
                  }).toList();
                },
              )
            ]),
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: index,
          height: 50.0,
          items: <Widget>[
            Icon(Icons.home, size: 30, color: Colors.white),
            Icon(Icons.calendar_today, size: 30, color: Colors.white),
            Icon(Icons.message, size: 30, color: Colors.white),
            Icon(Icons.timer, size: 30, color: Colors.white)
          ],

          color: Color.fromRGBO(0, 4, 40, 1), //Background Bottom Navigation
          buttonBackgroundColor:
              Color.fromRGBO(0, 78, 146, 1), //selected button
          backgroundColor: Colors.transparent, //Color(0xFFFFFFFF), // Curve Color
          animationCurve: Curves.easeOut,
          animationDuration: Duration(milliseconds: 400),
          onTap: (index) {
            setState(() {
              page = index;
            });
          },
        ),
        body: SafeArea(
          child: Container(
              child: Stack(
            children: <Widget>[
              Padding(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                        image: AssetImage('assets/images/background_bot.jpg'),
                        fit: BoxFit.cover),
                  ),
                  child: bodyContainer(uuid),
                ),
                padding: EdgeInsets.only(bottom: 0),
              ),
            ],
          )),
        ));
  }

  _onSelectedToolbar(ToolbarAction action) {
    switch (action.title) {
      case "Pengaturan":
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WorkerProfile();
        }));
        return true;
      case "Keluar":
        _showDialog();
        return true;
      default:
        return true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildContent() {
    return _buildStories();
  }

  @override
  Widget build(BuildContext context) {
    // Build the content depending on the state:
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: _buildContent(),
    );
  }

  bodyContainer(String userid) {
    switch (page) {
      case 0:
        new WorkerHome();
        break;
      case 1:
        new WorkerCalendar();
        break;

      case 2:
        new WorkerChat();
        break;
      case 3:
        new WorkerSpl();
        break;
    }
    return GestureDetector(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: _optionWidget.elementAt(page),
      ),
      onTap: () {
        page++;
      },
    );
  }

  Widget _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Peringatan"),
            content: Text("Anda Yakin Ingin Keluar?"),
            actions: <Widget>[
              new FlatButton.icon(
                  onPressed: () {
                    logOut();
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.red,
                  ),
                  label: Text("Keluar", style: TextStyle(color: Colors.red)))
            ],
          );
        });
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("id", null);
      preferences.commit();

      Navigator.pushReplacementNamed(context, '/Login');
    });
  }
}

class ToolbarAction {
  const ToolbarAction({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<ToolbarAction> action = const <ToolbarAction>[
  const ToolbarAction(title: "Pengaturan", icon: Icons.settings),
  const ToolbarAction(title: "Keluar", icon: Icons.exit_to_app),
];
