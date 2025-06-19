import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../helper/shared_preference.dart';

ThemeProvider getThemeController(BuildContext context) {
  var store = Provider.of<ThemeProvider>(context, listen: false);
  return store;
}

class ThemeProvider extends ChangeNotifier {
  bool darkTheme = SharedPref.pref!.getBool(Preferences.isDark) ?? false;

  toggleTheme() {
    darkTheme = !darkTheme;
    SharedPref.pref!.setBool(Preferences.isDark, darkTheme);
    notifyListeners();
  }

}
