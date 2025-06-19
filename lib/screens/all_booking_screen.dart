import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/global.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/routes.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../helper/string.dart';

import 'package:pdf/widgets.dart' as pw;

class AllBookingScreen extends StatefulWidget {
  String busNumber;
  String date;

  AllBookingScreen({required this.busNumber, required this.date});

  @override
  State<AllBookingScreen> createState() => _AllBookingScreenState();
}

class _AllBookingScreenState extends State<AllBookingScreen> {
  String htmlContent = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var bookingStore = getBookingStore(context);
      bookingStore.changeLoadingStatus(true);
      htmlContent = Global.getHtmlContent(
        date: widget.date,
        busNumber: widget.busNumber,
      );
      bookingStore.changeLoadingStatus(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BookingController>(
          builder: (context, bookingStore, snapshot) {
        List<Booking> lists = bookingStore.bookingList;
        lists.sort((a, b) {
          int seatA;
          int seatB;
          if (a.seatNumber!.contains('-')) {
            seatA = int.parse(a.seatNumber!.split("-").first);
          } else {
            seatA = int.parse(a.seatNumber!);
          }
          if (b.seatNumber!.contains('-')) {
            seatB = int.parse(b.seatNumber!.split("-").first);
          } else {
            seatB = int.parse(b.seatNumber!);
          }
          return seatA.compareTo(seatB);
        });
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimens.padding_20),
                  child: BackAppBar(
                    title: Languages.of(context)!.allBooking,
                    actions: [
                      InkWell(
                        onTap: () {
                          NavigationService.navigateTo(Routes.pdfView,
                              arguments: {
                                'busNumber': widget.busNumber,
                                'date': widget.date
                              });
                        },
                        child: Image.asset(
                          Images.view,
                          height: Dimens.height_25,
                        ),
                      ),
                      SizedBox(
                        width: Dimens.dimen_20,
                      ),
                      InkWell(
                        onTap: () {
                          Global.downloadPDF(
                              htmlContent: htmlContent,
                              busNumber: widget.busNumber,
                              date: widget.date);
                        },
                        child: Image.asset(
                          Images.download,
                          height: Dimens.height_20,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: Dimens.dimen_20,
                      ),
                      InkWell(
                        onTap: () {
                          Global.sharePDF(
                              htmlContent: htmlContent,
                              busNumber: widget.busNumber,
                              date: widget.date);
                        },
                        child: Image.asset(
                          Images.share,
                          height: Dimens.height_20,
                          color: skyBlue,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          buildTableTitle(Languages.of(context)!.fullName),
                          buildTableTitle(Languages.of(context)!.place),
                          buildTableTitle(Languages.of(context)!.seat),
                          buildTableTitle(''),
                        ],
                        rows: bookingStore.bookingList.map((booking) {
                          return DataRow(cells: [
                            buildDataCell(booking.fullName ?? ''),
                            buildDataCell(booking.place ?? ''),
                            buildDataCell(booking.seatNumber ?? ''),
                            DataCell(
                              InkWell(
                                onTap: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      booking.mobileNumber ?? '');
                                },
                                child: Image.asset(
                                  Images.phone,
                                  height: Dimens.dimen_25,
                                  width: Dimens.dimen_25,
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                )
              ],
            ),
            LoadingWithBackground(bookingStore.loading)
          ],
        );
      }),
    );
  }

  buildTableTitle(String title) {
    return DataColumn(
      label: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.labelSmall!.color,
          fontSize: Dimens.dimen_12,
          fontFamily: Fonts.semiBold,
        ),
      ),
    );
  }

  buildDataCell(String value) {
    return DataCell(Text(
      value,
      style: TextStyle(
        color: Theme.of(context).textTheme.labelSmall!.color,
        fontFamily: Fonts.regular,
        fontSize: Dimens.fontSize_11,
      ),
    ));
  }

}
