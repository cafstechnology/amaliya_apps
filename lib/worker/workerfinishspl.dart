import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';

class WorkerFinishSplPage extends StatefulWidget {
  final String taskid;

  const WorkerFinishSplPage({Key key, this.taskid}) : super(key: key);
  @override
  _WorkerFinishSplPageState createState() =>
      _WorkerFinishSplPageState(taskid);
}

class _WorkerFinishSplPageState extends State<WorkerFinishSplPage> {
  List<Step> steps;
  TextEditingController _remarksController;
  _WorkerFinishSplPageState(String taskid);
  @override
  void initState() {
    _remarksController = new TextEditingController();
    super.initState();
  }

  String status = '';
  int currentStep = 0;
  bool complete = false;
  bool isValidate = false;
  StepState stepState = StepState.editing;
  File _imageAfter;
  String errMessage = 'Kesalahan dalam Mengunggah Gambar';
  Uint8List _imageBeforeBytes;
  String base64ImageAfter;
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

  startUpload() {
    setStatus('Uploading Image...');
    //if (null == _imageBefore) {
    //setStatus(errMessage);
    //return;
    //}
    String fileNameAfter = "";
    String remarks = "";
    if (_imageAfter != null) {
      fileNameAfter = _imageAfter.path.split('/').last;
    }
    remarks = _remarksController.text.toString();
    print("Remarks : ${remarks}");
    upload(fileNameAfter, remarks);
  }

  upload(String fileNameAfter, String remarks) async {
    try {
      String uploadEndPoint = AppConfig.API +
          "v1/worker/overtime/" +
          widget.taskid.toString() +
          "/done";
      FormData formData = new FormData.fromMap({
        "imageAfter": base64ImageAfter,
        "remarks": remarks,
      });
      Response response = await Dio().post(uploadEndPoint,
          data: formData,
          options: new Options(
              headers: {HttpHeaders.authorizationHeader: "Bearer " + token}));
      print(response.statusCode);
      if (response.statusCode == 200) {
        setStatus(response.toString());
        setState(() {
          _imageAfter = null;
        });

        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WorkerDashboard(
            index: 3,
            page: 3,
          );
        }));

        Future.delayed(
            Duration.zero,
            () => _showDialog(
                'Pemberitahuan',
                'SPL dengan no : ' +
                    widget.taskid.toString() +
                    ' telah selesai.'));
      } else {
        Navigator.of(context).pop();
        Future.delayed(
            Duration.zero, () => _showDialog('Kesalahan', 'Gagal Mengunggah'));
      }
      setState(() {});
    } catch (e) {
      print("error " + e.toString());
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
    if (_imageAfter != null) {
      isValidate = true;
    }
  }

  Future<void> encodeBase64(File fileBefore) async {
    //encode image before
    if (fileBefore != null) {
      String _base64After = base64Encode(fileBefore.readAsBytesSync());
      base64ImageAfter = "data:image/jpeg;base64," + _base64After;
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
                    child: _imageAfter == null
                        ? new Text('Ambil Photo Setelah Pengerjaan')
                        : Image.file(_imageAfter),
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
                              _imageAfter = _imageTmp;
                              encodeBase64(_imageAfter);
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
              title: Text("Langkah 2"),
              content: new Column(
                children: <Widget>[
                  TextFormField(
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                      labelText: 'Catatan',
                      labelStyle: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'QBold'),
                    ),
                    controller: _remarksController,
                    keyboardType: TextInputType.text,
                  ),
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
                                  "Foto Sesudah pegerjaan belum diambil");
                            } else {
                              startUpload();
                            }
                          },
                          child: new Text("Selesaikan Tugas"),
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
          onStepContinue: next(),
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
                "Selesaikan Tugas",
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
