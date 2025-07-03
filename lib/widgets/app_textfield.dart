import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../helper/colors.dart';
import '../helper/dimens.dart';
import '../helper/string.dart';

class AppTextField extends StatelessWidget {
  final String titleText;
  final TextEditingController? controller;
  final int? maxLines;
  final bool? isReadOnly;
  final bool? isEnabled;
  final int? maxLength;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final Function(String)? onchanged;
  final FormFieldValidator? validator;
  final Function()? onTap;
  final String? hintText;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefix;
  final Widget? prefixWidget;
  final Widget? suffix;
  final TextAlign? textAlign;
  final bool? autoValidate;
  final EdgeInsets? contentPadding;
  final bool? isCapital;
  final bool? isFilled;
  final ValueChanged<String>? onFieldSubmitted;
  final double? borderRadius;
  final Color? borderColor;
  final Color? fillColor;
  final String? labelText;
  final Color? prefixColor;
  const AppTextField(
      {super.key,
      required this.titleText,
      this.controller,
      this.maxLines,
      this.isReadOnly = false,
      this.isEnabled,
      this.maxLength,
      this.obscureText = false,
      this.keyboardType,
      this.onchanged,
      this.validator,
      this.onTap,
      this.hintText,
      this.inputFormatters,
      this.prefix,
      this.prefixWidget,
      this.suffix,
      this.textAlign,
      this.autoValidate = false,
      this.contentPadding,
      this.isCapital,
      this.onFieldSubmitted,
      this.isFilled = false,
      this.borderRadius = 12,
      this.borderColor,
      this.fillColor = backgroundColor,
      this.labelText,
      this.prefixColor = textFieldIconColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText.isNotEmpty
            ? Text(
                titleText,
                style: TextStyle(
                  fontSize: Dimens.fontSize_12,
                  fontFamily: Fonts.semiBold,
                  color: textColor,
                ),
              )
            : const SizedBox.shrink(),
        SizedBox(
          height: Dimens.height_6,
        ),
        TextFormField(
          controller: controller,
          style: TextStyle(
            fontSize: Dimens.fontSize_12,
            color: textColor,
            fontFamily: Fonts.medium,
          ),
          maxLines: maxLines ?? 1,
          readOnly: isReadOnly!,
          enabled: isEnabled,
          maxLength: maxLength,
          obscureText: obscureText!,
          decoration: InputDecoration(
              filled: isFilled,
              fillColor: fillColor,
              contentPadding: contentPadding ??
                  EdgeInsets.only(
                    left: Dimens.padding_15,
                    top: Dimens.padding_10,
                    right: Dimens.padding_15,
                    bottom: Dimens.padding_10,
                  ),
              hintText: hintText,
              hintStyle: TextStyle(
                  fontSize: Dimens.fontSize_13,
                  fontFamily: Fonts.semiBold,
                  color: redColor),
              labelText: labelText,
              labelStyle: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontFamily: Fonts.regular,
                    letterSpacing: -0.1,
                    fontSize: Dimens.fontSize_14,
                    color: hintColor.withOpacity(0.24),
                  ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(maxLines == null ? borderRadius! : 6),
                borderSide: isFilled!
                    ? BorderSide.none
                    : BorderSide(width: 1.0, color: borderColor ?? greyColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(maxLines == null ? borderRadius! : 6),
                borderSide: isFilled!
                    ? BorderSide.none
                    : BorderSide(width: 1.0, color: borderColor ?? greyColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(maxLines == null ? borderRadius! : 6),
                borderSide: isFilled!
                    ? BorderSide.none
                    : BorderSide(width: 1.0, color: borderColor ?? greyColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(maxLines == null ? borderRadius! : 6),
                borderSide: isFilled!
                    ? BorderSide.none
                    : BorderSide(width: 1.0, color: borderColor ?? primaryColor),
              ),
              prefixIcon: prefixWidget ??
                  (prefix == null
                      ? null
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 10, top: 10.0, bottom: 10, right: 6),
                          child: SvgPicture.asset(
                            prefix!,
                            width: 30,
                            height: 30,
                            colorFilter:
                                ColorFilter.mode(prefixColor!, BlendMode.srcIn),
                          ),
                        )),
              prefixIconConstraints: BoxConstraints(
                  minHeight: Dimens.height_15, minWidth: Dimens.width_15),
              suffixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.padding_10),
                child: suffix,
              ),
              suffixIconConstraints: BoxConstraints(
                minHeight: Dimens.height_20,
                minWidth: Dimens.width_20,
              ),
              counterText: ""),
          keyboardType: keyboardType ?? TextInputType.text,
          cursorColor: blackColor,
          onChanged: onchanged ?? (val) {},
          onTap: onTap ?? () {},
          validator: validator,
          autovalidateMode: autoValidate!
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.onUserInteraction,
        )
      ],
    );
  }
}

