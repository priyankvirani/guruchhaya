import 'package:flutter/material.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/responsive.dart';
import 'package:guruchaya/helper/routes.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_button.dart';
import 'package:guruchaya/widgets/app_drop_down.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:guruchaya/widgets/booking_display.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../helper/string.dart';

class AllBusBookingScreen extends StatefulWidget {
  String selectedDate;

  AllBusBookingScreen(this.selectedDate);

  @override
  State<AllBusBookingScreen> createState() => _AllBusBookingScreenState();
}

class _AllBusBookingScreenState extends State<AllBusBookingScreen> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        selectedDate = DateTime.parse(widget.selectedDate);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(builder: (context, constraints) {
        int crossAxisCount = 2;

        if (constraints.maxWidth >= 600) {
          crossAxisCount = 3;
        }
        if (constraints.maxWidth >= 1500) {
          crossAxisCount = 4;
        }
        return Consumer<BookingController>(
            builder: (context, bookingStore, snapshot) {
          return Stack(
            children: [
              SafeArea(
                child: MediaQuery(
                  data: MediaQueryData(
                    textScaleFactor: 1.0,
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: Dimens.padding_20),
                    child: Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: Dimens.padding_20),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => NavigationService.goBack,
                                child: Image.asset(
                                  Images.back,
                                  height: Dimens.height_25,
                                ),
                              ),
                              SizedBox(
                                width: Dimens.width_20,
                              ),
                              Image.asset(
                                Images.guruchhaya,
                                height: Dimens.height_30,
                              ),
                              Expanded(
                                child: SizedBox(),
                              ),
                              // if (selectedDate != null)
                              //   InkWell(
                              //     onTap: () {
                              //       showDatePicker(
                              //         context: context,
                              //         initialDate: selectedDate,
                              //         firstDate: DateTime.now()
                              //             .subtract(Duration(days: 14)),
                              //         lastDate: DateTime.now()
                              //             .add(Duration(days: 30)),
                              //         builder: (context, child) {
                              //           final mediaQuery =
                              //               MediaQuery.of(context);
                              //           return MediaQuery(
                              //             data: mediaQuery.copyWith(
                              //               textScaleFactor: 1.0,
                              //             ),
                              //             child: child ?? const SizedBox(),
                              //           );
                              //         },
                              //       ).then((pickedDate) {
                              //         if (pickedDate != null &&
                              //             pickedDate != selectedDate) {
                              //           setState(() {
                              //             selectedDate = pickedDate;
                              //           });
                              //         }
                              //       });
                              //     },
                              //     child: Container(
                              //       padding: EdgeInsets.symmetric(
                              //           horizontal: Dimens.padding_20,
                              //           vertical: Dimens.padding_15),
                              //       decoration: BoxDecoration(
                              //           border: Border.all(
                              //             color: primaryColor,
                              //           ),
                              //           borderRadius: BorderRadius.circular(
                              //               Dimens.circularRadius_12)),
                              //       child: Row(
                              //         children: [
                              //           Text(
                              //             DateFormat('dd/MM/yyyy')
                              //                 .format(selectedDate!),
                              //             style: TextStyle(
                              //               color: Theme.of(context)
                              //                   .textTheme
                              //                   .labelSmall!
                              //                   .color,
                              //               fontSize: Dimens.fontSize_14,
                              //               fontFamily: Fonts.medium,
                              //             ),
                              //           ),
                              //           SizedBox(
                              //             width: Dimens.dimen_10,
                              //           ),
                              //           Image.asset(
                              //             Images.dropDown,
                              //             height: Dimens.height_15,
                              //             width: Dimens.height_15,
                              //             color: Theme.of(context)
                              //                 .textTheme
                              //                 .labelSmall!
                              //                 .color,
                              //           )
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        // if (selectedDate != null)
                        //   Expanded(
                        //     child: GridView.builder(
                        //       gridDelegate:
                        //           SliverGridDelegateWithFixedCrossAxisCount(
                        //         crossAxisCount: crossAxisCount,
                        //         crossAxisSpacing: Dimens.width_15,
                        //         mainAxisSpacing: Dimens.width_15,
                        //         childAspectRatio: 1,
                        //       ),
                        //       itemBuilder: (context, index) {
                        //         return BookingDisplayWidget(
                        //           bookingStore.busNumberList[index],
                        //           selectedDate!,
                        //         );
                        //       },
                        //       itemCount: bookingStore.busNumberList.length,
                        //     ),
                        //   ),
                        if (selectedDate != null)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Wrap(
                                runAlignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                spacing: Dimens.width_30,
                                runSpacing: Dimens.width_30,
                                children: bookingStore.busNumberList.map((item){
                                  return BookingDisplayWidget(
                                    item,
                                    selectedDate!,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: Dimens.height_10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              LoadingWithBackground(bookingStore.loading)
            ],
          );
        });
      }),
    );
  }

  headerTile({required double boxSize, required String title}) {
    return SizedBox(
      width: boxSize,
      child: Center(
        child: FittedBox(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.labelSmall!.color,
              fontFamily: Fonts.semiBold,
              fontSize: Dimens.fontSize_12,
            ),
          ),
        ),
      ),
    );
  }
}
