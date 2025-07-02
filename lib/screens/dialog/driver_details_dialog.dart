import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/shared_preference.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_textfield.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../helper/dimens.dart';
import '../../helper/navigation.dart';
import '../../helper/responsive.dart';
import '../../helper/string.dart';
import '../../language/localization/language/languages.dart';
import '../../widgets/app_button.dart';

class DriverDetailsDialog extends StatefulWidget {
  String busNumber;

  DriverDetailsDialog(this.busNumber);

  @override
  State<DriverDetailsDialog> createState() => _DriverDetailsDialogState();
}

class _DriverDetailsDialogState extends State<DriverDetailsDialog> {
  TextEditingController driverNameController = TextEditingController();
  TextEditingController conductorNameController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController toVillageNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Map<String, dynamic>? data = await Preferences.getDriverDetails(widget.busNumber);
      if(data != null){
        driverNameController.text = data['driverName'] ?? '';
        conductorNameController.text = data['conductorName'] ?? '';
        timeController.text = data['time'] ?? '';
        toVillageNameController.text = data['toVillageName'] ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
            width: Responsive.isDesktop(context)
                ? Dimens.dimen_400
                : MediaQuery.of(context).size.width,
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
                            Languages.of(context)!.details,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.labelSmall!.color,
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
                              color:
                                  Theme.of(context).textTheme.labelSmall!.color,
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin:
                            EdgeInsets.symmetric(vertical: Dimens.padding_20),
                        height: Dimens.height_1,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                      ),
                      AppTextField(
                        hintText: Languages.of(context)!.driver,
                        controller: driverNameController,
                        titleText: '',
                      ),
                      SizedBox(
                        height: Dimens.dimen_16,
                      ),
                      AppTextField(
                        hintText: Languages.of(context)!.conductor,
                        controller: conductorNameController,
                        titleText: '',
                      ),
                      SizedBox(
                        height: Dimens.dimen_16,
                      ),
                      AppTextField(
                        hintText: Languages.of(context)!.time,
                        controller: timeController,
                        titleText: '',
                      ),
                      SizedBox(
                        height: Dimens.dimen_16,
                      ),
                      AppTextField(
                        hintText: Languages.of(context)!.suratTo,
                        controller: toVillageNameController,
                        titleText: '',
                      ),
                      SizedBox(
                        height: Dimens.dimen_16,
                      ),
                      AppButton(
                        label: Languages.of(context)!.submit,
                        width: double.infinity,
                        onPressed: () {
                          Preferences.saveDriverDetails(widget.busNumber, {
                            'driverName': driverNameController.text,
                            'conductorName': conductorNameController.text,
                            'time': timeController.text,
                            'toVillageName': toVillageNameController.text,
                          });
                          AlertSnackBar.success("${Languages.of(context)!.details} ${Languages.of(context)!.saved}");
                          NavigationService.goBack;
                        },
                      ),
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
