import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:amaliya/worker/workerstarttask.dart';
import 'package:geolocator/geolocator.dart';

import 'model/taskitem.dart';

var appBar = AppBar();
final _contollerTextEditing = TextEditingController();
ScrollController _scrollController;

class WorkerTaskList extends StatefulWidget {
  final String tw;
  WorkerTaskList({Key key, this.tw}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _WorkerTaskList(this.tw);
  }
}

List<TaskItem> list = [];
List<TaskItem> filteredList = [];
List<TaskItem> unfilteredList = [];

class _WorkerTaskList extends State<WorkerTaskList> {
  _WorkerTaskList(String tw);
  String urlApi = AppConfig.API + "v1/worker/get-schedule";
  Future<List> getListTask() async {
    try {
      list.clear();
      filteredList.clear();
      unfilteredList.clear();
      Response responseList = await Dio().post(urlApi,
          options: new Options(
              headers: {HttpHeaders.authorizationHeader: "Bearer " + widget.tw}));
      print(responseList.data.toString());
      for (int i = 0; i < responseList.data.length; i++) {
        TaskItem items = TaskItem(
          title: responseList.data[i]['taskCategoryName'].toString(),
          start: responseList.data[i]['startTime'].toString(),
          end: responseList.data[i]['endTime'].toString(),
          name: responseList.data[i]['name'].toString(),
          id: responseList.data[i]['id'].toString(),
          code: responseList.data[i]['code'].toString(),
          custname: responseList.data[i]['customerName'].toString(),
          date: responseList.data[i]['startDate'].toString(),
          workstatus: responseList.data[i]['workStatus'].toString(),
          desc: responseList.data[i]['description'].toString(),
          latitude: responseList.data[i]['latitude'].toString(),
          longitude: responseList.data[i]['longitude'].toString(),
          full_name: name,
          location: responseList.data[i]['locationName'].toString(),
        );

        if (items.workstatus == AppConfig.pending) {
          list.add(items);
          unfilteredList.add(items);
        }
        filteredList = list;
      }
    } catch (e) {
      print(e);
    }
    return filteredList;
  }

  postponeTask(String id, String code) async {
    try {
      Response response = await Dio().post(
          AppConfig.API + "v1/worker/schedule/$id/postpone",
          options: new Options(
              headers: {HttpHeaders.authorizationHeader: "Bearer " + token}));
      if (response.statusCode == 200) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
          return WorkerDashboard();
        }));
        Future.delayed(
            Duration.zero,
            () => _showDialog(
                'Pemberitahuann', 'Tugas dengan no : $code telah ditunda.'));
        print("Penundaan Tugas Sukses");
      } else {
        print("Penundaan Tugas Gagal");
      }
    } catch (e) {
      print(e);
    }
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

  Future _future;
  @override
  void initState() {
    super.initState();
    _future = getListTask();
  }

  @override
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
            "Daftar Tugas",
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFFFFFF),
      body: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
              child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      filterSearchResults(_contollerTextEditing.text);
                    });
                  },
                  controller: _contollerTextEditing,
                  decoration: InputDecoration(
                      labelText: "Cari Tugas Berdasarkan Nama",
                      hintText: "Cari Tugas Berdasarkan Nama",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0)))),
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: new FutureBuilder<List>(
                  future: _future,
                  // ignore: missing_return
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return filteredList.length == 0
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              controller: _scrollController,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                TaskItem items = filteredList[index];

                                return InkWell(
                                  child: Card(
                                      elevation: 0.0,
                                      color: Colors.transparent,
                                      margin: EdgeInsets.all(6.0),
                                      child: Stack(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.only(
                                              //top: Consts.avatarRadius + Consts.padding,
                                              bottom: Consts.padding,
                                              left: 3,
                                              right: 3,
                                            ),
                                            margin: EdgeInsets.only(top: 20),
                                            decoration: new BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Consts.padding),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 10.0,
                                                  offset:
                                                      const Offset(5.0, 5.0),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize
                                                  .max, // To make the card compact
                                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                              children: <Widget>[
                                                Container(
                                                  width: 140,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 20),
                                                        child: Text(
                                                          items.title,
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        items.start +
                                                            " Sampai " +
                                                            items.end,
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Text(
                                                        items.date,
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 20),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            items.name,
                                                            style: TextStyle(
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    'QBold'),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          items.desc,
                                                          style: TextStyle(
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'QBold'),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          items.custname,
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          items.location,
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      ButtonTheme(
                                                        child: new ButtonBar(
                                                          alignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            FlatButton(
                                                              color: Colors
                                                                  .redAccent,
                                                              child: const Text(
                                                                  'Tunda'),
                                                              shape: new RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          35.0)),
                                                              textColor:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                _showConfirm(
                                                                    items.id,
                                                                    items.code);
                                                              },
                                                            ),
                                                            FlatButton(
                                                              color: Colors
                                                                  .lightGreen,
                                                              child: const Text(
                                                                  'Mulai Tugas'),
                                                              shape: new RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      new BorderRadius
                                                                              .circular(
                                                                          35.0)),
                                                              textColor:
                                                                  Colors.white,
                                                              onPressed: () {
                                                                //Navigator.pushNamed(context, "/WorkerStartTask");
                                                                Navigator.of(
                                                                        context)
                                                                    .push(MaterialPageRoute(
                                                                        builder:
                                                                            (_) {
                                                                  return WorkerStartTaskPage(
                                                                    taskid:
                                                                        items
                                                                            .id,
                                                                    longitude: items
                                                                        .longitude,
                                                                    latitude: items
                                                                        .latitude,
                                                                  );
                                                                }));
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                              right: 10,
                                              top: 0,
                                              child: Row(
                                                children: <Widget>[
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 20, right: 0),
                                                      child: Text("DITUGASKAN",
                                                          style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 18,
                                                              fontFamily:
                                                                  'Lato',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold))),
                                                ],
                                              )),
                                        ],
                                      )),
                                );
                              },
                            );
                    } else {
                      return Center(
                        child: new CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ))
            ],
          ))),
    );
  }

  void _showConfirm(String id, String code) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text('Konfirmasi'),
              content: new Text(
                "Apakah Anda akan melakukan Penundaan untuk Tugas : $code ?",
                style: new TextStyle(fontSize: 30.0),
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      postponeTask(id, code);
                    },
                    child: new Text('Ya')),
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text('Tidak')),
              ],
            ));
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

  void filterSearchResults(String query) {
    var tmpList = new List<String>();
    List<TaskItem> dummySearchList = List<TaskItem>();
    dummySearchList.addAll(unfilteredList);
    if (query.isNotEmpty) {
      List<TaskItem> dummyListData = List<TaskItem>();
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        filteredList.clear();
        filteredList.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        print(unfilteredList.length.toString());
        filteredList.clear();
        filteredList.addAll(unfilteredList);
      });
    }
  }
}

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 46.0;
}
