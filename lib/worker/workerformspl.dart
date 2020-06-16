import 'dart:convert';
import 'dart:io';

import 'package:amaliya/helper/config.dart';
import 'package:amaliya/helper/dummyData.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:amaliya/worker/workerspl.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerFormSpl extends StatefulWidget {
  _WorkerFormSplState createState() => _WorkerFormSplState();
}

class _WorkerFormSplState extends State<WorkerFormSpl> {
  TextEditingController deskripsiCtr;
  TextEditingController startDateCtr;
  TextEditingController endDateCtr;
  TextEditingController startTimeCtr;
  TextEditingController endTimeCtr;
  String _currentCustomer;
  String _currentLocation;
  String _currentCategory;
  String _currentManager;
  String _currentSpv;
  List<DropdownMenuItem<String>> _dropDownMenuCustomer = new List();
  List<DropdownMenuItem<String>> _dropDownMenuLocation = new List();
  List<DropdownMenuItem<String>> _dropDownMenuCategory = new List();
  List<DropdownMenuItem<String>> _dropDownMenuManager = new List();
  List<DropdownMenuItem<String>> _dropDownMenuSpv = new List();
  bool _create = false;
  String splToken = "";
  @override
  void initState() {
    getPref();
    Future.delayed(new Duration(seconds: 1), () {
      getSpv();
      getCustomer();
      getLocation();
      getCategory();
    });
    deskripsiCtr = TextEditingController();
    startDateCtr = TextEditingController();
    endDateCtr = TextEditingController();
    startTimeCtr = TextEditingController();
    endTimeCtr = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    deskripsiCtr.dispose();
    startDateCtr.dispose();
    endDateCtr.dispose();
    startTimeCtr.dispose();
    endTimeCtr.dispose();
    super.dispose();
  }

  createSPl(
      String description,
      String startDate,
      String startTime,
      String endDate,
      String endTime,
      int customerId,
      int locationId,
      int taskCategoryId,
      int managerId,
      int supervisorId) async {
    try {
      String createEndPoint = AppConfig.API + "v1/worker/overtime/create";

      FormData formData = new FormData.fromMap({
        "description": description,
        "startDate": startDate,
        "startTime": startTime,
        "endDate": endDate,
        "endTime": endTime,
        "customerId": customerId,
        "locationId": locationId,
        "taskCategoryId": taskCategoryId,
        "managerId": managerId,
        "supervisorId": supervisorId,
      });
     
      Response response = await Dio().post(createEndPoint,
          data: formData,
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + splToken
          }));

      if (response.statusCode == 200) {
        setState(() {
          _create = true;
        });
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WorkerDashboard(index: 3, page: 3,);
        }));

        Future.delayed(
            Duration.zero,
            () => _showDialog('Pemberitahuan',
                'SPL Sudah Diajukan dan Menunggu Persetujuan'));
      } else {
        _create = true;
        Navigator.of(context).pop();
        Future.delayed(
            Duration.zero, () => _showDialog('Kesalahan', 'Gagal Membuat SPL'));
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

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      splToken = preferences.getString("token");
    });
  }

  Future<List> getSpv() async {
    try {
      Response responseSpv = await Dio().get(
          AppConfig.API + "v1/get-supervisor",
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + splToken
          }));
      print(responseSpv.data.toString());
      for (int i = 0; i < responseSpv.data.length; i++) {
        print('value : ' + responseSpv.data[i]['id'].toString());
        _dropDownMenuSpv.add(new DropdownMenuItem(
            value: responseSpv.data[i]['id'].toString(),
            child: new Text(responseSpv.data[i]['name'].toString())));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List> getCustomer() async {
    try {
      Response responseCust = await Dio().get(AppConfig.API + "v1/get-customer",
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + splToken
          }));
      for (int i = 0; i < responseCust.data.length; i++) {
        _dropDownMenuCustomer.add(new DropdownMenuItem(
            value: responseCust.data[i]['id'].toString(),
            child: new Text(responseCust.data[i]['name'].toString())));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List> getLocation() async {
    try {
      Response responseLocation = await Dio().get(
          AppConfig.API + "v1/get-location",
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + splToken
          }));
      for (int i = 0; i < responseLocation.data.length; i++) {
        _dropDownMenuLocation.add(new DropdownMenuItem(
            value: responseLocation.data[i]['id'].toString(),
            child: new Text(responseLocation.data[i]['name'].toString())));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List> getCategory() async {
    try {
      Response responseCategory = await Dio().get(
          AppConfig.API + "v1/get-task-category",
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + splToken
          }));
      for (int i = 0; i < responseCategory.data.length; i++) {
        _dropDownMenuCategory.add(new DropdownMenuItem(
            value: responseCategory.data[i]['id'].toString(),
            child: new Text(responseCategory.data[i]['name'].toString())));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<List> getManager(String custId) async {
    try {
      Response responseManager = await Dio().get(
          AppConfig.API + "v1/get-manager?customerId=" + custId,
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + splToken
          }));

      for (int i = 0; i < responseManager.data.length; i++) {
        _dropDownMenuManager.add(new DropdownMenuItem(
            value: responseManager.data[i]['id'].toString(),
            child: new Text(responseManager.data[i]['name'].toString())));
      }
    } catch (e) {
      print(e);
    }
  }

  void startTimeSelect() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    DateTime date = DateFormat.jm().parse(picked.format(context));

    setState(() {
      startTimeCtr.text = DateFormat("HH:mm").format(date);
    });
  }

  void endTimeSelect() async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child,
        );
      },
    );
    DateTime date = DateFormat.jm().parse(picked.format(context));

    setState(() {
      endTimeCtr.text = DateFormat("HH:mm").format(date);
    });
  }

  Widget _buildWidget() {
    return new Form(
      child: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width / 1,
                padding: EdgeInsets.only(bottom: 10, top: 10, left: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: deskripsiCtr,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                      ),
                    ),
                    TextFormField(
                      controller: startDateCtr,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Dimulai',
                      ),
                      onTap: () async {
                        var datePicked = await DatePicker.showSimpleDatePicker(
                          context,
                          initialDate: DateTime.now(),//DateTime(2020),
                          firstDate: DateTime(1960),
                          dateFormat: "dd-MMMM-yyyy",
                          locale: DateTimePickerLocale.en_us,
                        );
                        setState(() {
                          final DateFormat df = new DateFormat('yyyy-MM-dd');
                          startDateCtr.text = df.format(datePicked);
                        });
                      },
                    ),
                    TextFormField(
                      controller: startTimeCtr,
                      decoration: InputDecoration(
                        labelText: 'Jam Dimulai',
                      ),
                      onTap: () async {
                        startTimeSelect();
                      },
                    ),
                    TextFormField(
                      controller: endDateCtr,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Selesai',
                      ),
                      onTap: () async {
                        var datePicked = await DatePicker.showSimpleDatePicker(
                          context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1960),
                          dateFormat: "dd-MMMM-yyyy",
                          locale: DateTimePickerLocale.en_us,
                        );
                        setState(() {
                          final DateFormat df = new DateFormat('yyyy-MM-dd');
                          endDateCtr.text = df.format(datePicked);
                        });
                      },
                    ),
                    TextFormField(
                      controller: endTimeCtr,
                      decoration: InputDecoration(
                        labelText: 'Jam Selesai',
                      ),
                      onTap: () async {
                        endTimeSelect();
                      },
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Customer",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.all(1.0),
                          ),
                          DropdownButton(
                            value: _currentCustomer,
                            items: _dropDownMenuCustomer,
                            onChanged: (value) {
                              setState(() {
                                _dropDownMenuManager = new List();
                                _currentCustomer = value;
                                getManager(_currentCustomer);
                              });
                            },
                          ),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Lokasi",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.all(1.0),
                          ),
                          DropdownButton(
                            value: _currentLocation,
                            items: _dropDownMenuLocation,
                            onChanged: (value) {
                              setState(() {
                                _currentLocation = value;
                              });
                            },
                          ),
                        ]),
                        Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Kategori",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.all(1.0),
                          ),
                          DropdownButton(
                            value: _currentCategory,
                            items: _dropDownMenuCategory,
                            onChanged: (value) {
                              setState(() {
                                _currentCategory = value;
                              });
                            },
                          ),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Manager",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.all(1.0),
                          ),
                          DropdownButton(
                            value: _currentManager,
                            items: _dropDownMenuManager,
                            onChanged: (value) {
                              setState(() {
                                _currentManager = value;
                              });
                            },
                          ),
                        ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Supervisor",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          Container(
                            padding: EdgeInsets.all(1.0),
                          ),
                          DropdownButton(
                            value: _currentSpv,
                            items: _dropDownMenuSpv,
                            onChanged: (value) {
                              setState(() {
                                _currentSpv = value;
                              });
                            },
                          ),
                        ]),
                    Padding(
                      padding: EdgeInsets.only(bottom: 25),
                    ),
                    RaisedButton(
                      onPressed: () {
                        createSPl(
                            deskripsiCtr.text,
                            startDateCtr.text,
                            startTimeCtr.text,
                            endDateCtr.text,
                            endTimeCtr.text,
                            int.parse(_currentCustomer),
                            int.parse(_currentLocation),
                            int.parse(_currentCategory),
                            int.parse(_currentManager),
                            int.parse(_currentSpv));
                      },
                      textColor: Colors.white,
                      padding: const EdgeInsets.all(0.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 1.7,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                Color.fromRGBO(0, 4, 40, 1),
                                Color.fromRGBO(0, 78, 146, 1),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(80.0))),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: const Text('Ajukan SPL',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget build(BuildContext context) {
    final _appBar = AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Form Pengajuan Lembur",
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

    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
        appBar: _appBar,
        body: ModalProgressHUD(
          child: _buildWidget(),
          inAsyncCall: _create,
        ));
  }
}
