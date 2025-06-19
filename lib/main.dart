import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:guruchaya/provider/auth_provider.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/provider/theme_provider.dart';
import 'package:guruchaya/screens/splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'helper/app_theme.dart';
import 'helper/navigation.dart';
import 'helper/routes.dart';
import 'helper/shared_preference.dart';
import 'helper/string.dart';
import 'language/localization/local_constant.dart';
import 'language/localization/localization_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupaBaseKeys.baseUrl,
    anonKey: SupaBaseKeys.apiKey,
  );
  SharedPref.pref = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => BookingController()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_MyAppState>();
    state!.setLocale(newLocale);
  }

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() async {
    getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Consumer<ThemeProvider>(
        builder: (context,themeStore, snapshot) {
          return ScreenUtilInit(
            designSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            minTextAdapt: true,
            splitScreenMode: true,
            useInheritedMediaQuery: true,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: Constants.appName,
              locale: _locale,
              supportedLocales: const [
                Locale('en', ''),
                Locale('hi', ''),
                Locale('gu', ''),
              ],
              localizationsDelegates: const [
                AppLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale?.languageCode &&
                      supportedLocale.countryCode == locale?.countryCode) {
                    return supportedLocale;
                  }
                }
                return supportedLocales.first;
              },
              theme: themeStore.darkTheme
                  ? AppTheme.darkTheme
                  : AppTheme.lightTheme,
              themeMode: ThemeMode.light,
              navigatorKey: NavigationService.navigatorKey,
              onGenerateRoute: RouteGenerator.generateRoute,
              home: SplashScreen(),
            ),
          );
        }
      ),
    );
  }
}


