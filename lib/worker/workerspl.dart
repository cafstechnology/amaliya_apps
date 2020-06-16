import 'dart:convert';
import 'dart:io';

import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerformspl.dart';
import 'package:amaliya/worker/workersplapprovedlist.dart';
import 'package:amaliya/worker/workerspldone.dart';
import 'package:amaliya/worker/workersplonprogress.dart';
import 'package:amaliya/worker/workersplrejectedlist.dart';
import 'package:amaliya/worker/workersplunapprovelist.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerSpl extends StatefulWidget {
  _WorkerSpl createState() => _WorkerSpl();
}

class _WorkerSpl extends State<WorkerSpl> {
  String tokenWorker = "",
      email = "-",
      name = "-",
      phone = "-",
      gender = "-",
      edu = "-",
      urlimage = "-";
  String pendingapproval = "0",
      approved = "0",
      rejected = "0",
      splonprogress = "0",
      spldone = "0";
  static final String serverUrl =
      AppConfig.API + "v1/worker/overtime/get-summary-status";
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString("email") ?? '-';
      name = preferences.getString("name") ?? '-';
      tokenWorker = preferences.getString("token") ?? '-';
      urlimage = preferences.getString("imgPP");
    });
  }

  List<GridItems> items = [];
  Future<List> fetchTaskCount() async {
    Response responseRemain = await Dio().post(serverUrl,
        options: new Options(headers: {
          HttpHeaders.authorizationHeader: "Bearer " + tokenWorker
        }));
    if (responseRemain.statusCode.toString() == "200") {
      pendingapproval =
          jsonDecode(responseRemain.toString())['waiting'].toString();
      approved = jsonDecode(responseRemain.toString())['scheduled'].toString();
      rejected = jsonDecode(responseRemain.toString())['cancel'].toString();
      splonprogress = jsonDecode(responseRemain.toString())['start'].toString();
      spldone = jsonDecode(responseRemain.toString())['done'].toString();
    }

    // ignore: unnecessary_statements
    items = <GridItems>[
      GridItems(
          title: "BELUM DISETUJUI",
          titleJob: pendingapproval == null ? "0" : pendingapproval,
          id: 1),
      GridItems(
          title: "SUDAH DISETUJUI",
          titleJob: approved == null ? "0" : approved,
          id: 2),
      GridItems(
          title: "DITOLAK", titleJob: rejected == null ? "0" : rejected, id: 3),
      GridItems(
          title: "SPL BERLANGSUNG",
          titleJob: splonprogress == null ? "0" : splonprogress,
          id: 4),
      GridItems(
          title: "SPL TERSELESAIKAN",
          titleJob: spldone == null ? "0" : spldone,
          id: 5),
    ];
    return items;
  }

  @override
  void initState() {
    super.initState();
    getPref();
    //generate image
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(
      centerTitle: true,
      title: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Pengajuan Lembur",
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
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 25.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerFormSpl(),
                  ));
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 26.0,
            ),
          ),
        )
      ],
    );
    return Scaffold(
      appBar: _appBar,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,//Color(0xFFFFFFFF),
      body: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: new Center(
                    child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: FutureBuilder(
                          future: fetchTaskCount(),
                          // ignore: missing_return
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return items.length == 0 || items.length == null
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : GridView.count(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 4.0,
                                      crossAxisSpacing: 4.0,
                                      childAspectRatio: 1,
                                      padding: const EdgeInsets.all(7.0),
                                      children:
                                          List.generate(items.length, (index) {
                                        GridItems item = items[index];
                                        return Container(
                                          child: InkWell(
                                            onTap: () {
                                              switch (item.id) {
                                                case 1:
                                                  if (pendingapproval != "0") {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return WorkerSplUnapproveList(
                                                        tw: tokenWorker,
                                                      );
                                                    }));
                                                  }

                                                  break;
                                                case 2:
                                                  if (approved != "0") {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return WorkerSplApprovedList(
                                                        tw: tokenWorker,
                                                      );
                                                    }));
                                                  }
                                                  break;
                                                case 3:
                                                  if (rejected != "0") {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return WorkerSplRejectedList(
                                                        tw: tokenWorker,
                                                      );
                                                    }));
                                                  }
                                                  break;
                                                case 4:
                                                  if (splonprogress != "0") {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return WorkerSplOnprogress(
                                                        tw: tokenWorker,
                                                      );
                                                    }));
                                                  }
                                                  break;
                                                case 5:
                                                  if (spldone != "0") {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (_) {
                                                      return WorkerSplDone(
                                                        tw: tokenWorker,
                                                      );
                                                    }));
                                                  }
                                                  break;

                                                default:
                                                  break;
                                              }
                                            },
                                            child: Card(
                                              elevation: 6,
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: 45,
                                                    padding: EdgeInsets.only(
                                                        left: 5,
                                                        right: 5,
                                                        top: 5),
                                                    child: Text(
                                                      item.title,
                                                      maxLines: 3,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'QRegular'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        item.titleJob,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 40,
                                                            fontFamily:
                                                                'QBold'),
                                                      ),
                                                    ],
                                                  ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    );
                            } else {
                              return Center(
                                child: new CircularProgressIndicator(),
                              );
                            }
                          },
                        ))),
              ),
              RaisedButton(
                onPressed: //check()
                    () async {
                  setState(() {
                    fetchTaskCount();
                  });
                  fetchTaskCount();
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
                  child: const Text('Muat Ulang / Refresh',
                      style: TextStyle(fontSize: 20)),
                ),
              )
            ],
          )),
    );
  }
}

class GridItems {
  const GridItems({this.title, this.titleJob, this.id});

  final String title;
  final String titleJob;
  final id;
}
