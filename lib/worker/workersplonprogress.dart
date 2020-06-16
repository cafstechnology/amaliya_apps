import 'dart:io';

import 'package:amaliya/worker/model/spl.dart';
import 'package:amaliya/worker/workerfinishspl.dart';
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

class WorkerSplOnprogress extends StatefulWidget {
  final String tw;
  WorkerSplOnprogress({Key key, this.tw}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _WorkerSplOnprogressState(this.tw);
  }
}

List<Spl> list = [];
List<Spl> filteredList = [];
List<Spl> unfilteredList = [];

class _WorkerSplOnprogressState extends State<WorkerSplOnprogress> {
  _WorkerSplOnprogressState(String tw);
  String urlApi = AppConfig.API + "v1/worker/overtime/get-overtime";
  Future<List> getListTask() async {
    try {
      list.clear();
      filteredList.clear();
      unfilteredList.clear();
      Response responseList = await Dio().post(urlApi,
          options: new Options(headers: {
            HttpHeaders.authorizationHeader: "Bearer " + widget.tw
          }));
      print(responseList.data.toString());
      for (int i = 0; i < responseList.data.length; i++) {
        Spl items = Spl(
          title: responseList.data[i]['taskCategoryName'].toString(),
          description: responseList.data[i]['description'].toString(),
          scheduledStartDate:
              responseList.data[i]['scheduledStartDate'].toString(),
          scheduledStartTime:
              responseList.data[i]['scheduledStartTime'].toString(),
          scheduledEndDate: responseList.data[i]['scheduledEndDate'].toString(),
          scheduledEndTime: responseList.data[i]['scheduledEndTime'].toString(),
          customerName: responseList.data[i]['customerName'].toString(),
          supervisorName: responseList.data[i]['supervisorName'].toString(),
          fullName: name,
          status: responseList.data[i]['status'].toString(),
          lokasi: responseList.data[i]['locationName'].toString() ?? '-',
          category: responseList.data[i]['taskCategoryName'].toString() ?? '-',
          longitude: responseList.data[i]['longitude'].toString() ?? '-',
          latitude: responseList.data[i]['latitude'].toString() ?? '-',
          approvalStatus:
              responseList.data[i]['approvalStatus'].toString() ?? '-',
          id: responseList.data[i]['id'].toString() ?? '-',
        );

        if (items.status == "On Progress") {
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
            "SPL Berlangsung",
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
                                    Spl items = filteredList[index];

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
                                                            items.scheduledStartDate +
                                                                " " +
                                                                items
                                                                    .scheduledStartTime +
                                                                " Sampai " +
                                                                items
                                                                    .scheduledEndDate +
                                                                " " +
                                                                items
                                                                    .scheduledEndTime,
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          ),
                                                          SizedBox(
                                                            height: 20,
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
                                                                items
                                                                    .description,
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
                                                              items.description,
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
                                                              items
                                                                  .customerName,
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
                                                              items.lokasi,
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
                                                                      return WorkerFinishSplPage(
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
    List<Spl> dummySearchList = List<Spl>();
    dummySearchList.addAll(unfilteredList);
    if (query.isNotEmpty) {
      List<Spl> dummyListData = List<Spl>();
      dummySearchList.forEach((item) {
        if (item.description.toLowerCase().contains(query.toLowerCase())) {
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
