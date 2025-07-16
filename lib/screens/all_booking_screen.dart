import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/global.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/routes.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/shared_preference.dart';
import '../helper/string.dart';

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
  Widget build(BuildContext context) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(Dimens.padding_20),
                      child: BackAppBar(
                        title: Languages.of(context)!.allBooking,
                        actions: [
                          InkWell(
                            onTap: () async {
                              Map<String, dynamic>? data = await Preferences.getDriverDetails(widget.busNumber);
                              if(Platform.isWindows){
                                NavigationService.navigateTo(Routes.pdfWindowsView,
                                    arguments: {
                                      'busNumber': widget.busNumber,
                                      'date': widget.date,
                                      'driver': data?['driverName'] ?? '',
                                      'conductor': data?['conductorName'] ?? '',
                                      'time': data?['time'] ?? '',
                                      'to': data?['toVillageName'] ?? '',
                                    });
                              }else if(Platform.isAndroid || Platform.isIOS){
                                NavigationService.navigateTo(Routes.pdfView,
                                    arguments: {
                                      'busNumber': widget.busNumber,
                                      'date': widget.date,
                                      'driver': data?['driverName'] ?? '',
                                      'conductor': data?['conductorName'] ?? '',
                                      'time': data?['time'] ?? '',
                                      'to': data?['toVillageName'] ?? '',
                                    });
                              }else{
                                bookingStore.changeLoadingStatus(true);
                                htmlContent = await Global.getHtmlContent(
                                  date: widget.date,
                                  busNumber: widget.busNumber,
                                  scaleFactor: MediaQuery.of(context).textScaleFactor,
                                  driver: data?['driverName'] ?? '',
                                  conductor: data?['conductorName'] ?? '',
                                  time: data?['time'] ?? '',
                                  suratTo: data?['toVillageName'] ?? '',
                                );
                                bookingStore.changeLoadingStatus(false);

                                final tempDir = await getTemporaryDirectory();
                                final htmlFile = File('${tempDir.path}/preview.html');
                                await htmlFile.writeAsString(htmlContent);

                                final uri = Uri.file(htmlFile.path);
                                final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                if (!launched) {
                                  throw 'Could not launch HTML file.';
                                }
                              }
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
                            onTap: () async {
                              Map<String, dynamic>? data = await Preferences.getDriverDetails(widget.busNumber);
                              bookingStore.changeLoadingStatus(true);
                              htmlContent = await Global.getHtmlContent(
                                date: widget.date,
                                busNumber: widget.busNumber,
                                scaleFactor: MediaQuery.of(context).textScaleFactor,
                                driver: data?['driverName'] ?? '',
                                conductor: data?['conductorName'] ?? '',
                                time: data?['time'] ?? '',
                                suratTo: data?['toVillageName'] ?? '',
                              );
                              bookingStore.changeLoadingStatus(false);
                              if(Platform.isWindows){
                                final tempDir = await getTemporaryDirectory();
                                final htmlFile = File('${tempDir.path}/preview.html');
                                await htmlFile.writeAsString(htmlContent);

                                final uri = Uri.file(htmlFile.path);
                                final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                if (!launched) {
                                  throw 'Could not launch HTML file.';
                                }
                              }else{

                                Global.downloadPDF(
                                    htmlContent: htmlContent,
                                    busNumber: widget.busNumber,
                                    date: widget.date);
                              }


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
                            onTap: () async {
                              Map<String, dynamic>? data = await Preferences.getDriverDetails(widget.busNumber);
                              bookingStore.changeLoadingStatus(true);
                              htmlContent = await Global.getHtmlContent(
                                date: widget.date,
                                busNumber: widget.busNumber,
                                scaleFactor: MediaQuery.of(context).textScaleFactor,
                                driver: data?['driverName'] ?? '',
                                conductor: data?['conductorName'] ?? '',
                                time: data?['time'] ?? '',
                                suratTo: data?['toVillageName'] ?? '',
                              );
                              bookingStore.changeLoadingStatus(false);

                              if(Platform.isWindows){
                                final tempDir = await getTemporaryDirectory();
                                final htmlFile = File('${tempDir.path}/preview.html');
                                await htmlFile.writeAsString(htmlContent);

                                final uri = Uri.file(htmlFile.path);
                                final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                                if (!launched) {
                                  throw 'Could not launch HTML file.';
                                }
                              }else{
                                Global.sharePDF(
                                    htmlContent: htmlContent,
                                    busNumber: widget.busNumber,
                                    date: widget.date);
                              }
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
                            rows: generateListSeatWise(),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            //LoadingWithBackground(bookingStore.loading)
          ],
        );
      }),
    );
  }

  List<DataRow> generateListSeatWise() {
    var bookingStore = getBookingStore(NavigationService.context);
    List<Booking> lists = bookingStore.bookingList;

    List<DataRow> rows = [];

    List<String> seatLayout = Global.seatLayout
        .where((seat) => seat != 'K' && seat != 'Total')
        .toList();

    for (int index = 0; index < seatLayout.length; index++) {
      final seat = seatLayout[index];
      final gujaratiSeat = Global.gujaratiSeatLayout[index];
      Booking? booking;
      if (seat.contains("-")) {
        List splitSeatNo = bookingStore.getSplitSeatNo(seat);
        if (splitSeatNo.isEmpty) {
          booking = lists.firstWhere(
            (b) {
              return b.seatNumber == seat;
            },
            orElse: () => Booking(),
          );
        } else {
          List<Booking> list =
              bookingStore.getListOfBookingInfo(splitSeatNo) ?? [];
          if (list.isEmpty) {
            booking = lists.firstWhere(
              (b) {
                return b.seatNumber == seat;
              },
              orElse: () => Booking(),
            );
          } else if (list.length == 1) {
            booking = list.first;
          } else if (list.length == 2) {
            booking = Booking(
              fullName: '${list[0].fullName}\n${list[1].fullName}',
              seatNumber: seat,
              cash: '${list[0].cash}\n${list[1].cash}',
              pending: '${list[0].pending}\n${list[1].pending}',
              mobileNumber:
                  '${list[0].mobileNumber ?? "-"}\n${list[1].mobileNumber ?? "-"}',
              secondaryMobileNumber:
                  '${list[0].secondaryMobileNumber ?? "-"}\n${list[1].secondaryMobileNumber ?? "-"}',
              place:
                  '${list[0].place!.split("(").first}\n${list[1].place!.split("(").first}',
              villageName: '${list[0].villageName}\n${list[1].villageName}',
            );
          } else {
            booking = lists.firstWhere(
              (b) {
                return b.seatNumber == seat;
              },
              orElse: () => Booking(),
            );
          }
        }
      } else {
        booking = lists.firstWhere(
          (b) {
            return b.seatNumber == seat;
          },
          orElse: () => Booking(),
        );
      }

      String mobileNumber = booking.mobileNumber ?? '';

      rows.add(DataRow(cells: [
        buildDataCell(booking.fullName ?? ''),
        buildDataCell(
            booking.place != null ? booking.place!.split("(").first : ""),
        buildDataCell(seat == 'K' ? '' : gujaratiSeat),
        mobileNumber.isEmpty
            ? DataCell(SizedBox())
            : DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        await FlutterPhoneDirectCaller.callNumber(
                            mobileNumber.split("\n").first ?? '');
                      },
                      child: Image.asset(
                        Images.phone,
                        height: Dimens.dimen_25,
                        width: Dimens.dimen_25,
                      ),
                    ),
                    if (mobileNumber.contains("\n"))
                      Padding(
                        padding: EdgeInsets.only(left: Dimens.padding_10),
                        child: InkWell(
                          onTap: () async {
                            await FlutterPhoneDirectCaller.callNumber(
                                mobileNumber.split("\n").last ?? '');
                          },
                          child: Image.asset(
                            Images.phone,
                            height: Dimens.dimen_25,
                            width: Dimens.dimen_25,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ]));
    }

    return rows;
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
