import 'package:flutter/material.dart';

import '../helper/colors.dart';
import '../helper/dimens.dart';
import '../helper/string.dart';

class AppButton extends StatelessWidget {
  final String label;
  final Function() onPressed;
  final double? width;
  final double height;
  final double textSize;
  final double radius;
  final EdgeInsets margin;

  final double iconSize;
  final Color? bgColor;
  final Color textColor;
  final bool isBorder;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final MainAxisAlignment mainAxisAlignment;

   AppButton(
      {required this.label,
      required this.onPressed,
      this.width = double.infinity,
      this.height = 55,
      this.textSize = 15,
      this.radius = 14,
      this.margin = EdgeInsets.zero,
      this.iconSize = 20,
      this.bgColor = primaryColor,
      this.textColor = whiteColor,
      this.isBorder = false,
      this.suffixIcon,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? MediaQuery.of(context).size.width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: isBorder ? primaryColor : Colors.transparent),
        color: bgColor,
      ),
      child: MaterialButton(
        height: height,
        color: Colors.transparent,
        minWidth: width ?? MediaQuery.of(context).size.width / 2,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        onPressed: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: mainAxisAlignment,
          children: [
            if (prefixIcon != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.dimen_8),
                child: prefixIcon!,
              ),
            Text(
              label,
              textAlign: TextAlign.center,
              softWrap: false,
              maxLines: 1,
              style: TextStyle(
                fontSize: textSize,
                color: textColor,
                fontFamily: Fonts.semiBold,
              ),
            ),
            if (suffixIcon != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.dimen_8),
                child: suffixIcon!,
              ),
          ],
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Function() onPressed;
  final double? width;
  final double height;
  final double textSize;
  final double radius;
  final EdgeInsets margin;
  final TextStyle? textStyle;
  final String? icon;
  final double iconSize;

  const SocialButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 50,
    this.textSize = 14,
    this.radius = 8,
    this.margin = EdgeInsets.zero,
    this.textStyle,
    this.icon,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? MediaQuery.of(context).size.width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        // border: Border.all(color: AppColors.buttonBorder.withOpacity(0.2)),
        color: Colors.transparent,
      ),
      child: MaterialButton(
        height: height,
        color: Colors.transparent,
        minWidth: width ?? MediaQuery.of(context).size.width / 2,
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        disabledElevation: 0,
        highlightElevation: 0,
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Image.asset(
                      icon!,
                      width: iconSize,
                    ),
                  ),
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: textSize,
                  color: Theme.of(context).textTheme.labelSmall!.color,
                  // fontFamily: Fonts.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
