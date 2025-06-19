import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? pref;
}

class Preferences {
  Preferences._();

  static const String isLogin = 'is_user_login';
  static const String token = 'is_token';
  static const String isDark = 'is_dark';
}
