import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/responsive.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/app_textfield.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helper/global.dart';
import '../helper/string.dart';

class TotalIncomeScreen extends StatefulWidget {
  @override
  State<TotalIncomeScreen> createState() => _TotalIncomeScreenState();
}

class _TotalIncomeScreenState extends State<TotalIncomeScreen> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  PickerDateRange? _selectedRange;

  List<Booking> bookingList = [];

  String htmlContent = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedRange = PickerDateRange(startDate, endDate);
      });
      initData();
    });
  }

  initData() {
    getBookingStore(context)
        .getDateWiseData(startDate, endDate)
        .then((val) async {
      bookingList = val;
      var grouped = groupBookings(bookingList);
      htmlContent = await Global.getHtmlTotalIncome(
        incomeData: grouped,
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BookingController>(
        builder: (context, bookStore, snapshot) {
          var grouped = groupBookings(bookingList);
          return Stack(
            children: [
              SafeArea(
                child: MediaQuery(
                  data: MediaQueryData(
                    textScaleFactor: 1.0,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(Dimens.padding_20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Dimens.padding_20),
                          child: BackAppBar(
                            title: Languages.of(context)!.totalIncome,
                            actions: [
                              if (Platform.isWindows)
                                InkWell(
                                  onTap: () async {
                                    var grouped = groupBookings(bookingList);
                                    bookStore.changeLoadingStatus(true);
                                    htmlContent =
                                        await Global.getHtmlTotalIncome(
                                      incomeData: grouped,
                                      scaleFactor: MediaQuery.of(context)
                                          .textScaleFactor,
                                    );
                                    bookStore.changeLoadingStatus(false);

                                    if (kIsWeb) {
                                    } else {
                                      if (Platform.isWindows) {
                                        // NavigationService.navigateTo(Routes.pdfWindowsView,
                                        //     arguments: {
                                        //       'busNumber': widget.busNumber,
                                        //       'date': widget.date,
                                        //       'driver': data?['driverName'] ?? '',
                                        //       'conductor': data?['conductorName'] ?? '',
                                        //       'time': data?['time'] ?? '',
                                        //       'to': data?['toVillageName'] ?? '',
                                        //     });
                                      } else if (Platform.isAndroid ||
                                          Platform.isIOS) {
                                        // NavigationService.navigateTo(Routes.pdfView,
                                        //     arguments: {
                                        //       'busNumber': widget.busNumber,
                                        //       'date': widget.date,
                                        //       'driver': data?['driverName'] ?? '',
                                        //       'conductor': data?['conductorName'] ?? '',
                                        //       'time': data?['time'] ?? '',
                                        //       'to': data?['toVillageName'] ?? '',
                                        //     });
                                      } else {
                                        final tempDir =
                                            await getTemporaryDirectory();
                                        final htmlFile = File(
                                            '${tempDir.path}/preview.html');
                                        await htmlFile
                                            .writeAsString(htmlContent);

                                        final uri = Uri.file(htmlFile.path);
                                        final launched = await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                        if (!launched) {
                                          throw 'Could not launch HTML file.';
                                        }
                                      }
                                    }
                                  },
                                  child: Image.asset(
                                    Images.view,
                                    height: Dimens.height_25,
                                  ),
                                ),
                              if (Platform.isAndroid || Platform.isIOS)
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: Dimens.padding_20),
                                  child: InkWell(
                                    onTap: () async {
                                      var grouped = groupBookings(bookingList);
                                      bookStore.changeLoadingStatus(true);
                                      htmlContent =
                                          await Global.getHtmlTotalIncome(
                                        incomeData: grouped,
                                        scaleFactor: MediaQuery.of(context)
                                            .textScaleFactor,
                                      );
                                      if (Platform.isWindows) {
                                        final tempDir =
                                            await getTemporaryDirectory();
                                        final htmlFile = File(
                                            '${tempDir.path}/preview.html');
                                        await htmlFile
                                            .writeAsString(htmlContent);

                                        final uri = Uri.file(htmlFile.path);
                                        final launched = await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                        bookStore.changeLoadingStatus(false);
                                        if (!launched) {
                                          throw 'Could not launch HTML file.';
                                        }

                                      } else {
                                        Global.downloadIncomePDF(
                                            htmlContent: htmlContent,
                                            date:
                                                "${DateFormat("dd-MM-yyyy").format(startDate)} - ${DateFormat("dd-MM-yyyy").format(endDate)}");
                                        bookStore.changeLoadingStatus(false);
                                      }
                                    },
                                    child: Image.asset(
                                      Images.download,
                                      height: Dimens.height_20,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              if (Platform.isAndroid || Platform.isIOS)
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: Dimens.padding_20),
                                  child: InkWell(
                                    onTap: () async {
                                      print("Share : $htmlContent");
                                      var grouped = groupBookings(bookingList);
                                      bookStore.changeLoadingStatus(true);
                                      htmlContent =
                                          await Global.getHtmlTotalIncome(
                                        incomeData: grouped,
                                        scaleFactor: MediaQuery.of(context)
                                            .textScaleFactor,
                                      );
                                      bookStore.changeLoadingStatus(false);
                                      if (Platform.isWindows) {
                                        final tempDir =
                                            await getTemporaryDirectory();
                                        final htmlFile = File(
                                            '${tempDir.path}/preview.html');
                                        await htmlFile
                                            .writeAsString(htmlContent);

                                        final uri = Uri.file(htmlFile.path);
                                        final launched = await launchUrl(uri,
                                            mode:
                                                LaunchMode.externalApplication);
                                        if (!launched) {
                                          throw 'Could not launch HTML file.';
                                        }
                                      } else {
                                        Global.shareIncomePDF(
                                            htmlContent: htmlContent,
                                            date:
                                                "${DateFormat("dd-MM-yyyy").format(startDate)} - ${DateFormat("dd-MM-yyyy").format(endDate)}");
                                      }
                                    },
                                    child: Image.asset(
                                      Images.share,
                                      height: Dimens.height_20,
                                      color: skyBlue,
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        SizedBox(
                          width: Responsive.isDesktop(context)
                              ? MediaQuery.of(context).size.width / 4
                              : MediaQuery.of(context).size.width,
                          child: AppTextField(
                            onTap: () {
                              showDateRangeDialog();
                            },
                            titleText: "",
                            controller: TextEditingController(
                                text:
                                    "${DateFormat("dd/MM/yyyy").format(startDate)} - ${DateFormat("dd/MM/yyyy").format(endDate)}"),
                            isReadOnly: true,
                            suffix: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                Images.dropDown,
                                height: Dimens.height_10,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        Expanded(
                          child: buildBookingReport(grouped),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              LoadingWithBackground(bookStore.loading)
            ],
          );
        },
      ),
    );
  }

  textTile(
      {required String title,
      required int value,
      Color boxColor = primaryColor}) {
    return SizedBox(
      width: Responsive.isDesktop(context)
          ? MediaQuery.of(context).size.width / 4
          : MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: Dimens.width_100,
            child: Text(
              title,
              style: TextStyle(
                  color: Theme.of(context).textTheme.labelSmall!.color,
                  fontSize: Dimens.fontSize_16,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: EdgeInsets.all(Dimens.padding_12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: boxColor,
                borderRadius: BorderRadius.circular(Dimens.radius_8)),
            child: Text(
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹ ',
                decimalDigits: 0,
              ).format(value),
              style: TextStyle(
                color: whiteColor,
                fontSize: Dimens.fontSize_14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDateRangeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        PickerDateRange? tempRange = _selectedRange;

        return AlertDialog(
          title: Text(Languages.of(context)!.date),
          content: SizedBox(
            width: 300,
            height: 350,
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: _selectedRange,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  tempRange = args.value;
                }
              },
              maxDate:
                  DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
              minDate: DateTime(2025),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // cancel
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedRange = tempRange;
                  startDate = _selectedRange!.startDate!;
                  endDate = _selectedRange!.endDate!;
                });
                initData();
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Map<String, Map<String, int>> groupBookings(List<Booking> bookings) {
    Map<String, Map<String, int>> grouped = {};

    for (var booking in bookings) {
      String dateKey = DateFormat('dd/MM/yyyy').format(booking.createdAt!);
      String bus = booking.busNumber!;

      // Convert cash string to int
      int seatPrice = int.tryParse(booking.cash.toString()) ?? 0;

      // Initialize date group
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = {};
      }

      // Initialize bus total
      if (!grouped[dateKey]!.containsKey(bus)) {
        grouped[dateKey]![bus] = 0;
      }

      // Add seat price to total
      grouped[dateKey]![bus] = grouped[dateKey]![bus]! + seatPrice;
    }

    return grouped;
  }

  Widget buildBookingReport(Map<String, Map<String, int>> groupedData) {
    final sortedDates = groupedData.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(a)
          .compareTo(DateFormat('dd/MM/yyyy').parse(b)));

    List<TableRow> tableRows = [];

    tableRows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade300),
        children: [
          Padding(
            padding: EdgeInsets.all(Dimens.padding_5),
            child: Text(
              Languages.of(context)!.date,
              style: TextStyle(
                fontSize: Dimens.fontSize_14,
                fontFamily: Fonts.bold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Dimens.padding_5),
            child: Text(
              Languages.of(context)!.busNumber,
              style: TextStyle(
                fontSize: Dimens.fontSize_14,
                fontFamily: Fonts.bold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Dimens.padding_5),
            child: Text(
              Languages.of(context)!.income,
              style: TextStyle(
                fontSize: Dimens.fontSize_14,
                fontFamily: Fonts.bold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Dimens.padding_5),
            child: Text(
              Languages.of(context)!.totalIncome,
              style: TextStyle(
                fontSize: Dimens.fontSize_14,
                fontFamily: Fonts.bold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    double totalIncome = 0;

    for (var date in sortedDates) {
      final busData = groupedData[date]!;
      bool isFirst = true;

      double income = 0;

      for (var entry in busData.entries) {
        income += entry.value;
      }

      totalIncome += income;

      for (var entry in busData.entries) {
        tableRows.add(
          TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(Dimens.padding_5),
                child: isFirst
                    ? Text(
                        date,
                        style: TextStyle(
                          fontSize: Dimens.fontSize_14,
                          fontFamily: Fonts.medium,
                          color: skyBlue,
                        ),
                      )
                    : Text(
                        "",
                        style: TextStyle(
                          fontSize: Dimens.fontSize_14,
                          fontFamily: Fonts.medium,
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimens.padding_5),
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: Dimens.fontSize_14,
                    fontFamily: Fonts.medium,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimens.padding_5),
                child: Text(
                  getThousandValue(entry.value.toDouble()),
                  style: TextStyle(
                    fontSize: Dimens.fontSize_14,
                    fontFamily: Fonts.medium,
                  ),
                ),
              ),
              isFirst
                  ? Padding(
                      padding: EdgeInsets.all(Dimens.padding_5),
                      child: Text(
                        getThousandValue(income),
                        style: TextStyle(
                          fontSize: Dimens.fontSize_14,
                          fontFamily: Fonts.medium,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
        isFirst = false;
      }
    }

    tableRows.add(
      TableRow(
        decoration: BoxDecoration(color: Colors.grey.shade300),
        children: [
          Padding(
            padding: EdgeInsets.all(Dimens.padding_5),
            child: Text(
              Languages.of(context)!.totalIncome,
              style: TextStyle(
                fontSize: Dimens.fontSize_14,
                fontFamily: Fonts.bold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          Padding(
            padding: EdgeInsets.all(Dimens.padding_5),
            child: Text(
              getThousandValue(totalIncome),
              style: TextStyle(
                fontSize: Dimens.fontSize_14,
                fontFamily: Fonts.bold,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(60),
            2: FixedColumnWidth(80),
            3: FixedColumnWidth(90),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: tableRows,
        ),
      ),
    );
  }

  getThousandValue(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    ).format(value);
  }
}
