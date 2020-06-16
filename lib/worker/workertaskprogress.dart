import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:amaliya/worker/workerfinishtask.dart';

import 'model/taskitem.dart';

var appBar = AppBar();
final _contollerTextEditing = TextEditingController();
ScrollController _scrollController;

class WorkerTaskProgress extends StatefulWidget {
  final String tw;
  WorkerTaskProgress({Key key, this.tw}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _WorkerTaskProgress(this.tw);
  }
}

List<TaskItem> list = [];
List<TaskItem> filteredList = [];
List<TaskItem> unfilteredList = [];

class _WorkerTaskProgress extends State<WorkerTaskProgress> {
  _WorkerTaskProgress(String tw);
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
          full_name: name,
          location: responseList.data[i]['locationName'].toString(),
        );

        if (items.workstatus == AppConfig.onprogress) {
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
            "Task Berlangsung",
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
      body: Container(
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
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Container(
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
                                                margin:
                                                    EdgeInsets.only(top: 20),
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
                                                      offset: const Offset(
                                                          5.0, 5.0),
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
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Text(
                                                                items.name,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontFamily:
                                                                        'QBold'),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
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
                                                            alignment: Alignment
                                                                .topLeft,
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
                                                            alignment: Alignment
                                                                .topLeft,
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
                                                            child:
                                                                new ButtonBar(
                                                              alignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <
                                                                  Widget>[
                                                                FlatButton(
                                                                  color: Colors
                                                                      .lightGreen,
                                                                  child: const Text(
                                                                      'Selesaikan Tugas'),
                                                                  shape: new RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          new BorderRadius.circular(
                                                                              35.0)),
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  onPressed:
                                                                      () {
                                                                    //Navigator.pushNamed(context, "/WorkerStartTask");
                                                                    Navigator.of(
                                                                            context)
                                                                        .push(MaterialPageRoute(builder:
                                                                            (_) {
                                                                      return WorkerFinishTaskPage(
                                                                        taskid:
                                                                            items.id,
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
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 20,
                                                                  right: 0),
                                                          child: Text(
                                                              "DITUGASKAN",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red,
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
                  ))),
            )
          ],
        ),
      ),
    );
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
