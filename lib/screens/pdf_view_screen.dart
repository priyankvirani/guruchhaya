import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:guruchaya/helper/dimens.dart';
import 'package:guruchaya/helper/global.dart';
import 'package:guruchaya/helper/string.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/provider/booking_provider.dart';
import 'package:guruchaya/widgets/appbar.dart';
import 'package:guruchaya/widgets/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../helper/navigation.dart';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;

class PdfScreen extends StatefulWidget {
  String busNumber;
  String date;

  PdfScreen({required this.busNumber, required this.date});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  Uint8List? pdfBytes;

  String htmlContent = '';
  WebViewController? _controller;

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
        scaleFactor: MediaQuery.of(context).textScaleFactor,
      );

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(htmlContent);
      bookingStore.changeLoadingStatus(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    double scale = MediaQuery.of(context).textScaleFactor;
    print(scale);
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
                    title: "Guruchhaya(${widget.busNumber}) - ${widget.date}",
                  ),
                ),
                Expanded(
                  child: _controller == null
                      ? SizedBox()
                      : WebViewWidget(controller: _controller!),
                )
              ],
            ),
            LoadingWithBackground(bookStore.loading)
          ],
        );
      }),
    );
  }

}

// class PdfScreen extends StatefulWidget {
//   String busNumber;
//   String date;
//
//   PdfScreen({required this.busNumber, required this.date});
//
//   @override
//   State<PdfScreen> createState() => _PdfScreenState();
// }
//
// class _PdfScreenState extends State<PdfScreen> {
//   Uint8List? pdfBytes;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       var bookingStore = getBookingStore(context);
//       bookingStore.changeLoadingStatus(true);
//       await generatePDF();
//       bookingStore.changeLoadingStatus(false);
//     });
//   }
//
//   final seatLayout = [
//     '1',
//     '2',
//     '3-4',
//     '5-6',
//     '7',
//     '8',
//     '9-10',
//     '11-12',
//     '13',
//     '14',
//     '15-16',
//     '17-18',
//     '19',
//     '20',
//     '21-22',
//     '23-24',
//     '25',
//     '26',
//     '27-28',
//     '29-30',
//     '31',
//     '32',
//     '33-34',
//     '35-36',
//     'K',
//     'K',
//     'K',
//     'K',
//     'K',
//   ];
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body:
//       Consumer<BookingController>(builder: (context, bookStore, snapshot) {
//         return Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Padding(
//                   padding: EdgeInsets.all(Dimens.padding_20),
//                   child: BackAppBar(
//                     title: "Guruchhaya(${widget.busNumber}) - ${widget.date}",
//                   ),
//                 ),
//                 if (pdfBytes != null)
//                   Expanded(
//                     child: SfPdfViewerTheme(
//                       data: SfPdfViewerThemeData(
//                         backgroundColor:
//                         Theme.of(context).scaffoldBackgroundColor,
//                       ),
//                       child: SfPdfViewer.memory(
//                         pdfBytes!,
//                       ),
//                     ),
//                   )
//
//
//               ],
//             ),
//             LoadingWithBackground(bookStore.loading)
//           ],
//         );
//       }),
//     );
//   }
//
//   Future<pw.Font> loadUnicodeFont() async {
//     final gujaratiFont = pw.Font.ttf(
//       await rootBundle.load('assets/fonts/NotoSansGujarati-Medium.ttf'),
//     );
//     return gujaratiFont;
//   }
//
//   Future<void> generatePDF() async {
//     pw.Font font = await loadUnicodeFont();
//     var bookingStore = getBookingStore(context);
//     List<Booking> lists = bookingStore.bookingList;
//     lists.sort((a, b) {
//       int seatA;
//       int seatB;
//       if (a.seatNumber!.contains('-')) {
//         seatA = int.parse(a.seatNumber!.split("-").first);
//       } else {
//         seatA = int.parse(a.seatNumber!);
//       }
//       if (b.seatNumber!.contains('-')) {
//         seatB = int.parse(b.seatNumber!.split("-").first);
//       } else {
//         seatB = int.parse(b.seatNumber!);
//       }
//       return seatA.compareTo(seatB);
//     });
//
//     double totalAmount = lists.fold(0.0, (sum, booking) {
//       return sum + (int.parse(booking.cash ?? "0"));
//     });
//
//     double totalPendingAmount = lists.fold(0.0, (sum, booking) {
//       return sum + (int.parse(booking.pending ?? "0"));
//     });
//
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.MultiPage(
//         build: (context) {
//           return [
//             pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Text(
//                     'Guruchhaya (${widget.busNumber})',
//                     style: pw.TextStyle(
//                       fontSize: Dimens.dimen_24,
//                       fontWeight: pw.FontWeight.bold,
//                       font: font,
//                     ),
//                   ),
//                   pw.Text(
//                     '${Languages.of(NavigationService.context)!.date} : ${widget.date}',
//                     style: pw.TextStyle(
//                       fontSize: Dimens.dimen_14,
//                       font: font,
//                     ),
//                   ),
//                 ]),
//             pw.SizedBox(height: Dimens.height_20),
//             pw.Table.fromTextArray(
//               headers: [
//                 Languages.of(NavigationService.context)!.number,
//                 Languages.of(NavigationService.context)!.name,
//                 Languages.of(NavigationService.context)!.place,
//                 Languages.of(NavigationService.context)!.cash,
//                 Languages.of(NavigationService.context)!.pending,
//                 Languages.of(NavigationService.context)!.seatNo,
//                 Languages.of(NavigationService.context)!.mobileNumber,
//                 Languages.of(NavigationService.context)!.village,
//               ],
//               data: List.generate(
//                 seatLayout.length,
//                     (index) {
//                   final seat = seatLayout[index];
//                   final booking = lists.firstWhere(
//                         (b) => b.seatNumber == seat,
//                     orElse: () => Booking(),
//                   );
//
//                   return [
//                     seat == 'K' ? seat : (index + 1).toString(),
//                     booking.fullName ?? '',
//                     booking.place ?? '',
//                     booking.cash ?? '',
//                     booking.pending ?? '',
//                     booking.seatNumber ?? (seat == 'K' ? '' : seat),
//                     booking.mobileNumber ?? '',
//                     booking.villageName ?? '',
//                   ];
//                 },
//               ),
//               cellStyle: pw.TextStyle(fontSize: Dimens.fontSize_8, font: font),
//               headerStyle: pw.TextStyle(
//                   fontSize: Dimens.fontSize_8,
//                   fontWeight: pw.FontWeight.bold,
//                   color: PdfColors.black,
//                   font: font),
//               headerDecoration:
//               const pw.BoxDecoration(color: PdfColors.grey300),
//             ),
//             pw.SizedBox(height: Dimens.height_20),
//             pw.Text(
//               '${Languages.of(NavigationService.context)!.totalCollection} : ${totalAmount.toStringAsFixed(0)}',
//               style: pw.TextStyle(
//                 fontSize: Dimens.dimen_18,
//                 fontWeight: pw.FontWeight.bold,
//                 font: font,
//               ),
//             ),
//           ];
//         },
//       ),
//     );
//     pdfBytes = await pdf.save();
//     setState(() {});
//   }
//
//
// }
