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
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../helper/global.dart';
import '../helper/string.dart';
import '../widgets/app_drop_down.dart';

class TotalIncomeScreen extends StatefulWidget {
  @override
  State<TotalIncomeScreen> createState() => _TotalIncomeScreenState();
}

class _TotalIncomeScreenState extends State<TotalIncomeScreen> {
  DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  int cash = 0;
  int pending = 0;

  PickerDateRange? _selectedRange;

  String selectedBusNumber = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      setState(() {
        selectedBusNumber = getBookingStore(context).busNumberList.first;
        _selectedRange = PickerDateRange(startDate, endDate);
      });
      initData();
    });
  }

  initData(){
    getBookingStore(context).getDateWiseData(startDate, endDate,selectedBusNumber).then((val){
      List<Booking> bookingList = val;
      cash = bookingList.fold(0, (sum, booking) => sum + Global.parseLocalizedNumber(booking.cash ?? "0"));
      pending = bookingList.fold(0, (sum, booking) => sum + Global.parseLocalizedNumber(booking.pending ?? "0"));
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
                          ),
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        SizedBox(
                          width: Responsive.isDesktop(context)
                              ? MediaQuery.of(context).size.width / 4
                              : MediaQuery.of(context).size.width,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  onTap: (){
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
                              SizedBox(width: Dimens.width_20,),
                              SizedBox(
                                width: Dimens.width_120,
                                child: AppDropDown(
                                  selectedItem: selectedBusNumber,
                                  items: bookStore.busNumberList,
                                  onItemSelected: (val) {
                                    setState(() {
                                      selectedBusNumber = val;
                                    });
                                    initData();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        textTile(
                          title: Languages.of(context)!.cash,
                          value: cash,
                        ),
                        SizedBox(
                          height: Dimens.height_20,
                        ),
                        textTile(
                          title: Languages.of(context)!.pending,
                          value: pending,
                          boxColor: redColor
                        )
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
              maxDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
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

}
