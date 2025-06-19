import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_textfield.dart';
import 'package:provider/provider.dart';

import '../../helper/dimens.dart';
import '../../helper/navigation.dart';
import '../../helper/responsive.dart';
import '../../helper/string.dart';
import '../../language/localization/language/languages.dart';
import '../../widgets/app_button.dart';

class VillageDialog extends StatefulWidget {
  Function(String name) onTap;

  VillageDialog(this.onTap);

  @override
  State<VillageDialog> createState() => _VillageDialogState();
}

class _VillageDialogState extends State<VillageDialog> {
  TextEditingController villageNameController = TextEditingController();

  ScrollController scrollController = ScrollController();

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
        child: Consumer<BookingController>(
            builder: (context, bookingStore, snapshot) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
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
                        Languages.of(context)!.village,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.labelSmall!.color,
                          fontFamily: Fonts.medium,
                          fontSize: Dimens.fontSize_16,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          NavigationService.goBack;
                        },
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).textTheme.labelSmall!.color,
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: Dimens.padding_20),
                    height: Dimens.height_1,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                  ),
                  AppTextField(
                    hintText: Languages.of(context)!.enterManually,
                    controller: villageNameController,
                    titleText: '',
                  ),
                  SizedBox(
                    height: Dimens.dimen_20,
                  ),
                  Expanded(
                    child: RawScrollbar(
                      thumbVisibility: true,
                      thumbColor: primaryColor,
                      trackColor: Theme.of(context).textTheme.labelSmall!.color!.withOpacity(0.05),
                      trackVisibility: true,
                      minThumbLength: Dimens.height_40,
                      trackBorderColor: Colors.transparent,
                      radius: Radius.circular(Dimens.radius_20),
                      thickness: 6,
                      controller: scrollController,
                      child: ListView.builder(
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              widget.onTap(bookingStore.villageList[index].trim() ?? '');
                              NavigationService.goBack;
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: Dimens.padding_8),
                              child: Text(
                                bookingStore.villageList[index] ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.labelSmall!.color,
                                  fontFamily: Fonts.medium,
                                  fontSize: Dimens.fontSize_14,
                                ),
                              ),
                            ),
                          );
                        },
                        itemCount: bookingStore.villageList.length,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dimens.dimen_30,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: Languages.of(context)!.submit,
                          onPressed: () {
                            widget.onTap(villageNameController.text);
                            NavigationService.goBack;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
