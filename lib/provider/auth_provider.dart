import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/shared_preference.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/screens/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_provider.dart';

AuthController getAuthStore(BuildContext context) {
  var store = Provider.of<AuthController>(context, listen: false);
  return store;
}

class AuthController extends ChangeNotifier {

  bool loading = false;

  changeLoadingStatus(bool status) {
    loading = status;
    notifyListeners();
  }

  login({required String email, required String password}) async {
    changeLoadingStatus(true);
    try {
      final response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);
      changeLoadingStatus(false);
      if (response.user != null) {
        SharedPref.pref!.setString(Preferences.token, response.session!.accessToken);
        SharedPref.pref!.setBool(Preferences.isLogin, true);
        getBookingStore(NavigationService.context).getAllBusNumber();
        Navigator.pushAndRemoveUntil(
          NavigationService.context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        AlertSnackBar.error(Languages.of(NavigationService.context)!.noUserFound);
      }
    } on AuthException catch (e) {
      changeLoadingStatus(false);
      AlertSnackBar.error(e.message);
    } catch (e) {
      changeLoadingStatus(false);
      AlertSnackBar.error(e.toString());
    }
  }
}
