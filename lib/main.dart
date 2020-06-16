import 'dart:convert';
import 'dart:io';

import 'package:amaliya/helper/chat.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/splashscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:amaliya/worker/workerstarttask.dart';
import 'package:amaliya/worker/workertaskdone.dart';
import 'package:amaliya/worker/workertasklist.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/login.dart';

void main() => runApp(MyApp());

//recommit for pipeline
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  String currentUserId;
  final FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
    getCurrent();
    registerNotification();
    configLocalNotification();
    //new NotificationHandler().initializeFcmNotification();
  }

  getCurrent() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = preferences.getString("uuid");
    });
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification'], message['data']);

      //return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      runApp(MaterialApp(
        home: ChatScreen(
          peerAvatar: AppConfig.SERVER + imgPP,
          peerId: message['data']['peer_id'].toString(),
        ),
      ));

      //return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      runApp(MaterialApp(
        home: ChatScreen(
          peerAvatar: AppConfig.SERVER + imgPP,
          peerId: message['data']['peer_id'].toString(),
        ),
      ));
      //return;
    });
/**
    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(currentUserId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
    **/
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amaliya',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/Login': (BuildContext context) =>
            new LoginPage(LoginStatus.notSignIn),
        '/WorkerDashboard': (BuildContext context) => new WorkerDashboard(),
        '/WorkerTaskList': (BuildContext context) => new WorkerTaskList(),
        '/WorkerTaskDone': (BuildContext context) => new WorkerTaskDone(),
        '/WorkerStartTask': (BuildContext context) => new WorkerStartTaskPage(),
      },
    );
  }
}
