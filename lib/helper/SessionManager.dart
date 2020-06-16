library prefs;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
class SharedPreferencesHelper {
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static _doSave(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('id_user', token);
    print(prefs.getString('id_user'));
  }

}

class SessionClass {
  static String IDUSER      = "IDUSER";
  static String NAME        = "NAME";
  static String PROFILE_URL = "PROFILE_URL";
}