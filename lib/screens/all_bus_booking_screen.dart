import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/routes.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_textfield.dart';
import 'package:guruchaya/widgets/booking_display.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../helper/colors.dart';
import '../helper/responsive.dart';
import '../helper/snackbar.dart';
import '../helper/string.dart';
import '../language/localization/language/languages.dart';
import '../widgets/app_button.dart';

class AllBusBookingScreen extends StatefulWidget {
  String selectedDate;

  AllBusBookingScreen(this.selectedDate);

  @override
  State<AllBusBookingScreen> createState() => _AllBusBookingScreenState();
}

class _AllBusBookingScreenState extends State<AllBusBookingScreen> {
  DateTime? selectedDate = DateTime.now();

  List<String> selectedItems = [];

  Map<String, Set<String>> seatMapList = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        selectedDate = DateTime.parse(widget.selectedDate);
        selectedItems = getBookingStore(context)
            .busNumberList
            .sublist(0, 3)
            .map((item) => item.toString())
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BookingController>(
          builder: (context, bookingStore, snapshot) {
        return Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimens.padding_20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          InkWell(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now()
                                    .subtract(Duration(days: 14)),
                                lastDate:
                                    DateTime.now().add(Duration(days: 30)),
                                builder: (context, child) {
                                  final mediaQuery = MediaQuery.of(context);
                                  return MediaQuery(
                                    data: mediaQuery.copyWith(
                                      textScaleFactor: 1.0,
                                    ),
                                    child: child ?? const SizedBox(),
                                  );
                                },
                              ).then((pickedDate) {
                                if (pickedDate != null &&
                                    pickedDate != selectedDate) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimens.padding_20,
                                  vertical: Dimens.padding_15),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      Dimens.circularRadius_12)),
                              child: Row(
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy')
                                        .format(selectedDate!),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .color,
                                      fontSize: Dimens.fontSize_14,
                                      fontFamily: Fonts.medium,
                                    ),
                                  ),
                                  SizedBox(
                                    width: Dimens.dimen_10,
                                  ),
                                  Image.asset(
                                    Images.dropDown,
                                    height: Dimens.height_15,
                                    width: Dimens.height_15,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .color,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Dimens.width_20,
                          ),
                          SizedBox(
                            width: Dimens.width_180,
                            child: AppTextField(
                              titleText: "",
                              onTap: () {
                                AppDialog.selectBusNumbersDialog(context,
                                    selectedNumber: selectedItems,
                                    onSubmit: (val) {
                                  if (val != null) {
                                    setState(() {
                                      selectedItems = val;
                                    });
                                  }
                                });
                              },
                              controller: TextEditingController(
                                  text: selectedItems.join(', ')),
                              suffix: Image.asset(
                                Images.dropDown,
                                height: Dimens.height_15,
                                width: Dimens.height_15,
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                              ),
                              isReadOnly: true,
                              textStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                                fontSize: Dimens.fontSize_14,
                                fontFamily: Fonts.medium,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: Dimens.padding_14,
                                  horizontal: Dimens.padding_18),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimens.height_20,
                    ),
                    if (selectedDate != null)
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 3, // or 3, depending on layout
                          crossAxisSpacing: Dimens.width_20,
                          mainAxisSpacing: Dimens.width_20,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: selectedItems.map((item) {
                            return BookingDisplayWidget(
                              busNumber: item,
                              selectedDate: selectedDate!,
                              onChangeSeat: (seatList) {
                                setState(() {
                                  seatMapList[item] = seatList;
                                });
                                seatMapList.removeWhere((key, value) => value.isEmpty);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(
                      height: Dimens.height_10,
                    ),
                    Row(
                      mainAxisAlignment: Responsive.isDesktop(context)
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Container(
                          height: Dimens.height_15,
                          width: Dimens.height_15,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(
                          width: Dimens.width_10,
                        ),
                        Text(
                          Languages.of(context)!.booked,
                          style: TextStyle(
                            color:
                            Theme.of(context).textTheme.labelSmall!.color,
                            fontSize: Dimens.fontSize_12,
                          ),
                        ),
                        SizedBox(
                          width: Dimens.width_30,
                        ),
                        Container(
                          height: Dimens.height_15,
                          width: Dimens.height_15,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(
                          width: Dimens.width_10,
                        ),
                        Text(
                          Languages.of(context)!.available,
                          style: TextStyle(
                            color:
                            Theme.of(context).textTheme.labelSmall!.color,
                            fontSize: Dimens.fontSize_12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimens.height_10,
                    ),
                    Center(
                      child: AppButton(
                        label: Languages.of(context)!.bookTicket,
                        onPressed: () {
                          if (seatMapList.isEmpty) {
                            AlertSnackBar.error(Languages.of(context)!
                                .pleaseSelectSeat);
                          } else {
                            String busNumber = seatMapList.keys.last;
                            Set<String> selected = seatMapList[busNumber]!;

                            String? seatNo;
                            bool isSplitOption = false;
                            if (selected.length == 1 && selected.first.contains("-")) {
                              isSplitOption = true;
                              seatNo = selected.first;
                            }
                            AppDialog.passengerDetailsDialog(
                              context,
                              isSplitOption: isSplitOption,
                              seatNo: seatNo,
                              onSubmit: (name,
                                  place,
                                  number,
                                  village,
                                  cash,
                                  pending,
                                  secondaryNumber,
                                  isSplit,
                                  splitSeatNumber) async {
                                for (int i = 0; i < selected.length; i++) {
                                  String seatNumber = selected.elementAt(i);
                                  await bookingStore.bookSeat(
                                    busNumber: busNumber,
                                    seatNumber: (isSplit ?? false)
                                        ? splitSeatNumber!
                                        : seatNumber,
                                    date: DateFormat('dd-MM-yyyy')
                                        .format(selectedDate!),
                                    fullName: name,
                                    place: place,
                                    cash: i == 0 ? cash : "0",
                                    mobileNumber: number,
                                    villageName: village,
                                    pending: i == 0 ? pending : "0",
                                    secondaryNumber: secondaryNumber,
                                    isSplit: isSplit ?? false,
                                  );
                                }
                                selected.clear();
                              },
                            );
                          }
                        },
                        width: Responsive.isDesktop(context)
                            ? MediaQuery.of(context).size.width / 3
                            : MediaQuery.of(context).size.width,
                      ),
                    ),
                    SizedBox(
                      height: Dimens.height_20,
                    ),
                  ],
                ),
              ),
            ),
            LoadingWithBackground(bookingStore.loading)
          ],
        );
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
