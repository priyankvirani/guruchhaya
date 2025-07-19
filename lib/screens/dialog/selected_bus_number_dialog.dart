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

class SelectedBusNumberDialog extends StatefulWidget {

  List<String> selectedNumber;
  Function(List<String> value) onTap;

  SelectedBusNumberDialog(this.selectedNumber,this.onTap);

  @override
  State<SelectedBusNumberDialog> createState() => _SelectedBusNumberDialogState();
}

class _SelectedBusNumberDialogState extends State<SelectedBusNumberDialog> {


  List<String> selectedNumber = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        selectedNumber = widget.selectedNumber;
      });
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
        child: Consumer<BookingController>(
            builder: (context, bookingStore, snapshot) {
          return MediaQuery(
            data: MediaQueryData(
              textScaleFactor: 1.0,
            ),
            child: SizedBox(
              height: Dimens.dimen_550,
              width: Responsive.isDesktop(context) ? Dimens.dimen_220 : MediaQuery.of(context).size.width,
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
                          Languages.of(context)!.selectBusNumber,
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
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(Dimens.circularRadius_50),
                            onTap: (){
                              setState(() {
                                if (selectedNumber.contains(bookingStore.busNumberList[index])) {
                                  selectedNumber.remove(bookingStore.busNumberList[index]);
                                } else {
                                  selectedNumber.add(bookingStore.busNumberList[index]);
                                }
                              });
                            },
                            child: Container(
                              padding:  EdgeInsets.symmetric(
                                  horizontal: Dimens.padding_15,
                                  vertical: Dimens.padding_8),
                              decoration: BoxDecoration(
                                color: selectedNumber.contains(bookingStore.busNumberList[index]) ? primaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(Dimens.circularRadius_50),
                              ),
                              child: Text(
                                bookingStore.busNumberList[index] ?? '',
                                style: TextStyle(
                                  color: selectedNumber.contains(bookingStore.busNumberList[index]) ? whiteColor : blackColor,
                                  fontFamily: Fonts.medium,
                                  fontSize: Dimens.fontSize_14,
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: Dimens.dimen_10,
                          );
                        },
                        itemCount: bookingStore.busNumberList.length,
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
                              widget.onTap(selectedNumber);
                              NavigationService.goBack;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
