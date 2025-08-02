import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/app_dialog.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/global.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_textfield.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/dimens.dart';
import '../../helper/navigation.dart';
import '../../helper/responsive.dart';
import '../../helper/string.dart';
import '../../language/localization/language/languages.dart';
import '../../widgets/app_button.dart';
import 'package:pdf/widgets.dart' as pw;

class PassengerDetailsDialog extends StatefulWidget {
  Function(
      String name,
      String place,
      String number,
      String village,
      String cash,
      String pending,
      String secondaryNumber,
      bool isSplit,
      String splitSeatNumber) onTap;
  Booking? booking;
  Function(bool? isSplit, String? splitSeatNumber)? onCancel;
  bool? isSplitOption;
  String? seatNo;
  String? selectedSplitSeatNo;
  List<Booking> bookingList;

  PassengerDetailsDialog(
      this.onTap,
      this.booking,
      this.onCancel,
      this.isSplitOption,
      this.seatNo,
      this.selectedSplitSeatNo,
      this.bookingList);

  @override
  State<PassengerDetailsDialog> createState() => _PassengerDetailsDialogState();
}

class _PassengerDetailsDialogState extends State<PassengerDetailsDialog> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController secondaryMobileController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController cashAmountController = TextEditingController();
  TextEditingController pendingAmountController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSplitOption = false;
  bool isSplit = false;

  String seat = '';
  String selectedSeat = "";

  bool _isClearing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getBookingStore(context).getAllPlace();
      await getBookingStore(NavigationService.context).getAllVillage();
      setState(() {
        isSplitOption = widget.isSplitOption ?? false;
        seat = widget.seatNo ?? '';
        selectedSeat = seat.split("-").first;
        if (widget.selectedSplitSeatNo != null) {
          isSplit = true;
          selectedSeat = widget.selectedSplitSeatNo!;
        }
      });
      fillExistingDetails(widget.booking);
    });
  }

  fillExistingDetails(Booking? booking) {
    if (booking != null) {
      setState(() {
        fullNameController.text = booking.fullName ?? '';
        placeController.text = booking.place ?? '';
        mobileController.text = booking.mobileNumber ?? '';
        secondaryMobileController.text = booking.secondaryMobileNumber ?? '';
        villageController.text = booking.villageName ?? '';
        cashAmountController.text = booking.cash ?? '';
        pendingAmountController.text = booking.pending ?? '';
      });
    } else {
      _isClearing = true;
      fullNameController.clear();
      placeController.clear();
      mobileController.clear();
      secondaryMobileController.clear();
      villageController.clear();
      cashAmountController.clear();
      pendingAmountController.clear();
      Future.delayed(Duration(milliseconds: 100), () {
        _isClearing = false;
      });
    }
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
              return Form(
                key: formKey,
                child: SingleChildScrollView(
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
                              Languages.of(context)!.passengerDetails,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .color,
                                fontFamily: Fonts.medium,
                                fontSize: Dimens.fontSize_16,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                if (widget.booking != null)
                                  InkWell(
                                    onTap: () async {
                                      Booking booking = widget.booking!;
                                      String html = Global.printTicket(
                                        village: booking.villageName!,
                                        date: DateFormat('dd/MM/yy').format(DateFormat('dd-MM-yyyy').parse(booking.date!)),
                                        busNumber: booking.busNumber!,
                                        name: booking.fullName!,
                                        time: booking.place!.toString().split("(").last.replaceAll(')', "").split("-").first,
                                        busTime: booking.place!.toString().split("(").last.replaceAll(')', "").split("-").last,
                                        seatNumber: booking.seatNumber!,
                                        totalSeat: booking.seatNumber!.contains("-") ? "2" : "1",
                                        cash: booking.cash!,
                                        pending: booking.pending!,
                                      );
                                      final tempDir = await getTemporaryDirectory();
                                      final htmlFile = File('${tempDir.path}/ticket.html');
                                      await htmlFile.writeAsString(html);

                                      final uri = Uri.file(htmlFile.path);
                                      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    },
                                    child: Icon(
                                      Icons.print,
                                      color: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .color,
                                    ),
                                  ),
                                SizedBox(width: Dimens.width_15,),
                                InkWell(
                                  onTap: () {
                                    NavigationService.goBack;
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .color,
                                  ),
                                )
                              ],
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
                        if (isSplitOption)
                          Padding(
                            padding: EdgeInsets.only(bottom: Dimens.padding_10),
                            child: Row(
                              children: [
                                Text(
                                  Languages.of(context)!.split,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelSmall!
                                        .color,
                                    fontSize: Dimens.fontSize_12,
                                    fontFamily: Fonts.medium,
                                  ),
                                ),
                                CupertinoSwitch(
                                  value: isSplit,
                                  onChanged: widget.booking == null
                                      ? (bool value) {
                                          setState(() {
                                            isSplit = value;
                                          });
                                        }
                                      : null,
                                ),
                                if (isSplit)
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: Dimens.padding_15),
                                    width: Dimens.width_70,
                                    height: Dimens.height_32,
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border:
                                            Border.all(color: primaryColor)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedSeat =
                                                    seat.split("-").first;
                                              });
                                              Booking? booking = widget
                                                  .bookingList
                                                  .where((b) =>
                                                      b.seatNumber ==
                                                      selectedSeat)
                                                  .firstOrNull;
                                              fillExistingDetails(booking);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8)),
                                                color: selectedSeat ==
                                                        seat.split("-").first
                                                    ? primaryColor
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  seat.split("-").first,
                                                  style: TextStyle(
                                                      color: selectedSeat ==
                                                              seat
                                                                  .split("-")
                                                                  .first
                                                          ? Theme.of(context)
                                                              .textTheme
                                                              .labelMedium!
                                                              .color
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .labelSmall!
                                                              .color,
                                                      fontSize:
                                                          Dimens.fontSize_14,
                                                      fontFamily: Fonts.medium),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedSeat =
                                                    seat.split("-").last;
                                              });
                                              Booking? booking = widget
                                                  .bookingList
                                                  .where((b) =>
                                                      b.seatNumber ==
                                                      selectedSeat)
                                                  .firstOrNull;
                                              fillExistingDetails(booking);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(8),
                                                    bottomRight:
                                                        Radius.circular(8)),
                                                color: selectedSeat ==
                                                        seat.split("-").last
                                                    ? primaryColor
                                                    : Colors.transparent,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  seat.split("-").last,
                                                  style: TextStyle(
                                                      color: selectedSeat ==
                                                              seat
                                                                  .split("-")
                                                                  .last
                                                          ? Theme.of(context)
                                                              .textTheme
                                                              .labelMedium!
                                                              .color
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .labelSmall!
                                                              .color,
                                                      fontSize:
                                                          Dimens.fontSize_14,
                                                      fontFamily: Fonts.medium),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                        AppTextField(
                          hintText: Languages.of(context)!.village,
                          controller: villageController,
                          onTap: () {
                            AppDialog.villageDialog(context, onSubmit: (name) {
                              villageController.text = name;
                            });
                          },
                          suffix: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              Images.dropDown,
                              height: Dimens.height_10,
                            ),
                          ),
                          isReadOnly: true,
                          validator: (value) {
                            if (_isClearing) return null;
                            if (value == null || value.isEmpty) {
                              return Languages.of(context)!.villageRequired;
                            }
                            return null;
                          },
                          titleText: '',
                        ),
                        SizedBox(
                          height: Dimens.dimen_16,
                        ),
                        AppTextField(
                          hintText: Languages.of(context)!.fullName,
                          controller: fullNameController,
                          validator: (value) {
                            if (_isClearing) return null;
                            if (value == null || value.isEmpty) {
                              return Languages.of(context)!.fullNameRequired;
                            }
                            return null;
                          },
                          titleText: '',
                        ),
                        SizedBox(
                          height: Dimens.dimen_16,
                        ),
                        AppTextField(
                          hintText: Languages.of(context)!.mobileNumber,
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,10}')),
                          ],
                          titleText: '',
                        ),
                        SizedBox(
                          height: Dimens.dimen_16,
                        ),
                        AppTextField(
                          hintText:
                              Languages.of(context)!.secondaryMobileNumber,
                          controller: secondaryMobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d{0,10}')),
                          ],
                          titleText: '',
                        ),
                        SizedBox(
                          height: Dimens.dimen_16,
                        ),
                        AppTextField(
                          hintText: Languages.of(context)!.pickPlace,
                          onTap: () {
                            AppDialog.placeDialog(context, onSubmit: (name) {
                              placeController.text = name;
                            });
                          },
                          suffix: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              Images.dropDown,
                              height: Dimens.height_10,
                            ),
                          ),
                          isReadOnly: true,
                          controller: placeController,
                          validator: (value) {
                            if (_isClearing) return null;
                            if (value == null || value.isEmpty) {
                              return Languages.of(context)!.placeRequired;
                            }
                            return null;
                          },
                          titleText: '',
                        ),
                        SizedBox(
                          height: Dimens.dimen_16,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppTextField(
                                hintText: Languages.of(context)!.cash,
                                controller: cashAmountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,10}')),
                                ],
                                titleText: '',
                              ),
                            ),
                            SizedBox(
                              width: Dimens.dimen_16,
                            ),
                            Expanded(
                              child: AppTextField(
                                hintText:
                                    "${Languages.of(context)!.pending} ${Languages.of(context)!.amount}",
                                controller: pendingAmountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d{0,10}')),
                                ],
                                titleText: '',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        if (widget.booking != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: Dimens.padding_10),
                            child: InkWell(
                              onTap: () {
                                AppDialog.changeBusNumberDialog(
                                  context,
                                  onSubmit: (changeNumber) async {
                                    await bookingStore
                                        .changeAllBookingBusNumber(
                                            oldBusNumber:
                                                bookingStore.selectedBusNumber,
                                            newBusNumber: changeNumber,
                                            date: widget.booking!.date!,
                                            seatNumber: isSplit
                                                ? selectedSeat
                                                : widget.booking!.seatNumber);
                                    await getBookingStore(
                                            NavigationService.context)
                                        .getBookedSeats(
                                            bookingStore.selectedBusNumber,
                                            widget.booking!.date!);
                                    NavigationService.goBack;
                                  },
                                  currentBusNumber:
                                      bookingStore.selectedBusNumber,
                                );
                              },
                              child: Text(
                                Languages.of(context)!
                                    .changeBusNumberForThisSeat,
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
                                label: Languages.of(context)!.submit,
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    widget.onTap(
                                      fullNameController.text,
                                      placeController.text,
                                      mobileController.text,
                                      villageController.text,
                                      cashAmountController.text.isEmpty
                                          ? "0"
                                          : cashAmountController.text,
                                      pendingAmountController.text.isEmpty
                                          ? "0"
                                          : pendingAmountController.text,
                                      secondaryMobileController.text,
                                      isSplit,
                                      isSplit ? selectedSeat : "",
                                    );
                                    NavigationService.goBack;
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width:
                                  widget.booking != null ? Dimens.width_10 : 0,
                            ),
                            if (widget.booking != null)
                              Expanded(
                                child: AppButton(
                                  label: Languages.of(context)!.cancel,
                                  bgColor: redColor,
                                  onPressed: () {
                                    AppDialog.confirmationDialog(context,
                                        title:
                                            "${Languages.of(context)!.cancelBooking}?",
                                        msg: Languages.of(context)!
                                            .cancelBookingContent,
                                        onTap: (val) {
                                      if (val) {
                                        widget.onCancel!(isSplit, selectedSeat);
                                        NavigationService.goBack;
                                      }
                                    });
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
        ),
      ),
    );
  }
}
