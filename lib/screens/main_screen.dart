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
import 'package:guruchaya/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../helper/string.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime selectedDate = DateTime.now();

  final Set<String> selected = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var bookingStore = getBookingStore(context);
      bookingStore.getAllBusNumber().then((val) async {
        await getAllBookedSeat();
        await getBookingStore(context).getAllPlace();
        await getBookingStore(context).getAllVillage();
      });
    });
  }

  Widget singleSeat(int seatNo) {
    var bookingStore = getBookingStore(context);
    final isSelected = selected.contains('$seatNo');
    double totalSize = Responsive.isDesktop(context) ? (MediaQuery.of(context).size.width/3.5) : MediaQuery.of(context).size.width - Dimens.padding_40;
    double boxSize = totalSize / 7;
    bool isAlreadyBook = bookingStore.checkAlreadyBook(seatNo.toString());
    Booking? bookingInfo = bookingStore.getBookingInfo(seatNo.toString());
    return GestureDetector(
      onTap: () {
        if (isAlreadyBook) {
          AppDialog.passengerDetailsDialog(
            context,
            onCancel: (bool? isSplit, String? splitSeatNumber) async {
              await bookingStore.deleteBooking(
                  busNumber: bookingStore.selectedBusNumber,
                  seatNumber: seatNo.toString(),
                  date: DateFormat('dd-MM-yyyy').format(selectedDate));
              getAllBookedSeat();
            },
            onSubmit: (name, place, number, village, cash, pending,
                secondaryMobile, isSplit, splitSeatNumber) async {
              await bookingStore.updateBooking(
                  id: bookingInfo!.id!,
                  fullName: name,
                  villageName: village,
                  place: place,
                  cash: cash,
                  mobileNumber: number,
                  pendingAmount: pending,
                  secondaryMobileNumber: secondaryMobile);
              getAllBookedSeat();
            },
            booking: bookingInfo,
          );
        } else {
          setState(() {
            isSelected ? selected.remove('$seatNo') : selected.add('$seatNo');
          });
        }
      },
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: isAlreadyBook
              ? primaryColor
              : isSelected
                  ? skyBlue
                  : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          '$seatNo',
          style: TextStyle(
            color: isSelected || isAlreadyBook
                ? Theme.of(context).textTheme.labelMedium!.color
                : Theme.of(context).textTheme.labelSmall!.color,
            fontSize: Dimens.fontSize_14,
            fontFamily: Fonts.medium,
          ),
        ),
      ),
    );
  }

  Widget doubleSeat(String id, List<int> seats) {
    var bookingStore = getBookingStore(context);
    double totalSize = Responsive.isDesktop(context) ? (MediaQuery.of(context).size.width/3.5) : MediaQuery.of(context).size.width - Dimens.padding_40;
    double boxSize = totalSize / 7;
    final isSelected = selected.contains(id);
    bool isAlreadyBook = bookingStore.checkAlreadyBook(id);
    bool isSplit = bookingStore.checkIsSplit(id);
    List splitSeatNo = bookingStore.getSplitSeatNo(id);
    Booking? bookingInfo = bookingStore.getBookingInfo(id);
    return GestureDetector(
      onTap: () {
        if (isAlreadyBook) {
          AppDialog.passengerDetailsDialog(
            context,
            onCancel: (bool? isSplit, String? splitSeatNumber) async {
              await bookingStore.deleteBooking(
                  busNumber: bookingStore.selectedBusNumber,
                  seatNumber: ((isSplit ?? false) &&
                          splitSeatNumber != null &&
                          splitSeatNumber.isNotEmpty)
                      ? splitSeatNumber
                      : id,
                  date: DateFormat('dd-MM-yyyy').format(selectedDate));
              getAllBookedSeat();
            },
            onSubmit: (name, place, number, village, cash, amount,
                secondaryNumber, isSplit, splitSeatNumber) async {
              print("splitSeatNumber : $splitSeatNumber");
              Booking? booking = bookingStore.bookingList
                  .where((b) => b.seatNumber == splitSeatNumber)
                  .firstOrNull;
              if (booking == null && splitSeatNumber != null) {
                await bookingStore.bookSeat(
                  busNumber: bookingStore.selectedBusNumber,
                  seatNumber: splitSeatNumber,
                  date: DateFormat('dd-MM-yyyy').format(selectedDate),
                  fullName: name,
                  place: place,
                  cash: cash,
                  mobileNumber: number,
                  villageName: village,
                  pending: amount,
                  secondaryNumber: secondaryNumber,
                  isSplit: isSplit ?? false,
                );
              } else {
                await bookingStore.updateBooking(
                  id: ((isSplit ?? false) &&
                          splitSeatNumber != null &&
                          splitSeatNumber.isNotEmpty)
                      ? booking!.id!
                      : bookingInfo!.id!,
                  fullName: name,
                  villageName: village,
                  place: place,
                  cash: cash,
                  mobileNumber: number,
                  pendingAmount: amount,
                  secondaryMobileNumber: secondaryNumber,
                  isSplit: isSplit ?? false,
                );
              }
              getAllBookedSeat();
            },
            booking: bookingInfo,
            isSplitOption: isSplit,
            seatNo: id,
            selectedSplitSeatNo: splitSeatNo.isEmpty ? null : splitSeatNo.first,
          );
        } else {
          setState(() {
            isSelected ? selected.remove(id) : selected.add(id);
          });
        }
      },
      child: Container(
        width: boxSize * 1.75,
        height: boxSize,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: double.infinity,
                decoration: BoxDecoration(
                    color: getSelectedBoxColor(isSplit, splitSeatNo,
                        isAlreadyBook, isSelected, seats[0].toString()),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8))),
                child: Text(
                  '${seats[0]}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: getSelectedTextColor(isSplit, splitSeatNo,
                          isAlreadyBook, isSelected, seats[0].toString()),
                      fontSize: Dimens.fontSize_14,
                      fontFamily: Fonts.medium),
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                height: double.infinity,
                decoration: BoxDecoration(
                    color: getSelectedBoxColor(isSplit, splitSeatNo,
                        isAlreadyBook, isSelected, seats[1].toString()),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                child: Text(
                  '${seats[1]}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: getSelectedTextColor(isSplit, splitSeatNo,
                          isAlreadyBook, isSelected, seats[1].toString()),
                      fontSize: Dimens.fontSize_14,
                      fontFamily: Fonts.medium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? getSelectedBoxColor(bool isSplit, List splitSeatNo,
      bool isAlreadySelected, bool isSelected, String seat) {
    if (isSplit) {
      if (splitSeatNo.contains(seat)) {
        return primaryColor;
      } else {
        return Colors.grey[300];
      }
    } else {
      if (isAlreadySelected) {
        return primaryColor;
      } else if (isSelected) {
        return skyBlue;
      } else {
        return Colors.grey[300];
      }
    }
  }

  Color? getSelectedTextColor(bool isSplit, List splitSeatNo,
      bool isAlreadySelected, bool isSelected, String seat) {
    if (isSplit) {
      if (splitSeatNo.contains(seat)) {
        return Theme.of(context).textTheme.labelMedium!.color;
      } else {
        return Theme.of(context).textTheme.labelSmall!.color;
      }
    } else {
      if (isAlreadySelected) {
        return Theme.of(context).textTheme.labelMedium!.color;
      } else if (isSelected) {
        return Theme.of(context).textTheme.labelMedium!.color;
      } else {
        return Theme.of(context).textTheme.labelSmall!.color;
      }
    }
  }

  Widget seatRow({
    required int single1,
    required int single2,
    required int doubleLower1,
    required int doubleLower2,
    required int doubleUpper1,
    required int doubleUpper2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Single seats on the left
        Row(
          children: [
            singleSeat(single1),
            SizedBox(
              width: Dimens.width_10,
            ),
            singleSeat(single2),
          ],
        ),
        // Spacer (empty space in middle)
        SizedBox(width: 30),
        // Double berths on right (side by side)
        Row(
          children: [
            doubleSeat(
                '$doubleLower1-$doubleLower2', [doubleLower1, doubleLower2]),
            SizedBox(
              width: Dimens.width_10,
            ),
            doubleSeat(
                '$doubleUpper1-$doubleUpper2', [doubleUpper1, doubleUpper2]),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalSize = Responsive.isDesktop(context) ? (MediaQuery.of(context).size.width/3.5) : MediaQuery.of(context).size.width - Dimens.padding_40;
    double boxSize = totalSize / 7;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BookingController>(
          builder: (context, bookingStore, snapshot) {
        return Stack(
          children: [
            SafeArea(
              child: MediaQuery(
                data: MediaQueryData(
                  textScaleFactor: 1.0,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.padding_20),
                  child: Column(
                    crossAxisAlignment: Responsive.isDesktop(context) ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimens.padding_20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(Images.guruchhaya,height: Dimens.height_30,),
                            InkWell(
                              onTap: () {
                                NavigationService.navigateTo(Routes.setting);
                              },
                              child: Icon(
                                Icons.settings,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(Duration(days: 14)),
                                lastDate: DateTime.now().add(Duration(days: 30)),
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
                                  getAllBookedSeat();
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
                                    DateFormat('dd/MM/yyyy').format(selectedDate),
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
                            width: Dimens.width_120,
                            child: AppDropDown(
                              selectedItem: bookingStore.selectedBusNumber,
                              items: bookingStore.busNumberList,
                              onItemSelected: (val) {
                                selected.clear();
                                bookingStore.changeBusNumber(val);
                                getAllBookedSeat();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Dimens.height_20,
                      ),
                      SizedBox(
                        width: Responsive.isDesktop(context) ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            headerTile(
                              boxSize: boxSize,
                              title: Languages.of(context)!.upper,
                            ),
                            SizedBox(
                              width: Dimens.width_10,
                            ),
                            headerTile(
                              boxSize: boxSize,
                              title: Languages.of(context)!.lower,
                            ),
                            Expanded(child: SizedBox()),
                            headerTile(
                              boxSize: boxSize * 1.75,
                              title: Languages.of(context)!.upper,
                            ),
                            SizedBox(
                              width: Dimens.width_10,
                            ),
                            headerTile(
                              boxSize: boxSize * 1.75,
                              title: Languages.of(context)!.lower,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Dimens.height_10,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: Responsive.isDesktop(context) ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                          child: RefreshIndicator(
                            onRefresh: () async {
                              selected.clear();
                              await getAllBookedSeat();
                            },
                            child: ListView.separated(
                              physics: AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                int pos = index * 6;
                                return seatRow(
                                  single1: pos + 1,
                                  single2: pos + 2,
                                  doubleLower1: pos + 3,
                                  doubleLower2: pos + 4,
                                  doubleUpper1: pos + 5,
                                  doubleUpper2: pos + 6,
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: Dimens.height_10,
                                );
                              },
                              itemCount: 6,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: Responsive.isDesktop(context) ? MainAxisAlignment.center : MainAxisAlignment.start,
                        children: [
                          Container(
                            height: Dimens.height_20,
                            width: Dimens.height_20,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(
                            width: Dimens.width_10,
                          ),
                          Text(
                            Languages.of(context)!.booked,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.labelSmall!.color,
                              fontSize: Dimens.fontSize_14,
                            ),
                          ),
                          SizedBox(
                            width: Dimens.width_30,
                          ),
                          Container(
                            height: Dimens.height_20,
                            width: Dimens.height_20,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          SizedBox(
                            width: Dimens.width_10,
                          ),
                          Text(
                            Languages.of(context)!.available,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.labelSmall!.color,
                              fontSize: Dimens.fontSize_14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Dimens.height_20,
                      ),
                      if (bookingStore.bookingList.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: Dimens.padding_10),
                          child: InkWell(
                            onTap: () {
                              AppDialog.changeBusNumberDialog(
                                context,
                                onSubmit: (changeNumber) async {
                                  await bookingStore.changeAllBookingBusNumber(
                                    oldBusNumber: bookingStore.selectedBusNumber,
                                    newBusNumber: changeNumber,
                                    date: DateFormat("dd-MM-yyyy")
                                        .format(selectedDate),
                                  );
                                  getAllBookedSeat();
                                },
                                currentBusNumber: bookingStore.selectedBusNumber,
                              );
                            },
                            child: Text(
                              Languages.of(context)!.changeBusNumberForAllBooking,
                              style: TextStyle(
                                  color: skyBlue,
                                  fontSize: Dimens.fontSize_14,
                                  fontFamily: Fonts.semiBold,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: skyBlue),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(bottom: Dimens.padding_10),
                        child: InkWell(
                          onTap: () {
                            AppDialog.driverDetailsDialog(context,bookingStore.selectedBusNumber);
                          },
                          child: Text(
                            "${Languages.of(context)!.driver} ${Languages.of(context)!.details}",
                            style: TextStyle(
                                color: skyBlue,
                                fontSize: Dimens.fontSize_14,
                                fontFamily: Fonts.semiBold,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: skyBlue),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: Languages.of(context)!.bookTicket,
                              onPressed: () {
                                if (selected.isEmpty) {
                                  AlertSnackBar.error(
                                      Languages.of(context)!.pleaseSelectSeat);
                                } else {
                                  String? seatNo;
                                  bool isSplitOption = false;
                                  if (selected.length == 1 &&
                                      selected.first.contains("-")) {
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
                                          busNumber: bookingStore.selectedBusNumber,
                                          seatNumber: (isSplit ?? false)
                                              ? splitSeatNumber!
                                              : seatNumber,
                                          date: DateFormat('dd-MM-yyyy')
                                              .format(selectedDate),
                                          fullName: name,
                                          place: place,
                                          cash: i == 0 ? cash : "0",
                                          mobileNumber: number,
                                          villageName: village,
                                          pending: i == 0 ? pending : "0",
                                          secondaryNumber: secondaryNumber,
                                          isSplit: isSplit ?? false,
                                        );
                                        getAllBookedSeat();
                                      }
                                      selected.clear();
                                    },
                                  );
                                }
                              },
                              width: Responsive.isDesktop(context) ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                            ),
                          ),
                          if (bookingStore.bookingList.isNotEmpty)
                            Expanded(
                              child: AppButton(
                                label: Languages.of(context)!.allBooking,
                                margin: EdgeInsets.only(left: Dimens.padding_10),
                                bgColor: Colors.transparent,
                                isBorder: true,
                                textColor: primaryColor,
                                width: Responsive.isDesktop(context) ? MediaQuery.of(context).size.width / 3 : MediaQuery.of(context).size.width,
                                onPressed: () {
                                  NavigationService.navigateTo(Routes.allBooking,
                                      arguments: {
                                        'busNumber': bookingStore.selectedBusNumber,
                                        'date': DateFormat('dd/MM/yyyy')
                                            .format(selectedDate)
                                      });
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: Dimens.height_30,
                      ),
                    ],
                  ),
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

  getAllBookedSeat() async {
    var bookingStore = getBookingStore(context);
    await getBookingStore(context).getBookedSeats(
        bookingStore.selectedBusNumber,
        DateFormat('dd-MM-yyyy').format(selectedDate));
  }
}
