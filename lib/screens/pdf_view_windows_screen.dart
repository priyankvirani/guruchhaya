import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/global.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:provider/provider.dart';
import 'package:webview_windows/webview_windows.dart';


class PdfWindowsScreen extends StatefulWidget {
  String busNumber;
  String date;
  String driver;
  String conductor;
  String time;
  String to;

  PdfWindowsScreen(
      {required this.busNumber,
      required this.date,
      required this.driver,
      required this.conductor,
      required this.time,
      required this.to});

  @override
  State<PdfWindowsScreen> createState() => _PdfWindowsScreenState();
}

class _PdfWindowsScreenState extends State<PdfWindowsScreen> {
  Uint8List? pdfBytes;

  String htmlContent = '';

  WebviewController controller = WebviewController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.initialize();
      var bookingStore = getBookingStore(context);
      bookingStore.changeLoadingStatus(true);
      htmlContent = await Global.getHtmlContent(
        date: widget.date,
        busNumber: widget.busNumber,
        scaleFactor: MediaQuery.of(context).textScaleFactor,
        driver: widget.driver,
        conductor: widget.conductor,
        time: widget.time,
        suratTo: widget.to,
      );
      bookingStore.changeLoadingStatus(false);

      controller.loadStringContent(htmlContent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:
          Consumer<BookingController>(builder: (context, bookStore, snapshot) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(Dimens.padding_20),
                  child: BackAppBar(
                    title: "${Languages.of(context)!.guruchhayaTravels}(${widget.busNumber}) - ${widget.date}",
                  ),
                ),
                Expanded(
                  child: Webview(controller),
                )
              ],
            ),
            //LoadingWithBackground(bookStore.loading)
          ],
        );
      }),
    );
  }
}
