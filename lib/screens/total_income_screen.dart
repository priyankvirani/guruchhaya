import 'dart:io';

import 'package:flutter/material.dart';
import 'package:guruchaya/helper/colors.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/global.dart';
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
import '../helper/string.dart';

class TotalIncomeScreen extends StatefulWidget {
  @override
  State<TotalIncomeScreen> createState() => _TotalIncomeScreenState();
}

class TotalIncome {
  String date;
  List<Map<String, num>> value1;
  List<Map<String, num>> value2;
  List<Map<String, num>> value3;
  List<Map<String, num>> value4;
  int total;

  TotalIncome(
      {required this.date,
      required this.value1,
      required this.value2,
      required this.value3,
      required this.value4,
      required this.total});

}

class _TotalIncomeScreenState extends State<TotalIncomeScreen> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  PickerDateRange? _selectedRange;

  List<Booking> bookingList = [];

  String htmlContent = "";

  List<TotalIncome> totalIncomeList = [];

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
      generateTotalData(bookingList);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<BookingController>(
        builder: (context, bookStore, snapshot) {
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
                              Padding(
                                padding:
                                    EdgeInsets.only(left: Dimens.padding_20),
                                child: InkWell(
                                  onTap: () async {
                                    htmlContent = await Global.getHtmlTotalIncome(
                                      totalIncomeList: totalIncomeList,
                                      scaleFactor: MediaQuery.of(context).textScaleFactor,
                                    );
                                    if (Platform.isWindows) {
                                      final tempDir =
                                          await getTemporaryDirectory();
                                      final htmlFile =
                                          File('${tempDir.path}/income.html');
                                      await htmlFile.writeAsString(htmlContent);

                                      final uri = Uri.file(htmlFile.path);
                                      final launched = await launchUrl(uri,
                                          mode: LaunchMode.externalApplication);
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

                                      htmlContent = await Global.getHtmlTotalIncome(
                                        totalIncomeList: totalIncomeList,
                                        scaleFactor: MediaQuery.of(context).textScaleFactor,
                                      );

                                      bookStore.changeLoadingStatus(false);
                                      Global.shareIncomePDF(
                                          htmlContent: htmlContent,
                                          date:
                                          "${DateFormat("dd-MM-yyyy").format(startDate)} - ${DateFormat("dd-MM-yyyy").format(endDate)}");
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
                        if(_selectedRange != null)
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
                                    "${DateFormat("dd/MM/yyyy").format(_selectedRange!.startDate!)} - ${DateFormat("dd/MM/yyyy").format(_selectedRange!.endDate!)}"),
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
                          child: buildBookingReport(),
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

  Widget buildBookingReport() {
    List<List<String>> busGroups = Global.getBusGroup();

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
          for (int i = 0; i < busGroups.length; i++)
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                busGroups[i].join('\n'),
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

    for (var income in totalIncomeList) {
      tableRows.add(
        TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                income.date,
                style: TextStyle(
                  fontSize: Dimens.fontSize_14,
                  fontFamily: Fonts.medium,
                  color: skyBlue,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                Global.getBusNumberIncome(income.value1),
                style: TextStyle(
                  fontSize: Dimens.fontSize_14,
                  fontFamily: Fonts.medium,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                Global.getBusNumberIncome(income.value2),
                style: TextStyle(
                  fontSize: Dimens.fontSize_14,
                  fontFamily: Fonts.medium,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                Global.getBusNumberIncome(income.value3),
                style: TextStyle(
                  fontSize: Dimens.fontSize_14,
                  fontFamily: Fonts.medium,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                Global.getBusNumberIncome(income.value4),
                style: TextStyle(
                  fontSize: Dimens.fontSize_14,
                  fontFamily: Fonts.medium,
                  color: textColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                Global.getThousandValue(income.total),
                style: TextStyle(
                  fontSize: Dimens.fontSize_14,
                  fontFamily: Fonts.medium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    List<int> calculateColumnsTotal = Global.calculateColumnTotals(totalIncomeList);

    totalIncome = calculateColumnsTotal.fold(0, (sum, value) => sum + value);

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
          for (int i = 0; i < calculateColumnsTotal.length; i++)
            Padding(
              padding: EdgeInsets.all(Dimens.padding_5),
              child: Text(
                Global.getThousandValue(calculateColumnsTotal[i]),
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
              Global.getThousandValue(totalIncome.toInt()),
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

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: const {
            0: FixedColumnWidth(100),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(120),
            3: FixedColumnWidth(120),
            4: FixedColumnWidth(120),
            5: FixedColumnWidth(100),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: tableRows,
        ),
      ),
    );
  }

  generateTotalData(List<Booking> bookings) async {
    List<TotalIncome> totalIncomeList = [];
    List<List<String>> busGroups = Global.getBusGroup();

    List<String> dateList = [];

    while (startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
      dateList.add(DateFormat('dd-MM-yyyy').format(startDate));
      startDate = startDate.add(Duration(days: 1));
    }

    for (var date in dateList) {
      TotalIncome totalIncome = TotalIncome(
        date: date,
        value1: [
          {busGroups[0].first: 0},
          {busGroups[0].last: 0}
        ],
        value2: [
          {busGroups[1].first: 0},
          {busGroups[1].last: 0}
        ],
        value3: [
          {busGroups[2].first: 0},
          {busGroups[2].last: 0}
        ],
        value4: [
          {busGroups[3].first: 0},
          {busGroups[3].last: 0}
        ],
        total: 0,
      );
      totalIncomeList.add(totalIncome);
    }

    for (var income in totalIncomeList) {
      int index = totalIncomeList.indexOf(income);

      TotalIncome totalIncome = TotalIncome(
        date: income.date,
        value1:
            getGroupIncomeFromBusNumber(income.value1, income.date, bookings),
        value2:
            getGroupIncomeFromBusNumber(income.value2, income.date, bookings),
        value3:
            getGroupIncomeFromBusNumber(income.value3, income.date, bookings),
        value4:
            getGroupIncomeFromBusNumber(income.value4, income.date, bookings),
        total: 0,
      );
      totalIncomeList[index] = totalIncome;
      totalIncomeList[index].total = calculatePerDayTotals(totalIncome);
    }

    setState(() {
      this.totalIncomeList = totalIncomeList;
    });

    htmlContent = await Global.getHtmlTotalIncome(
      totalIncomeList: totalIncomeList,
      scaleFactor: MediaQuery.of(context).textScaleFactor,
    );
    setState(() {});
  }

  List<Map<String, num>> getGroupIncomeFromBusNumber(
    List<Map<String, num>> value,
    String date,
    List<Booking> bookings,
  ) {
    return value
        .map((map) {
          final busNumber = map.keys.first;

          final total = bookings
              .where((b) => b.busNumber == busNumber && b.date == date && (b.isSplit ?? false ? true : Global.seatLayout.contains(b.seatNumber)))
              .fold<num>(
                  0, (sum, b) => sum + (num.tryParse(b.cash ?? '0') ?? 0));

          return {busNumber: total};
        })
        .where((map) => map.values.first > 0)
        .toList();
  }

  int calculatePerDayTotals(TotalIncome income) {
    int total = 0;
    for (var entry in [...income.value1, ...income.value2, ...income.value3, ...income.value4]) {
      total += entry.values.first.toInt();
    }
    return total;
  }



}
