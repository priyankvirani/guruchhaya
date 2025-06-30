import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/snackbar.dart';
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
import '../../widgets/app_drop_down.dart';

class ChangeBusNumberDialog extends StatefulWidget {
  String currentBusNumber;
  Function(String changeNumber) onTap;

  ChangeBusNumberDialog(
    this.currentBusNumber,
    this.onTap,
  );

  @override
  State<ChangeBusNumberDialog> createState() => _ChangeBusNumberDialogState();
}

class _ChangeBusNumberDialogState extends State<ChangeBusNumberDialog> {
  TextEditingController changeBusNumberController = TextEditingController();

  String changeNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    double totalSize = MediaQuery.of(context).size.width - Dimens.padding_40;
    double boxSize = totalSize / 7;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: Dimens.padding_20),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: MediaQuery(
          data: MediaQueryData(
            textScaleFactor: 1.0,
          ),
          child: SizedBox(
            width: Responsive.isDesktop(context) ? Dimens.dimen_400 : MediaQuery.of(context).size.width,
            child: Consumer<BookingController>(
                builder: (context, bookingStore, snapshot) {
              return SingleChildScrollView(
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
                            Languages.of(context)!.changeBusNumber,
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
                      Text(
                        Languages.of(context)!.selectBusNumber,
                        style: TextStyle(
                          fontSize: Dimens.fontSize_12,
                          fontFamily: Fonts.semiBold,
                          color: Theme.of(context).textTheme.labelSmall!.color,
                        ),
                      ),
                      SizedBox(
                        height: Dimens.height_6,
                      ),
                      AppDropDown(
                        selectedItem: changeNumber,
                        items: bookingStore.busNumberList
                            .where((busNumber) =>
                                busNumber != bookingStore.selectedBusNumber)
                            .toList(),
                        onItemSelected: (val) {
                          setState(() {
                            changeNumber = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: Dimens.height_20,
                      ),
                      AppButton(
                        label: Languages.of(context)!.submit,
                        onPressed: () {
                          if (changeNumber.isEmpty) {
                            AlertSnackBar.error(Languages.of(context)!
                                .selectBusNumberYouWantToChange);
                          } else {
                            AppDialog.confirmationDialog(context,
                                title: Languages.of(context)!.changeBusNumber,
                                msg: Languages.of(context)!
                                    .areYouSureYouWantToChangeThisBusNumberForAllBooking,
                                onTap: (val) {
                              widget.onTap(changeNumber);
                              NavigationService.goBack;
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
