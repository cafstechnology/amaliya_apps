import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amaliya/login/login.dart';
import 'dart:async';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  DatabaseReference mDB;
  Query _lastVersion;
  String FirebaseVersion;

  @override
  void initState() {
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
    super.initState();
    //setTimerHandler();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light));
    return Scaffold(
        body: Container(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/images/splash.gif',
          fit: BoxFit.fill,
          //width: MediaQuery.of(context).size.width * 0.4,
        ),
      ),
    ));
  }

  setTimerHandler() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, () {
      versionCheck(context);
    });
  }

  versionCheck(context) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    mDB = FirebaseDatabase.instance.reference();
    _lastVersion = mDB.child("/_serverVersion/");
    _lastVersion.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      values.forEach((key, values) {
        FirebaseVersion = values.toString();
        // Compare Run
        if (info.version.toString() != FirebaseVersion.toString()) {
          print(info.version.toString() +
              " VERSUS " +
              FirebaseVersion.toString());
         _showVersionDialog(context);
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
            return LoginPage(LoginStatus.notSignIn);
          }));
        }
      });
    });
    //Get Current installed version of app
  }

  // _cekLoginUser(context) {
  //   var duration = Duration(seconds: 2);
  //   return Timer(
  //       duration, () {
  //     Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  //     prefs.then((value){
  //       print(value.getString(SessionClass.IDUSER));
  //       if(value.getString(SessionClass.IDUSER) != null){
  //         Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(builder: (_){
  //               return HomeScreen();
  //             })
  //         );
  //       } else{
  //         Navigator.of(context).pushReplacement(
  //             MaterialPageRoute(builder: (_){
  //               return LoginPage(auth: new Auth());
  //             })
  //         );
  //       }
  //     });
  //   });
  // }
  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message = "There is a newer version of app";
        String btnLabel = "UPDATE NOW";
        String btnLabelCancel = "Later";

        return new AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            content: new Padding(
              padding: EdgeInsets.only(top: 200),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(""),
                  SizedBox(
                    height: 20.0,
                  ),
                  new Container(
                    color: Colors.blue,
                    child: new FlatButton(
                        onPressed: () {
                          
                          _launchPlayStore();
                        },
                        child: Text(
                          btnLabel,
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )),
                  ),
                ],
              ),
            ));
      },
    );
  }
}

_launchPlayStore() async {
  print("masuk");
  const url =
      'https://play.google.com/store/apps/details?id=technology.cafs.amaliya'; //nanti ganti ke amaliya
  launch(url);
}
//_launchPlayStore() async { const url = 'https://play.google.com/store/apps/details?id=technology.cafs.mba'; launch(url); }
