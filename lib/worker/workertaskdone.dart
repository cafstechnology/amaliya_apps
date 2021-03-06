import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';

import 'model/taskitem.dart';

var appBar = AppBar();
final _contollerTextEditing = TextEditingController();
ScrollController _scrollController;

class WorkerTaskDone extends StatefulWidget {
  final String tw;
  WorkerTaskDone({Key key, this.tw}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _WorkerTaskDone(this.tw);
  }
}

List<TaskItem> list = [];
List<TaskItem> filteredList = [];
List<TaskItem> unfilteredList = [];

class _WorkerTaskDone extends State<WorkerTaskDone> {
  _WorkerTaskDone(String tw);
  List<TaskItem> list = [];
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
          remarksDone: responseList.data[i]['remarksDone'].toString() ?? '-',
          remarksSpv: responseList.data[i]['remarksSpv'].toString() ?? '-',
          full_name: name,
          location: responseList.data[i]['locationName'].toString() ?? '-',
        );
        print(items.workstatus + " vs " + AppConfig.pending);
        if (items.workstatus == AppConfig.done) {
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
      centerTitle: true,
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Task Done",
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

                                return Container(
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
                                                  width: 160,
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
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          'Catatan : ${items.remarksDone}',
                                                          style: TextStyle(
                                                              fontSize: 18),
                                                        ),
                                                      ),
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

/// Widget

/// Start Search
void _settingModalBottomSheet(context) {
  Future<void> future = showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0.0))),
    //backgroundColor: Colors.black,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                    TextField(
                        controller: _contollerTextEditing,
                        decoration: InputDecoration(hintText: 'Search....'),
                        autofocus: true,
                        maxLines: 1,
                        style:
                            new TextStyle(fontSize: 24.0, color: Colors.black)
                        //controller: _newMediaLinkAddressController,
                        ),
                  ])),
              SizedBox(
                width: 50,
                height: 50,
                child: RaisedButton(
                    padding: EdgeInsets.all(0),
                    color: Colors.transparent,
                    elevation: 0,
                    onPressed: () {
                      _sendComment(_contollerTextEditing.text, "-", context);
                      _contollerTextEditing.text = "";
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.blue,
                    )),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
          ),
        ],
      ),
    ),
  );
  future.then((void value) => _closeModal(value));
}

void _closeModal(void value) {
  _contollerTextEditing.text = "";
  print('modal closed');
}

void _sendComment(String message, String emo, BuildContext context) async {
  Navigator.of(context).pop();
}

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 46.0;
}
