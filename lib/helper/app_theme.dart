import 'package:flutter/material.dart';
import 'colors.dart';
import 'shared_preference.dart';
import 'string.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: whiteColor,
    primaryColor: primaryColor,
    fontFamily: Fonts.medium,
    indicatorColor: scaffoldDarkColor,
    dividerColor: greyColor,
    textTheme: const TextTheme(
      labelSmall: TextStyle(color: blackColor),
      labelMedium: TextStyle(color: whiteColor),
      titleLarge: TextStyle(color: blackColor, fontFamily: Fonts.medium),
    ),

  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: scaffoldDarkColor,
    primaryColor:  primaryColor,
    fontFamily: Fonts.medium,
    indicatorColor: whiteColor,
    dividerColor: bottomBarDark,
    textTheme: const TextTheme(
      labelSmall: TextStyle(color: whiteColor),
      labelMedium: TextStyle(color: blackColor),
      titleLarge: TextStyle(color: textDarkColor, fontFamily: Fonts.medium),
    ),
  );
}

bool isDarkTheme() {
  bool darkTheme = SharedPref.pref!.getBool(Preferences.isDark) ?? true;

  return darkTheme;
}
