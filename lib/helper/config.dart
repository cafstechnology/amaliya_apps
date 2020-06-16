import 'package:flutter/material.dart';

class AppConfig{
  //static final String SERVER    = "https://amaliya.cafs.technology";
  static final String SERVER = "http://amaliya-dev.cafstechnology.id";
  static final String API = SERVER + "/api/";
  static final String pending = "Pending";
  static final String onprogress = "On Progress";
  static final String done = "Done";
  static final String postpone = "Postpone";
  static final String owner = "mbp";
  Color colormbp1 = Color.fromRGBO(255, 127, 95, 1);
  Color colormbp2 = Color.fromRGBO(254, 180, 123, 1);
  Color coloramaliya1 = Color.fromRGBO(0, 4, 40, 1);
  Color coloramaliya2 = Color.fromRGBO(0, 78, 146, 1);
  static const String backendUrl = "http://192.168.16.104:3000";
  static const String socketUrl = "ws://192.168.16.104:3000/cable";
}