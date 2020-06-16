import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amaliya/helper/config.dart';
import 'package:amaliya/worker/workerdashboard.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

class WorkerCalendar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WorkerCalendar();
  }
}

class _WorkerCalendar extends State<WorkerCalendar>
    with TickerProviderStateMixin {
  Map<DateTime, List> _events;

  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  DateTime now = DateTime.now();
  String urlApi = AppConfig.API + "v1/worker/get-schedule";

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    _selectedEvents = [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    //_streamController.close();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    String date = formatDate(day, [yyyy, "-", mm, "-", dd]);
    getData(date);
    setState(() {
      print("Size : ${events.length}");
      print('CALLBACK: _onDaySelected : ' + date);
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
    setState(() {
      _selectedEvents = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final _appBar = AppBar(
      centerTitle: true,
      title: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(
            "Jadwal Pekerja",
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
      appBar: _appBar,
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          // Switch out 2 lines below to play with TableCalendar's settings
          //-----------------------
          _buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: _buildEventList()),
        ],
      ),
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendar() {
    return Container(
        color: Colors.white,
        child: TableCalendar(
          locale: 'id_ID',
          calendarController: _calendarController,
          events: _events,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            selectedColor: Colors.blue[300],
            todayColor: Colors.blue,
            outsideDaysVisible: false,
          ),
          builders: CalendarBuilders(
            markersBuilder: (context, date, events, holidays) {
              final children = <Widget>[];
              return children;
            },
          ),
          headerStyle: HeaderStyle(
            centerHeaderTitle: true,
            formatButtonVisible: false,
          ),
          onDaySelected: _onDaySelected,
          onVisibleDaysChanged: _onVisibleDaysChanged,
        ));
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.redAccent
            : _calendarController.isToday(date)
                ? Colors.redAccent
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }

  Future getData(String date) async {
    _events = {};
    FormData formData = new FormData.fromMap({
      "date": date,
    });
    Response response = await Dio().post(urlApi,
        data: formData,
        options: new Options(
            headers: {HttpHeaders.authorizationHeader: "Bearer " + token}));

    for (var i = 0; i < response.data.length; i++) {
      String starttanggal = response.data[i]['startDate'].toString();
      String endtanggal = response.data[i]['endDate'].toString();
      _events.putIfAbsent(DateTime.parse(starttanggal), () => [])
          .add(response.data[i]['name'].toString() +" Dari Tanggal dan Jam "+starttanggal+"/"+response.data[i]['startTime'].toString()+ " Sampai Tanggal dan Jam "+endtanggal+"/"+response.data[i]['endTime'].toString());

    }
  }
}
