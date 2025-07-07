import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/string.dart';
import 'package:intl/intl.dart';

import '../helper/app_dialog.dart';
import '../model/booking.dart';
import '../provider/booking_provider.dart';

class BookingDisplayWidget extends StatefulWidget {
  String busNumber;
  DateTime selectedDate;

  BookingDisplayWidget(this.busNumber, this.selectedDate);

  @override
  State<BookingDisplayWidget> createState() => _BookingDisplayWidgetState();
}

class _BookingDisplayWidgetState extends State<BookingDisplayWidget> {
  List<Booking> bookingList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllBooking();
    });
  }

  getAllBooking() async {
    var bookingStore = getBookingStore(context);
    bookingList = await bookingStore.getAllBookingSeat(
        widget.busNumber, DateFormat('dd-MM-yyyy').format(widget.selectedDate));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: Dimens.dimen_18,
          right: Dimens.dimen_18,
          bottom: Dimens.dimen_18),
      decoration: BoxDecoration(
        border: Border.all(color: skyBlue, width: Dimens.dimen_1),
        borderRadius: BorderRadius.circular(
          Dimens.circularRadius_12,
        ),
      ),
      width: Dimens.width_300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: Dimens.padding_20,vertical: Dimens.padding_5),
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
          ),
          SizedBox(
            height: Dimens.height_10,
          ),
          ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              int pos = index * 6;
              if (index == 6) {
                return Row(
                  children: [
                    singleSeat("K1"),
                    SizedBox(
                      width: Dimens.width_5,
                    ),
                    singleSeat('K2'),
                    SizedBox(
                      width: Dimens.width_5,
                    ),
                    singleSeat("K3"),
                    SizedBox(
                      width: Dimens.width_5,
                    ),
                    singleSeat('K4'),
                    SizedBox(
                      width: Dimens.width_5,
                    ),
                    singleSeat('K5'),
                    SizedBox(
                      width: Dimens.width_5,
                    ),
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

  Widget singleSeat(String seatNo) {
    bool isAlreadyBook = checkAlreadyBook(seatNo.toString());
    Booking? bookingInfo = getBookingInfo(seatNo.toString());
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
              getAllBooking();
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
              getAllBooking();
            },
            booking: bookingInfo,
          );
        }
      },
      child: Container(
        width: Dimens.width_35,
        height: Dimens.width_35,
        decoration: BoxDecoration(
          color: isAlreadyBook ? primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          seatNo,
          style: TextStyle(
            color: isAlreadyBook
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
    List splitSeatNo = getSplitSeatNo(id);
    Booking? bookingInfo = getBookingInfo(id);
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
              getAllBooking();
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
              getAllBooking();
            },
            booking: bookingInfo,
            isSplitOption: isSplit,
            seatNo: id,
            selectedSplitSeatNo: splitSeatNo.isEmpty ? null : splitSeatNo.first,
          );
        }
      },
      child: Container(
        width: Dimens.width_70,
        height: Dimens.width_35,
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
                        isAlreadyBook, seats[0].toString()),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8))),
                child: Text(
                  seats[0],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: getSelectedTextColor(isSplit, splitSeatNo,
                          isAlreadyBook, seats[0].toString()),
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
                        isAlreadyBook, seats[1].toString()),
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8))),
                child: Text(
                  seats[1],
                  textAlign: TextAlign.end,
                  style: TextStyle(
                      color: getSelectedTextColor(isSplit, splitSeatNo,
                          isAlreadyBook, seats[1].toString()),
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
        SizedBox(width: Dimens.width_40),
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
      bool isSplit, List splitSeatNo, bool isAlreadySelected, String seat) {
    if (isSplit) {
      if (splitSeatNo.contains(seat)) {
        return primaryColor;
      } else {
        return Colors.grey[300];
      }
    } else {
      if (isAlreadySelected) {
        return primaryColor;
      } else {
        return Colors.grey[300];
      }
    }
  }

  Color? getSelectedTextColor(
      bool isSplit, List splitSeatNo, bool isAlreadySelected, String seat) {
    if (isSplit) {
      if (splitSeatNo.contains(seat)) {
        return Theme.of(context).textTheme.labelMedium!.color;
      } else {
        return Theme.of(context).textTheme.labelSmall!.color;
      }
    } else {
      if (isAlreadySelected) {
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
}
