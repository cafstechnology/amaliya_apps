import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

//final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  final LoginStatus loginStatus;

  LoginPage(this.loginStatus);
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user = null;
  String uid = "";
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String email, password;
  String errorMessage = '';
  String successMessage = '';
  //final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  bool _secureText = true;
  bool _isInAsyncCall = false;
  final _key = new GlobalKey<FormState>();
  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _isInAsyncCall = true;
      });
      login();
    }
  }

  // user defined function
  _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Login Gagal"),
          content: new Text("Email atau Password Salah!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> signIn(String email, String password) async {
    try {
      user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      setState(() {
        uid = user.uid;
      });

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);
      return uid;
    } catch (e) {
      handleError(e, email, password);
      return null;
    }
  }

  Future<bool> googleSignout() async {
    await auth.signOut();
    return true;
  }

  Future<String> handleSignUp(email, password, imageUrl) async {
    AuthResult result = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    final FirebaseUser user = result.user;
    setState(() {
      uid = user.uid;
    });

    Firestore.instance.collection("users").document(uid).setData({
      "chattingWith": "",
      "pushToken": "",
      "searchKey": emailInputController.text.toString().substring(0, 1),
      "uid": uid,
      "email": emailInputController.text,
      "imageUrl": AppConfig.SERVER + imageUrl,
    });
    assert(user != null);
    assert(await user.getIdToken() != null);

    return uid;
  }

  handleError(PlatformException error, String emails, String passwords) {
    print(error);
    switch (error.code) {
      case 'ERROR_USER_NOT_FOUND':
        setState(() {
          errorMessage = 'User Not Found!!!';
        });
        break;
      case 'ERROR_WRONG_PASSWORD':
        setState(() {
          errorMessage = 'Wrong Password!!!';
        });
        break;
    }
  }

  login() async {
    String loginApi = AppConfig.API + "login";
    String token = "";
    String name = "";
    String email = "";
    String gender = "";
    String edu = "";
    String phone = "";
    String imgPP = "";
    try {
      FormData formData = new FormData.fromMap({
        "email": emailInputController.text.toString(),
        "password": pwdInputController.text.toString(),
      });

      Response response = await Dio().post(loginApi, data: formData);
      if (response.statusCode == 200) {
        token = jsonDecode(response.toString())['token'];
        Response responseDetail = await Dio().get(
          AppConfig.API + "v1/profile",
          options: new Options(
              headers: {HttpHeaders.authorizationHeader: "Bearer " + token}),
        );
        if (responseDetail.statusCode == 200) {
          name = jsonDecode(responseDetail.toString())['name'];
          email = jsonDecode(responseDetail.toString())['email'];
          phone = jsonDecode(responseDetail.toString())['phone'];
          gender = jsonDecode(responseDetail.toString())['gender'];
          edu = jsonDecode(responseDetail.toString())['lastEducation'];
          imgPP = jsonDecode(responseDetail.toString())['imageProfile'];

          uid = await signIn(emailInputController.text.toString(),
              "B@ndung123");

          if (uid == null) {
            uid = await handleSignUp(emailInputController.text.toString(),
                "B@ndung123", imgPP);
          }
          setState(() {
            _loginStatus = LoginStatus.signIn;
            savePref(token, name, email, phone, gender, edu, imgPP, uid);
          });
        } else {
          _showDialog();
        }
      } else {
        _showDialog();
      }
    } catch (e) {
      _showDialog();
      print(e);
    }
    // stop the modal progress HUD
    _isInAsyncCall = false;
  }

  savePref(String token, String name, String email, String phone, String gender,
      String edu, String image, String uuid) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setString("token", token);
      preferences.setString("name", name);
      preferences.setString("email", email);
      preferences.setString("phone", phone);
      preferences.setString("gender", gender);
      preferences.setString("edu", edu);
      preferences.setString("imgPP", image);
      preferences.setString("uuid", uuid);
      preferences.commit();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getString("id");
      print("get pref before: " +
          _loginStatus.toString() +
          " " +
          value.toString());
      _loginStatus = value != null ? LoginStatus.signIn : LoginStatus.notSignIn;
      print("get pref after: " + _loginStatus.toString());
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.clear();
      //preferences.setString("id", "");
      //preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    super.initState();
    getPref();
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  Widget loginForm(BuildContext context) {
    return Form(
      key: _key,
      child: Column(
        children: <Widget>[
          Image.asset(
            'assets/images/logo-alphabet-amaliya.png',
            height: 130.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 120),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 1.2,
            child: TextFormField(
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white),
              controller: emailInputController,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              onSaved: (e) => email = e,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat Email anda',
                hintStyle: TextStyle(fontSize: 16, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(80),
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.solid,
                  ),
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                fillColor: Color.fromRGBO(20, 136, 204, 1),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width / 1.2,
            child: TextFormField(
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white),
              obscureText: _secureText,
              onSaved: (e) => password = e,
              decoration: InputDecoration(
                  hintText: 'Masukkan Password',
                  hintStyle: TextStyle(fontSize: 16, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(80),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.solid,
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.only(left: 16),
                  fillColor: Color.fromRGBO(20, 136, 204, 1),
                  suffixIcon: IconButton(
                    onPressed: showHide,
                    icon: Icon(
                        _secureText ? Icons.visibility_off : Icons.visibility),
                  )),
              controller: pwdInputController,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 40),
          ),
          RaisedButton(
            onPressed: //check()
                () async {
              if (_key.currentState.validate()) {
                check();
              }
            },
            textColor: Colors.white,
            padding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.0)),
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width / 4,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Color.fromRGBO(20, 136, 204, 1),
                      Color.fromRGBO(43, 50, 178, 1),
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(100.0))),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: const Text('Masuk', style: TextStyle(fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget buildLogin(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () => SystemNavigator.pop(),
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          resizeToAvoidBottomPadding: true,
          body: Stack(
            children: <Widget>[
              Center(
                child: new Container(
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/images/background2.jpg'))),
                ),
              ),
              Center(
                child: ModalProgressHUD(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: loginForm(context),
                      ),
                    ),
                  ),
                  inAsyncCall: _isInAsyncCall,
                  opacity: 0.5,
                  progressIndicator: CircularProgressIndicator(),
                ),
              )
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return buildLogin(context);
        break;
      case LoginStatus.signIn:
        return WorkerDashboard(
          index: 0,
          page: 0,
        );
    }
  }
}
