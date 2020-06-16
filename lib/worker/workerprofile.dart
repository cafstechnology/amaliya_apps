import 'dart:convert';
import 'dart:io';

import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WorkerProfile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _WorkerProfileState();
  }
}

class _WorkerProfileState extends State<WorkerProfile> {
  final phoneController = TextEditingController();
  String workerName, workerEmail, workerPhone, workerImage, imgProfile;
    File _imageProfile;
    String base64ImageBProfile;
  Image ppic;
  initState() {
    super.initState();
    //imageCache.clear();
    phoneController.text = phone;
    Future.delayed(new Duration(seconds: 1), () {
      generateImage();
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void updateProfile() async {
    FormData formData = new FormData.fromMap({
      "imageProfile": base64ImageBProfile,
      "phone": phoneController.text.toString(),
    });
    Response response = await Dio().post(AppConfig.API + "v1/profile/update",
        data: formData,
        options: new Options(
            headers: {HttpHeaders.authorizationHeader: "Bearer " + token}));
    if (response.statusCode == 200) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        return WorkerDashboard(
          index: 0,
          page: 0,
        );
      }));
      _showDialog("Berhasil", "Memperbarui Profil Berhasil");
    } else {
      _showDialog("Gagal", "Memperbarui Profile Gagal");
    }
  }

  _showDialog(String title, String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Tutup"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  generateImage() async {
    try {
      Response response = await Dio().get(AppConfig.SERVER + imgPP);

      if (response.statusCode == 200) {
        setState(() {
          imageCache.clear();
          ppic = new Image.network(AppConfig.SERVER + imgPP);
        });
      }
    } catch (e) {
      setState(() {
        imageCache.clear();
        ppic = new Image.asset("assets/images/default-profile.jpg");
      });
    }
  }

  Future getImage(src) async {
    //var image = await ImagePicker.pickImage(source: src);
    var image = await ImagePicker.pickImage(
        source: src,
        maxWidth: MediaQuery.of(context).size.width,
        imageQuality: 100);
    if (image != null) {
      setState(() {
        ppic = new Image.file(image);
        _imageProfile = image;
        String _base64 = base64Encode(_imageProfile.readAsBytesSync());
        base64ImageBProfile = "data:image/jpeg;base64," + _base64;
      });
    }
  }

  Future<void> _optionsDialogBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.add_a_photo,
                              color: Colors.grey[400],
                              size: 25,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            new Text('Camera'),
                          ],
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      getImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.image,
                              color: Colors.grey[400],
                              size: 25,
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            new Text('Gallery'),
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(
      centerTitle: true,
      title: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Profil Pekerja",
            style: TextStyle(color: Colors.white),
          )),
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
    );

    return new Scaffold(
      appBar: _appBar,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 150.0,
                  height: 150.0,
                  child: GestureDetector(
                    onTap: () {
                      _optionsDialogBox();
                    },
                    child: ClipOval(
                        child: ppic == null
                            ? new CircularProgressIndicator()
                            : ppic),
                  )),
              Text(
                name,
                style: TextStyle(fontFamily: 'SourceSansPro', fontSize: 25),
              ),
              SizedBox(
                height: 20.0,
                width: 200,
                child: Divider(
                  color: Color.fromRGBO(0, 4, 40, 1),
                ),
              ),
              Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Color.fromRGBO(0, 4, 40, 1),
                  ),
                  title: TextField(
                    controller: phoneController,
                    style: TextStyle(fontFamily: 'BalooBhai', fontSize: 20.0),
                  ),
                ),
              ),
              Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.mail,
                    color: Color.fromRGBO(0, 4, 40, 1),
                  ),
                  title: Text(
                    email,
                    style: TextStyle(fontSize: 20.0, fontFamily: 'Neucha'),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: //check()
                    () async {
                  updateProfile();
                },
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.0)),
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color.fromRGBO(0, 4, 40, 1),
                          Color.fromRGBO(0, 78, 146, 1),
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(80.0))),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: const Text('Memperbarui Profile',
                      style: TextStyle(fontSize: 20)),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
