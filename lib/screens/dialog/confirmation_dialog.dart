import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helper/dimens.dart';
import '../../helper/navigation.dart';
import '../../helper/responsive.dart';
import '../../helper/string.dart';
import '../../language/localization/language/languages.dart';
import '../../widgets/app_button.dart';

class ConfirmationDialog extends StatefulWidget {
  Function(bool value) onTap;
  String title;
  String msg;

  ConfirmationDialog(this.title, this.msg, this.onTap);

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: Dimens.padding_20),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: SizedBox(
          width: Responsive.isDesktop(context) ? Dimens.dimen_400 : MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.all(Dimens.padding_20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.labelSmall!.color,
                        fontFamily: Fonts.semiBold,
                        fontSize: Dimens.fontSize_16,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        widget.onTap(false);
                        NavigationService.goBack;
                      },
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).textTheme.labelSmall!.color,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: Dimens.height_20,
                ),
                Text(
                  widget.msg,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .color!
                        .withOpacity(0.6),
                    fontFamily: Fonts.medium,
                    fontSize: Dimens.fontSize_13,
                  ),
                ),
                SizedBox(
                  height: Dimens.height_30,
                ),
                Row(
                  children: [
                    AppButton(
                      height: Dimens.height_35,
                      width: Dimens.width_80,
                      label: Languages.of(context)!.yes,
                      textSize: Dimens.dimen_12,
                      onPressed: () {
                        widget.onTap(true);
                        NavigationService.goBack;
                      },
                    ),
                    SizedBox(width: Dimens.width_10,),
                    AppButton(
                      height: Dimens.height_35,
                      width: Dimens.width_80,
                      textSize: Dimens.dimen_12,
                      label: Languages.of(context)!.no,
                      onPressed: () {
                        widget.onTap(false);
                        NavigationService.goBack;
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
