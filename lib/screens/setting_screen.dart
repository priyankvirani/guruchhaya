import 'package:flutter/material.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/language/language_data.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:provider/provider.dart';
import '../helper/string.dart';
import '../language/localization/local_constant.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      languageLoad();
    });
  }

  String languageSelected = "";

  languageLoad() {
    getLocale().then((value) {
      LanguageData.languageList().forEach((element) {
        if (element.languageCode == value.languageCode) {
          setState(() {
            languageSelected = element.name;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BookingController>(
        builder: (context, bookStore, snapshot) {
          return Stack(
            children: [
              SafeArea(
                child: MediaQuery(
                  data: MediaQueryData(
                    textScaleFactor: 1.0,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(Dimens.padding_20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Dimens.padding_20),
                          child: BackAppBar(
                            title: Languages.of(context)!.setting,
                          ),
                        ),
                        settingTile(
                          title: Languages.of(context)!.language,
                          image: Images.language,
                          isLanguage: true,
                          onPressed: () {
                            AppDialog.languageDialog(context, onTap: (val) {
                              changeLanguage(context, val.languageCode);
                              languageLoad();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              LoadingWithBackground(bookStore.loading)
            ],
          );
        },
      ),
    );
  }

  settingTile(
      {required String title,
      required String image,
      required Function() onPressed,
      bool isLanguage = false,
      bool isCurrency = false,
      Color? color}) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.radius_10),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(Dimens.padding_15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radius_10),
            color: Theme.of(context)
                .textTheme
                .labelSmall!
                .color!
                .withOpacity(0.1)),
        child: Row(
          children: [
            Image.asset(
              image,
              width: Dimens.width_22,
              height: Dimens.height_22,
              color: color ?? Theme.of(context).textTheme.labelSmall!.color,
            ),
            const SizedBox(
              width: 15,
            ),
            Text(
              title,
              style: TextStyle(
                  fontFamily: Fonts.semiBold,
                  fontSize: Dimens.fontSize_14,
                  color:
                      color ?? Theme.of(context).textTheme.titleLarge!.color),
            ),
            const Expanded(child: SizedBox()),
            if (isLanguage)
              Padding(
                padding: EdgeInsets.only(right: Dimens.padding_10),
                child: Text(
                  languageSelected,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: Dimens.fontSize_12,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.labelSmall!.color,
            )
          ],
        ),
      ),
    );
  }
}
