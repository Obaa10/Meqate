import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _prefs;

  // call this method from iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }


  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static String? getString(String key) => _prefs.getString(key);

}