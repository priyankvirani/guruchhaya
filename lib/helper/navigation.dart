import 'package:flutter/material.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);

  static Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) =>
      navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);

  static Future<dynamic> navigateToReplacementAndRemove(String routeName) =>
      navigatorKey.currentState!.pushAndRemoveUntil(
        context,
        (route) => false,
      );

  static get goBack => navigatorKey.currentState!.pop();

  static get context => navigatorKey.currentContext;
}
