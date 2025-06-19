import 'package:flutter/material.dart';
import 'package:guruchaya/screens/main_screen.dart';
import 'package:guruchaya/screens/all_booking_screen.dart';
import 'package:guruchaya/screens/pdf_view_screen.dart';
import 'package:guruchaya/screens/setting_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../screens/login_screen.dart';
import '../screens/splash.dart';


class Routes {
  static const String splash = "/splash";
  static const String login = "/login";
  static const String main = "/main";
  static const String allBooking = "/allBooking";
  static const String setting = "/setting";
  static const String pdfView = "/pdfView";
}

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    Map<String, dynamic> args = {};
    if(settings.arguments != null){
      args = settings.arguments as Map<String, dynamic>;
    }

    switch (settings.name) {
      case Routes.splash:
        return fadePageTransition(SplashScreen());
      case Routes.login:
        return fadePageTransition(LoginScreen());
      case Routes.main:
        return fadePageTransition(MainScreen());
      case Routes.allBooking:
        return fadePageTransition(AllBookingScreen(busNumber : args['busNumber'], date: args['date'],));
      case Routes.pdfView:
        return fadePageTransition(PdfScreen(busNumber : args['busNumber'], date: args['date'],));
      case Routes.setting:
        return fadePageTransition(SettingScreen());
        default:
        return _errorRoutes();
    }
  }

  static PageTransition fadePageTransition(Widget screen,
      {RouteSettings? settings}) {
    return PageTransition(
        child: screen, type: PageTransitionType.fade, settings: settings);
  }

  static PageTransition rightToLeftTransition(Widget screen,
      {RouteSettings? settings}) {
    return PageTransition(
      child: screen,
      type: PageTransitionType.rightToLeft,
      settings: settings,
    );
  }

  static PageTransition bottomToTopTransition(Widget screen,
      {RouteSettings? settings}) {
    return PageTransition(
        child: screen,
        type: PageTransitionType.bottomToTop,
        settings: settings,
        duration: const Duration(milliseconds: 300));
  }

  static Route<dynamic> _errorRoutes() {
    return MaterialPageRoute(builder: (_) {
      return const Scaffold(
        body: Center(
          child: Text('Error'),
        ),
      );
    });
  }
}
