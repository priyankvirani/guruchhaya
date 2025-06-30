import 'package:flutter/material.dart';
import 'package:guruchaya/helper/shared_preference.dart';
import 'package:lottie/lottie.dart';
import '../helper/dimens.dart';
import '../helper/navigation.dart';
import '../helper/routes.dart';
import '../helper/string.dart';
import '../provider/booking_provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogin = SharedPref.pref!.getBool(Preferences.isLogin) ?? false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if(isLogin){
        getBookingStore(context).getAllBusNumber();
      }
      await Future.delayed(const Duration(seconds: 3)).then(
        (value) {
          NavigationService.navigateToReplacement(
            isLogin ? Routes.main : Routes.login,
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MediaQuery(
        data: MediaQueryData(
          textScaleFactor: 1.0,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(left: Dimens.dimen_30),
            child: Lottie.asset(LottieFile.bus, width: Dimens.width_400),
          ),
        ),
      ),
    );
  }
}
