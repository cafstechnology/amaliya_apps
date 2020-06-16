import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:android_intent/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';

class WorkerStartSplPage extends StatefulWidget {
  final String taskid;
  final String latitude;
  final String longitude;

  const WorkerStartSplPage(
      {Key key, this.taskid, this.latitude, this.longitude})
      : super(key: key);
  @override
  _WorkerStartSplPageState createState() =>
      _WorkerStartSplPageState(taskid, latitude, longitude);
}

class _WorkerStartSplPageState extends State<WorkerStartSplPage> {
  List<Step> steps;

  _WorkerStartSplPageState(String taskid, String lat, String long);
  @override
  void initState() {
    getCurrentLoc();
    super.initState();
  }

  String status = '';
  int currentStep = 0;
  bool complete = false;
  bool isValidate = false;
  StepState stepState = StepState.editing;
  File _imageSelfie;
  File _imageBefore;
  String errMessage = 'Kesalahan dalam Mengunggah Gambar';
  Uint8List _imageBeforeBytes;
  String base64ImageBefore;
  String base64ImageSelfie;
  bool isValid = false;
  goto(int step) {
    setState(() {
      currentStep = step;
    });
  }

  next() {
    currentStep + 1 != steps.length
        ? goto(currentStep + 1)
        : setState(() {
            complete = true;
          });
  }

  cancel() {
    if (currentStep > 0) {
      goto(currentStep - 1);
    }
  }

  bool isEnable = false;
  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      setState(() {
        isEnable = false;
      });
    } else {
      setState(() {
        isEnable = true;
      });
    }
  }

  checkLoc() async {
    bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
    print(isLocationEnabled);
    if (isLocationEnabled) {
      getCurrentLoc();
      double distanceInMeters = await Geolocator().distanceBetween(
          _currentLoc.latitude,
          _currentLoc.longitude,
          double.parse(widget.latitude),
          double.parse(widget.longitude));
      if (distanceInMeters <= 500) {
        isValid = true;
      } else {
        isValid = false;
      }

      if (isValid) {
        startUpload();
      } else {
        _showDialog("Peringatan",
            "Lokasi anda terlalu jauh dengan lokasi pengerjaan, silahkan mendekat dan coba lagi");
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Tidak bisa mendapatkan lokasi saat ini"),
            content: const Text('Pastikan Anda mengaktifkan GPS dan coba lagi'),
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

  startUpload() {
    setStatus('Uploading Image...');

    String fileNameBefore = "";
    if (_imageBefore != null) {
      fileNameBefore = _imageBefore.path.split('/').last;
    }

    String fileNameSelfie = "";
    if (_imageSelfie != null) {
      fileNameSelfie = _imageSelfie.path.split('/').last;
    }

    upload(fileNameBefore, fileNameSelfie);
  }

  upload(String fileNameBefore, String fileNameSelfie) async {
    try {
      String uploadEndPoint = AppConfig.API +
          "v1/worker/overtime/" +
          widget.taskid.toString() +
          "/start";
      print(uploadEndPoint);
      FormData formData = new FormData.fromMap({
        "imageBefore": base64ImageBefore,
        "imageSelfie": base64ImageSelfie,
      });
      Response response = await Dio().post(uploadEndPoint,
          data: formData,
          options: new Options(
              headers: {HttpHeaders.authorizationHeader: "Bearer " + token}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        setStatus(response.toString());

        setState(() {
          _imageBefore = null;
          _imageSelfie = null;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WorkerDashboard(
            index: 3,
            page: 3,
          );
        }));
        Future.delayed(
            Duration.zero,
            () => _showDialog('Informasi',
                'SPL dengan no : ' + widget.taskid.toString() + ' dimulai.'));
      } else {
        Navigator.of(context).pop();
        Future.delayed(
            Duration.zero, () => _showDialog('Kesalahan', 'Gagal  Mengunggah'));
      }
      setState(() {});
    } on DioError catch (e) {
      if (e.response.statusCode == 422) {
        _showDialog('Pemberitahuan',
            jsonDecode(e.response.toString())['message'].toString());

      } else {
        _showDialog(
            'Peringatan', 'Error : ' + e.response.statusMessage.toString());
      }
    }
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
    print("status : " + status);
  }

  void validate() {
    print("validate");
    if (_imageBefore != null && _imageSelfie != null) {
      isValidate = true;
    }
  }

  Position _currentLoc;
  getCurrentLoc() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentLoc = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> encodeBase64(File fileBefore, File fileSelfie) async {
    //encode image before
    if (fileBefore != null) {
      String _base64Before = base64Encode(fileBefore.readAsBytesSync());
      base64ImageBefore = "data:image/jpeg;base64," + _base64Before;
    } else {
      print("image kosong");
    }

    //encode image selfie
    if (fileSelfie != null) {
      String _base64Selfie = base64Encode(fileSelfie.readAsBytesSync());
      base64ImageSelfie = "data:image/jpeg;base64," + _base64Selfie;
    } else {
      print("image kosong");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(title),
            content: new Text(content),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Tutup"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  Widget _typeStep() => Container(
        margin: EdgeInsets.only(top: 10),
        constraints: BoxConstraints.expand(height: 200),
        //color: BLUE_LIGHT,
        child: Stepper(
          type: StepperType.horizontal,
          steps: steps = [
            Step(
              isActive: getActive(1),
              state: getState(1),
              title: Text("Langkah 1"),
              content: new Column(
                children: <Widget>[
                  new Center(
                    child: _imageSelfie == null
                        ? new Text('Ambil Photo Selfie')
                        : Image.file(_imageSelfie),
                  ),
                  new Center(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new FloatingActionButton(
                          foregroundColor: Colors.grey,
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            var _imageTmp = await ImagePicker.pickImage(
                                source: ImageSource.camera,
                                maxWidth: MediaQuery.of(context).size.width,
                                imageQuality: 100);
                            setState(() {
                              _imageSelfie = _imageTmp;
                            });
                          },
                          tooltip: 'Silahkan Ambil Photo',
                          child: Icon(Icons.add_a_photo),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Step(
              isActive: getActive(2),
              state: getState(2),
              title: Text("Langkah 2"),
              content: new Column(
                children: <Widget>[
                  new Center(
                    child: _imageBefore == null
                        ? new Text('Ambil Photo Sebelum Pengerjaan')
                        : Image.file(_imageBefore),
                  ),
                  new Center(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new FloatingActionButton(
                          foregroundColor: Colors.grey,
                          backgroundColor: Colors.white,
                          onPressed: () async {
                            var _imageTmp = await ImagePicker.pickImage(
                                source: ImageSource.camera,
                                maxWidth: MediaQuery.of(context).size.width,
                                imageQuality: 100);
                            setState(() {
                              _imageBefore = _imageTmp;
                              encodeBase64(_imageBefore, _imageSelfie);
                            });
                          },
                          tooltip: 'Silahkan Ambil Photo',
                          child: Icon(Icons.add_a_photo),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Step(
              isActive: false,
              state: getState(2),
              title: Text("Langkah 3"),
              content: new Column(
                children: <Widget>[
                  new Center(
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new FlatButton(
                          color: Colors.green,
                          onPressed: () {
                            validate();
                            if (!isValidate) {
                              _showDialog("Kesalahan",
                                  "Foto Selfie atau Sebelum Pengerjaan belum diambil");
                            } else {
                              checkLoc();
                            }
                          },
                          child: new Text("Mulai Tugas"),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
          currentStep: currentStep,
          onStepTapped: (step) => goto(step),
          onStepContinue: next,
          onStepCancel: cancel,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                "Mulai Tugas",
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
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: _typeStep(),
          ),
        ]));
  }

  StepState getState(int i) {
    if (currentStep >= i)
      return StepState.complete;
    else
      return StepState.indexed;
  }

  bool getActive(int i) {
    if (currentStep >= i)
      return true;
    else
      return false;
  }
}
