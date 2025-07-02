import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? pref;
}

class Preferences {
  Preferences._();

  static const String isLogin = 'is_user_login';
  static const String token = 'is_token';
  static const String isDark = 'is_dark';

  static Future<void> saveDriverDetails(String key,Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(data);
    await prefs.setString(key, jsonString);
  }

  static Future<Map<String, dynamic>?> getDriverDetails(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }



}


