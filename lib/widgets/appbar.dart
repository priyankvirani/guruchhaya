import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../helper/colors.dart';
import '../helper/dimens.dart';
import '../helper/navigation.dart';
import '../helper/string.dart';

class BackAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final GestureTapCallback? onBack;


  const BackAppBar({super.key, required this.title, this.actions = const [],this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      top: true,
      right: false,
      bottom: false,
      child: MediaQuery(
        data: MediaQueryData(
          textScaleFactor: 1.0,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onBack ?? ()  => NavigationService.goBack,
              child: Image.asset(
                Images.back,
                height: Dimens.height_25,
              ),
            ),
            SizedBox(
              width: Dimens.width_10,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.labelSmall!.color,
                  fontSize: Dimens.fontSize_16,
                  fontFamily: Fonts.semiBold,
                ),
              ),
            ),
            ...actions!
          ],
        ),
      ),
    );
  }
}

class MainAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final GestureTapCallback? onBack;


  const MainAppBar({super.key, required this.title, this.actions = const [],this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      top: true,
      right: false,
      bottom: false,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.labelSmall!.color,
                fontSize: Dimens.fontSize_16,
                fontFamily: Fonts.semiBold,
              ),
            ),
          ),
          ...actions!
        ],
      ),
    );
  }
}

