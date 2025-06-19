import 'package:flutter/material.dart';

import '../../helper/colors.dart';
import '../../helper/dimens.dart';
import '../../helper/responsive.dart';
import '../../helper/string.dart';
import '../../language/language_data.dart';
import '../../language/localization/language/languages.dart';
import '../../language/localization/local_constant.dart';

class LanguageDialog extends StatefulWidget {
  Function(LanguageData value) onTap;

  LanguageDialog(this.onTap);

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  String languageCode = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getLocale().then((value) {
        setState(() {
          languageCode = value.languageCode;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        width: Responsive.isDesktop(context) ? Dimens.dimen_400 : MediaQuery.of(context).size.width,
        child: Padding(
          padding: EdgeInsets.all(Dimens.padding_20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Languages.of(context)!.language,
                style: TextStyle(
                  color: Theme.of(context).textTheme.labelSmall!.color,
                  fontFamily: Fonts.semiBold,
                  fontSize: Dimens.fontSize_14,
                ),
              ),
              SizedBox(
                height: Dimens.height_20,
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: Dimens.height_15,
                  );
                },
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      widget.onTap(LanguageData.languageList()[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(Dimens.padding_10),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimens.circularRadius_10),
                          border: Border.all(
                              color: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .color!
                                  .withOpacity(0.2))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LanguageData.languageList()[index].name,
                            style: TextStyle(
                                fontSize: Dimens.fontSize_11,
                                fontFamily: Fonts.medium,
                                color: primaryColor),
                          ),
                          if (languageCode ==
                              LanguageData.languageList()[index].languageCode)
                             Icon(
                              Icons.check_circle,
                              color: primaryColor,
                            )
                        ],
                      ),
                    ),
                  );
                },
                itemCount: LanguageData.languageList().length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
