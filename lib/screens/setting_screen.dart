import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/language/language_data.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_button.dart';
import 'package:guruchaya/widgets/app_drop_down.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../helper/string.dart';

import 'package:pdf/widgets.dart' as pw;

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
      body:
          Consumer<BookingController>(builder: (context, bookStore, snapshot) {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(Dimens.padding_20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only( bottom:Dimens.padding_20),
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
            LoadingWithBackground(bookStore.loading)
          ],
        );
      }),
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
                  fontSize: Dimens.fontSize_12,
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
