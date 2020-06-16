import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workertaskdone.dart';
import 'package:amaliya/worker/workertasklist.dart';
import 'package:amaliya/worker/workertaskprogress.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

var appBar = AppBar();
String tokenWorker = "",
    email = "-",
    name = "-",
    phone = "-",
    gender = "-",
    edu = "-",
    urlimage = "-";
String remainCount = "0", doneCount = "0", progressCount = "0";
Image pp;

class WorkerHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _WorkerHome();
  }
}

class _WorkerHome extends State<WorkerHome> {
  static final String serverUrl =
      AppConfig.API + "v1/worker/get-summary-status";
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
      remainCount = jsonDecode(responseRemain.toString())['pending'].toString();
      doneCount = jsonDecode(responseRemain.toString())['done'].toString();
      progressCount = jsonDecode(responseRemain.toString())['start'].toString();
    }

    // ignore: unnecessary_statements
    items = <GridItems>[
      GridItems(
          title: "TUGAS TERSELESAIKAN",
          titleJob: doneCount == null ? "0" : doneCount,
          id: 1),
      GridItems(
          title: "TUGAS TERSISA",
          titleJob: remainCount == null ? "0" : remainCount,
          id: 2),
      GridItems(
          title: "TUGAS BERLANGSUNG",
          titleJob: progressCount == null ? "0" : progressCount,
          id: 3),
    ];
    return items;
  }

  @override
  void initState() {
    super.initState();
    imageCache.clear();
    pp = null;
    getPref();
    Future.delayed(new Duration(seconds: 1), () {
      generateImage();
    });
    //generate image
  }

  generateImage() async {
    try {
      Response response = await Dio().get(AppConfig.SERVER + urlimage);
      print("res : ${AppConfig.SERVER + urlimage} + ${response.statusCode}");
      if (response.statusCode == 200) {
        setState(() {
          pp = new Image.network(AppConfig.SERVER + urlimage);
        });
      }
    } catch (e) {
      setState(() {
        pp = new Image.asset("assets/images/default-profile.jpg");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,//Color(0xFFFFFFFF),
      body: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Column(
            children: <Widget>[
              Container(
                height: (MediaQuery.of(context).size.height -
                        appBar.preferredSize.height) /
                    2.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                      image: AssetImage('assets/images/background_fitur.jpg'),
                      fit: BoxFit.cover),
                ),
                child: Stack(children: <Widget>[
                  Material(
                    color: Colors.white.withOpacity(0.2),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                            top: 15,
                            left: 0,
                            right: 0,
                            child: Align(
                                alignment: Alignment.topCenter,
                                child: Text(name,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 20)))),
                        Positioned(
                            top: 55,
                            left: 0,
                            right: 0,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 150.0,
                                height: 150.0,
                                child: ClipOval(
                                    child: pp == null
                                        ? new CircularProgressIndicator()
                                        : pp),
                              ),
                            )),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                new Material(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: new BorderRadius.only(
                                      topRight: Radius.circular(25),
                                      bottomRight: Radius.circular(25)),
                                  child: FlatButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          fetchTaskCount();
                                        });
                                      },
                                      icon: Icon(Icons.schedule,
                                          color: Colors.white),
                                      label: Text("MUAT ULANG TASK",
                                          style:
                                              TextStyle(color: Colors.white))),
                                ),
                              ]),
                        ),
                      ],
                    ),
                  )
                ]),
              ),
              // Container(
              //   height: MediaQuery.of(context).size.height / 15,
              //   child: Padding(
              //     padding: EdgeInsets.only(top: 13),
              //     child: Text('HARI INI',
              //         style: TextStyle(
              //             color: Colors.black,
              //             fontSize: 25,
              //             fontFamily: 'QBold')),
              //   ),
              // ),
              Expanded(
                child: new Center(
                    child: Container(
                        // decoration: BoxDecoration(
                        //   color: Colors.transparent,
                        //   image: DecorationImage(
                        //       image: AssetImage(
                        //           'assets/images/background_bot.jpg'),
                        //       fit: BoxFit.cover),
                        // ),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(top: 13),
                              child: Text('HARI INI',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontFamily: 'QBold')),
                            ),
                            Expanded(
                              child: FutureBuilder(
                                future: fetchTaskCount(),
                                // ignore: missing_return
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return items.length == 0 ||
                                            items.length == null
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : GridView.count(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 4.0,
                                            crossAxisSpacing: 4.0,
                                            childAspectRatio: 1,
                                            padding: const EdgeInsets.all(7.0),
                                            children: List.generate(
                                                items.length, (index) {
                                              GridItems item = items[index];
                                              return Container(
                                                child: InkWell(
                                                  onTap: () {
                                                    switch (item.id) {
                                                      case 1:
                                                        if (doneCount != "0") {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) {
                                                            return WorkerTaskDone(
                                                              tw: tokenWorker,
                                                            );
                                                          }));
                                                        }

                                                        break;
                                                      case 2:
                                                        if (remainCount !=
                                                            "0") {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) {
                                                            return WorkerTaskList(
                                                              tw: tokenWorker,
                                                            );
                                                          }));
                                                        }
                                                        break;
                                                      case 3:
                                                        if (progressCount !=
                                                            "0") {
                                                          Navigator.of(context)
                                                              .push(
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) {
                                                            return WorkerTaskProgress(
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
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5,
                                                                  right: 5,
                                                                  top: 5),
                                                          child: Text(
                                                            item.title,
                                                            maxLines: 3,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
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
                              ),
                            )
                          ],
                        ))),
              ),
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
