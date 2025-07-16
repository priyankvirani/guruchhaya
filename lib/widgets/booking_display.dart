import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/routes.dart';
import 'package:guruchaya/helper/string.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helper/app_dialog.dart';
import '../helper/navigation.dart';
import '../helper/responsive.dart';
import '../language/localization/language/languages.dart';
import '../model/booking.dart';
import '../provider/booking_provider.dart';

class BookingDisplayWidget extends StatefulWidget {
  String busNumber;
  DateTime selectedDate;
  Function(Set<String>) onChangeSeat;

  BookingDisplayWidget({required this.busNumber,required this.selectedDate,required this.onChangeSeat});

  @override
  State<BookingDisplayWidget> createState() => _BookingDisplayWidgetState();
}

class _BookingDisplayWidgetState extends State<BookingDisplayWidget> {

  List<Booking> bookingList = [];

  final Set<String> selected = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {

    });
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Booking>>(
      stream: streamBookingSeat(
          widget.busNumber,
          DateFormat('dd-MM-yyyy').format(widget.selectedDate)),
      builder: (context, snapshot) {
        bookingList = snapshot.data ?? [];
        return Container(
          padding: EdgeInsets.only(
              left: Dimens.dimen_20,
              right: Dimens.dimen_20,
              bottom: Dimens.dimen_20),
          decoration: BoxDecoration(
            border: Border.all(color: skyBlue, width: Dimens.dimen_1),
            borderRadius: BorderRadius.circular(
              Dimens.circularRadius_12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Dimens.padding_20, vertical: Dimens.padding_10),
                    decoration: BoxDecoration(
                      color: skyBlue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(Dimens.circularRadius_12),
                        bottomRight: Radius.circular(
                          Dimens.circularRadius_12,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.busNumber,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.labelMedium!.color,
                        fontSize: Dimens.fontSize_14,
                        fontFamily: Fonts.medium,
                      ),
                    ),
                  ),
                  SizedBox(width: Dimens.width_20,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Dimens.height_5,),
                      if (bookingList.isNotEmpty)
                        InkWell(
                          onTap: () {
                            AppDialog.changeBusNumberDialog(
                              context,
                              onSubmit: (changeNumber) async {
                                await getBookingStore(context)
                                    .changeAllBookingBusNumber(
                                  oldBusNumber: widget.busNumber,
                                  newBusNumber: changeNumber,
                                  date: DateFormat("dd-MM-yyyy").format(widget.selectedDate),
                                );
                              },
                              currentBusNumber: widget.busNumber,
                            );
                          },
                          child: Text(
                            Languages.of(context)!
                                .changeBusNumberForAllBooking,
                            style: TextStyle(
                                color: skyBlue,
                                fontSize: Dimens.fontSize_14,
                                fontFamily: Fonts.semiBold,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: skyBlue),
                          ),
                        ),
                      InkWell(
                        onTap: () {
                          AppDialog.driverDetailsDialog(
                              context, widget.busNumber);
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
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  if (bookingList.isNotEmpty)
                  InkWell(
                    onTap: (){
                      NavigationService.navigateTo(
                          Routes.allBooking,
                          arguments: {
                            'busNumber': widget.busNumber,
                            'date': DateFormat('dd/MM/yyyy')
                                .format(widget.selectedDate)
                          });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimens.padding_20, vertical: Dimens.padding_10),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(Dimens.circularRadius_12),
                          bottomRight: Radius.circular(
                            Dimens.circularRadius_12,
                          ),
                        ),
                      ),
                      child: Text(
                        Languages.of(context)!.allBooking,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.labelMedium!.color,
                          fontSize: Dimens.fontSize_14,
                          fontFamily: Fonts.medium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  int pos = index * 6;
                  if (index == 6) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        singleSeat("K1"),
                        singleSeat('K2'),
                        singleSeat("K3"),
                        singleSeat('K4'),
                        singleSeat('K5'),
                        singleSeat('K6'),
                      ],
                    );
                  } else {
                    return seatRow(
                      single1: pos + 1,
                      single2: pos + 2,
                      doubleLower1: pos + 3,
                      doubleLower2: pos + 4,
                      doubleUpper1: pos + 5,
                      doubleUpper2: pos + 6,
                    );
                  }
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: Dimens.height_5,
                  );
                },
                itemCount: 7,
              ),
            ],
          ),
        );
      }
    );
  }

  Widget singleSeat(String seatNo) {
    bool isAlreadyBook = checkAlreadyBook(seatNo.toString());
    final isSelected = selected.contains(seatNo);
    Booking? bookingInfo = getBookingInfo(seatNo.toString());
    double totalWidth =
        ((MediaQuery.of(context).size.width - Dimens.dimen_200) / 3) -
            Dimens.width_50;
    double boxSize = (totalWidth - Dimens.dimen_20) / 7;
    return GestureDetector(
      onTap: () {
        var bookingStore = getBookingStore(context);
        if (isAlreadyBook) {
          AppDialog.passengerDetailsDialog(
            context,
            onCancel: (bool? isSplit, String? splitSeatNumber) async {
              await bookingStore.deleteBooking(
                  busNumber: widget.busNumber,
                  seatNumber: seatNo.toString(),
                  date: DateFormat('dd-MM-yyyy').format(widget.selectedDate));
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
            },
            booking: bookingInfo,
          );
        }else {
          setState(() {
            isSelected ? selected.remove(seatNo) : selected.add(seatNo);
          });
          widget.onChangeSeat(selected);
        }
      },
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: isAlreadyBook ? primaryColor : isSelected
              ? skyBlue
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          seatNo,
          style: TextStyle(
            color: isSelected || isAlreadyBook
                ? Theme.of(context).textTheme.labelMedium!.color
                : Theme.of(context).textTheme.labelSmall!.color,
            fontSize: Dimens.fontSize_12,
            fontFamily: Fonts.medium,
          ),
        ),
      ),
    );
  }

  Widget doubleSeat(String id, List<String> seats) {
    bool isAlreadyBook = checkAlreadyBook(id);
    bool isSplit = checkIsSplit(id);
    final isSelected = selected.contains(id);
    List splitSeatNo = getSplitSeatNo(id);
    Booking? bookingInfo = getBookingInfo(id);
    double totalWidth =
        ((MediaQuery.of(context).size.width - Dimens.dimen_200) / 3) -
            Dimens.width_50;
    double boxSize = (totalWidth - Dimens.dimen_20) / 7;
    return GestureDetector(
      onTap: () {
        var bookingStore = getBookingStore(context);
        if (isAlreadyBook) {
          AppDialog.passengerDetailsDialog(
            context,
            onCancel: (bool? isSplit, String? splitSeatNumber) async {
              await bookingStore.deleteBooking(
                  busNumber: widget.busNumber,
                  seatNumber: ((isSplit ?? false) &&
                          splitSeatNumber != null &&
                          splitSeatNumber.isNotEmpty)
                      ? splitSeatNumber
                      : id,
                  date: DateFormat('dd-MM-yyyy').format(widget.selectedDate));
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
                  date: DateFormat('dd-MM-yyyy').format(widget.selectedDate),
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
            },
            booking: bookingInfo,
            isSplitOption: isSplit,
            seatNo: id,
            selectedSplitSeatNo: splitSeatNo.isEmpty ? null : splitSeatNo.first,
          );
        }else {
          setState(() {
            isSelected ? selected.remove(id) : selected.add(id);
          });
          widget.onChangeSeat(selected);
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
                        isAlreadyBook,isSelected, seats[0].toString()),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8))),
                child: Text(
                  seats[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: getSelectedTextColor(isSplit, splitSeatNo,
                          isAlreadyBook,isSelected,seats[0].toString()),
                      fontSize: Dimens.fontSize_12,
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
                        isAlreadyBook,isSelected, seats[1].toString()),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                child: Text(
                  seats[1],
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: getSelectedTextColor(isSplit, splitSeatNo,
                          isAlreadyBook,isSelected, seats[1].toString()),
                      fontSize: Dimens.fontSize_12,
                      fontFamily: Fonts.medium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
        Row(
          children: [
            singleSeat(single1.toString()),
            SizedBox(
              width: Dimens.width_5,
            ),
            singleSeat(single2.toString()),
          ],
        ),
        Row(
          children: [
            doubleSeat('$doubleLower1-$doubleLower2',
                [doubleLower1.toString(), doubleLower2.toString()]),
            SizedBox(
              width: Dimens.width_5,
            ),
            doubleSeat('$doubleUpper1-$doubleUpper2',
                [doubleUpper1.toString(), doubleUpper2.toString()]),
          ],
        ),
      ],
    );
  }

  Color? getSelectedBoxColor(
      bool isSplit, List splitSeatNo, bool isAlreadySelected,bool isSelected, String seat) {
    if (isSplit) {
      if (splitSeatNo.contains(seat)) {
        return primaryColor;
      } else {
        return Colors.grey[300];
      }
    } else {
      if (isAlreadySelected) {
        return primaryColor;
      }else if (isSelected) {
        return skyBlue;
      } else {
        return Colors.grey[300];
      }
    }
  }

  Color? getSelectedTextColor(
      bool isSplit, List splitSeatNo, bool isAlreadySelected,bool isSelected, String seat) {
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

  bool checkAlreadyBook(String seatNumber) {
    for (var element in bookingList) {
      if (element.isSplit ?? false) {
        if (seatNumber.contains("-")) {
          String seatA = seatNumber.split('-')[0].trim();
          String seatB = seatNumber.split('-')[1].trim();
          if (element.seatNumber!.trim() == seatA ||
              element.seatNumber!.trim() == seatB) {
            return true;
          }
        }
      } else {
        if (element.seatNumber!.trim() == seatNumber.trim()) {
          return true;
        }
      }
    }
    return false;
  }

  Booking? getBookingInfo(String seatNumber) {
    for (var element in bookingList) {
      if (element.isSplit ?? false) {
        if (seatNumber.contains("-")) {
          String seatA = seatNumber.split('-')[0].trim();
          String seatB = seatNumber.split('-')[1].trim();
          if (element.seatNumber!.trim() == seatA ||
              element.seatNumber!.trim() == seatB) {
            return element;
          }
        }
      } else {
        if (element.seatNumber!.trim() == seatNumber.trim()) {
          return element;
        }
      }
    }
    return null;
  }

  bool checkIsSplit(String seatNumber) {
    for (var element in bookingList) {
      if (element.isSplit ?? false) {
        if (seatNumber.contains("-")) {
          String seatA = seatNumber.split('-')[0].trim();
          String seatB = seatNumber.split('-')[1].trim();
          if (element.seatNumber!.trim() == seatA ||
              element.seatNumber!.trim() == seatB) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List getSplitSeatNo(String seatNumber) {
    return bookingList
        .where((booking) => booking.isSplit ?? false)
        .expand((booking) {
      String seatA = seatNumber.split('-')[0].trim();
      String seatB = seatNumber.split('-')[1].trim();
      if (booking.seatNumber!.trim() == seatA ||
          booking.seatNumber!.trim() == seatB) {
        return [booking.seatNumber!];
      } else {
        return [];
      }
    }).toList();
  }

  Stream<List<Booking>> streamBookingSeat(String busNumber, String date) async* {
    final supabase = Supabase.instance.client;

    final stream = supabase
        .from('bus_bookings')
        .stream(primaryKey: ['id']) // assuming 'id' is your primary key
        .eq('bus_number', busNumber);


    await for (final response in stream) {
      List<Booking> bookings = response.map((item) => Booking.fromJson(item)).toList();
      bookings = bookings.where((booking) => booking.date == date).toList();
      yield bookings;
    }
  }

}
