import 'package:flutter/material.dart';
import 'package:guruchaya/language/localization/language/language_en.dart';
import 'package:guruchaya/language/localization/language/language_gu.dart';
import 'package:guruchaya/language/localization/language/language_hi.dart';


import 'language/languages.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<Languages> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar', 'hi','gu'].contains(locale.languageCode);

  @override
  Future<Languages> load(Locale locale) => _load(locale);

  static Future<Languages> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'hi':
        return LanguageHi();
      case 'gu':
        return LanguageGu();
      default:
        return LanguageGu();
    }
  }

  @override
  bool shouldReload(LocalizationsDelegate<Languages> old) => false;
}