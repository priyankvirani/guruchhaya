import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/helper/string.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../model/booking.dart';
import '../provider/booking_provider.dart';

class Global {
  static bool containsGujaratiDigits(String text) {
    final gujaratiDigitRegex = RegExp(r'[૦-૯]');
    return gujaratiDigitRegex.hasMatch(text);
  }

  static int parseLocalizedNumber(String input) {
    if (containsGujaratiDigits(input)) {
      return gujaratiToEnglishInt(input);
    } else {
      return int.tryParse(input) ?? 0;
    }
  }

  static int gujaratiToEnglishInt(String gujaratiNumber) {
    const gujaratiDigits = ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String englishNumber = gujaratiNumber.split('').map((char) {
      int index = gujaratiDigits.indexOf(char);
      return index != -1 ? englishDigits[index] : char;
    }).join('');

    return int.tryParse(englishNumber) ?? 0;
  }

  static List<String> seatLayout = [
    '1',
    '2',
    '3-4',
    '5-6',
    '7',
    '8',
    '9-10',
    '11-12',
    '13',
    '14',
    '15-16',
    '17-18',
    '19',
    '20',
    '21-22',
    '23-24',
    '25',
    '26',
    '27-28',
    '29-30',
    '31',
    '32',
    '33-34',
    '35-36',
    'K1',
    'K2',
    'K3',
    'K4',
    'K5',
    'K6',
    'Total'
  ];

  static List<String> gujaratiSeatLayout = [
    '૧',
    '૨',
    '૩-૪',
    '૫-૬',
    '૭',
    '૮',
    '૯-૧૦',
    '૧૧-૧૨',
    '૧૩',
    '૧૪',
    '૧૫-૧૬',
    '૧૭-૧૮',
    '૧૯',
    '૨૦',
    '૨૧-૨૨',
    '૨૩-૨૪',
    '૨૫',
    '૨૬',
    '૨૭-૨૮',
    '૨૯-૩૦',
    '૩૧',
    '૩૨',
    '૩૩-૩૪',
    '૩૫-૩૬',
    'K1',
    'K2',
    'K3',
    'K4',
    'K5',
    'K6',
    'Total'
  ];

  static Future<String> getHtmlContent({
    required String date,
    required String busNumber,
    required double scaleFactor,
    required String driver,
    required String conductor,
    required String time,
    required String suratTo,
  }) async {
    final ByteData imageBytes = await rootBundle.load(Images.guruchhaya);
    final Uint8List bytes = imageBytes.buffer.asUint8List();
    final String base64Image = base64Encode(bytes);

    String htmlContent = '''
<!DOCTYPE html>
<html lang="gu">
<head>
  <meta charset="UTF-8">
  <title>${Languages.of(NavigationService.context)!.guruchhayaTravels}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Gujarati&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Kumar+One&display=swap" rel="stylesheet">

  <style>
    /* Prevent system font scaling */
    html, body {
      font-size: ${14 / scaleFactor}px;
      -webkit-text-size-adjust: none !important;
      -moz-text-size-adjust: none !important;
      -ms-text-size-adjust: none !important;
      text-size-adjust: none !important;
    }

    body {
      margin: 0;
      padding: 20px;
      background-color: #fff;
      font-family: 'Noto Sans Gujarati', sans-serif;
      width: 210mm; /* A4 width */
      height: 297mm; /* A4 height */
      box-sizing: border-box;
    }

    .outer-border {
      border: 1px solid #000;
      padding: 10px;
    }

    .header-line {
      display: flex;
      justify-content: space-between;
      font-size: ${10 / scaleFactor}px;
      margin-bottom: 10px;
    }

    .title-driver-wrapper {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      flex-wrap: wrap;
      margin-bottom: 20px;
    }

    .fancy-title {
      display: flex;
      align-items: baseline;
      gap: 6px;
    }


    .right-info {
      font-size: ${12 / scaleFactor}px;
      text-align: right;
      line-height: 1.8;
    }

    .info-row {
      font-size: ${12 / scaleFactor}px;
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      margin: 10px 0;
      white-space: nowrap;
    }

    .table-wrapper {
      overflow-x: auto;
    }

    table {
      border-collapse: collapse;
      width: 100%;
      min-width: 700px;
      table-layout: fixed;
    }

     th, td {
      border: 1px solid #000;
      text-align: left;
      padding: 3px 2px; 
      font-size: ${14 / scaleFactor}px;
      white-space: normal;
      word-break: break-word;  
    }

    th:nth-child(1), td:nth-child(1) {   /* સંખ્યા */
      width: 20px;
    }
    th:nth-child(3), td:nth-child(3) {  /* place */
      width: 80px;
    }
    th:nth-child(4), td:nth-child(4) {   /* રોકડા */
      width: 50px;
    }
    th:nth-child(5), td:nth-child(5) {   /* બાકી */
      width: 50px;
    }
    th:nth-child(6), td:nth-child(6) {   /* સીટ નંબર */
      width: 60px;
    }
    th:nth-child(8), td:nth-child(8) {   /* સીટ નંબર */
      width: 80px;
    }
    
    th {
      background-color: #f2f2f2;
      font-weight: bold;
    }

    .total-section {
      margin-top: 5px;
      font-size: ${11 / scaleFactor}px;
    }
    
.title-driver-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.logo {
  max-height: ${70 / scaleFactor}px;
  height: auto;
  width: auto;
  display: block;
  margin-left: 20px; 
}

.right-info {
  font-size: ${12 / scaleFactor}px;
  text-align: left;
  line-height: 1.8;
  flex-shrink: 0;
}
    
  </style>
</head>
<body>
  <div class="outer-border">

    <!-- Header -->
    <div class="header-line">
      <div>શ્રી બ્રહ્માણી માં</div>
      <div>|| શ્રી ગણેશાય નમઃ ||</div>
      <div>આઈ શ્રી ખોડિયાર માં</div>
    </div>

    <!-- Title + Driver Info -->
  <div class="title-driver-wrapper">
  <img
    src="data:image/png;base64,$base64Image"
    class="logo"
    alt="Logo"
  />
  <div class="right-info">
    ડ્રાઈવર : ${driver.isNotEmpty ? driver : "________________________________"}<br>
    <span style="display: inline-block; margin-top: 10px;">
    કન્ડક્ટર : ${conductor.isNotEmpty ? conductor : "________________________________"}
  </span>
  </div>
</div>
   
   
    <!-- Info Line -->
    <div class="info-row">
      <span>તા. $date</span>
      <span>સમય : ${time.isNotEmpty ? time : "___________________"}</span>
      <span>ગાડી નં. $busNumber</span>
      <span>સુરત થી  ${suratTo.isNotEmpty ? suratTo : "______________________________________________________"}</span>
    </div>

    <!-- Table -->
    <div class="table-wrapper">
      <table>
        <tr>
          <th>સંખ્યા</th>
          <th>પૂરું નામ</th>
          <th>બેઠક સ્થળ</th>
          <th>રોકડા</th>
          <th>બાકી</th>
          <th>સીટ નંબર</th>
          <th>મોબાઈલ નંબર</th>
          <th>ગામ</th>
        </tr>
        ${generateTableRows()}
        
      </table>
    </div>

  </div>
</body>
</html>
''';
    return htmlContent;
  }

  static double getFontSize(double initialSize, double scale) {
    if (scale <= 1.0) {
      return initialSize;
    } else if (scale <= 1.15) {
      return initialSize / 1.15;
    } else if (scale <= 1.35) {
      return initialSize / 1.35;
    } else {
      return initialSize / scale;
    }
  }

  static String generateTableRows() {
    var bookingStore = getBookingStore(NavigationService.context);
    List<Booking> lists = bookingStore.bookingList;

    double totalAmount = 0;
    double totalPendingAmount = 0;

    String rows = '';

    for (int index = 0; index < seatLayout.length; index++) {
      final seat = seatLayout[index];
      final gujaratiSeat = gujaratiSeatLayout[index];
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
              fullName: '${list[0].fullName}<br>${list[1].fullName}',
              seatNumber: seat,
              cash: '${list[0].cash}<br>${list[1].cash}',
              pending: '${list[0].pending}<br>${list[1].pending}',
              mobileNumber:
                  '${list[0].mobileNumber ?? "-"}<br>${list[1].mobileNumber ?? "-"}',
              secondaryMobileNumber:
                  '${list[0].secondaryMobileNumber ?? "-"}<br>${list[1].secondaryMobileNumber ?? "-"}',
              place:
                  '${list[0].place!.split("(").first}<br>${list[1].place!.split("(").first}',
              villageName: '${list[0].villageName}<br>${list[1].villageName}',
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

      final no = seat.contains('K')
          ? '૧'
          : seat.contains('-')
              ? '૨'
              : '૧';

      String mobileNumber = booking.mobileNumber ?? '';
      if (booking.mobileNumber != null &&
          !booking.mobileNumber!.contains("<br>")) {
        if (booking.secondaryMobileNumber != null &&
            booking.secondaryMobileNumber!.isNotEmpty) {
          mobileNumber = '$mobileNumber / ${booking.secondaryMobileNumber}';
        }
      }
      if ((booking.cash ?? "0").contains("<br>")) {
        totalAmount += double.parse(booking.cash!.split('<br>').first);
        totalAmount += double.parse(booking.cash!.split('<br>').last);
      } else {
        totalAmount += double.parse(booking.cash ?? "0");
      }

      if ((booking.pending ?? "0").contains("<br>")) {
        totalPendingAmount +=
            double.parse(booking.pending!.split('<br>').first);
        totalPendingAmount += double.parse(booking.pending!.split('<br>').last);
      } else {
        totalPendingAmount += double.parse(booking.pending ?? "0");
      }

      if (seat == "Total") {
        rows += '''
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td>${totalAmount.toStringAsFixed(0)}</td>
      <td>${totalPendingAmount.toStringAsFixed(0)}</td>
      <td></td>
      <td></td>
      <td></td>
    </tr>
    ''';
      } else {
        rows += '''
    <tr>
      <td>$no</td>
      <td><span class="space"></span>${booking.fullName ?? ''}<span class="space"></span></td>
      <td>${booking.place == null ? "" : booking.place!.split("(").first}</td>
      <td>${booking.cash == null || booking.cash!.isEmpty || booking.cash == "0" ? "" : booking.cash}</td>
      <td>${booking.pending == null || booking.pending!.isEmpty || booking.pending == "0" ? "" : booking.pending}</td>
      <td>$gujaratiSeat</td>
      <td>$mobileNumber</td>
      <td>${booking.villageName ?? ''}</td>
    </tr>
    ''';
      }
    }
    return rows;
  }

  static Future<void> sharePDF(
      {required String htmlContent,
      required String busNumber,
      required String date}) async {
    final dir = await getTemporaryDirectory();
    print("filePath : ${dir.path}");
    final filePath = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      dir.path,
      "ગુરૂછાયા($busNumber)_${date.replaceAll("/", "-")}",
    );
    await Share.shareXFiles(
      [XFile(filePath.path)],
      text: 'Guruchhaya Travels',
      subject: 'Date : $date\nBus Number : $busNumber',
    );
  }

  static Future<void> downloadPDF(
      {required String htmlContent,
      required String busNumber,
      required String date}) async {
    await requestPermission();

    Directory? dir;

    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download'); // Default Downloads path
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      dir!.path,
      "ગુરૂછાયા($busNumber)_${date.replaceAll("/", "-")}",
    );

    AlertSnackBar.success("✅ PDF saved to: ${filePath.path}");
  }

  static Future<void> requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    } else {
      // Show error or request again
    }
  }

  static Future<String> getHtmlTotalIncome({
    required Map<String, Map<String, int>> incomeData,
    required double scaleFactor,
  }) async {
    final ByteData imageBytes = await rootBundle.load(Images.guruchhaya);
    final Uint8List bytes = imageBytes.buffer.asUint8List();
    final String base64Image = base64Encode(bytes);

    String htmlContent = '''
<!DOCTYPE html>
<html lang="gu">
<head>
  <meta charset="UTF-8">
  <title>${Languages.of(NavigationService.context)!.guruchhayaTravels}</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Gujarati&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Kumar+One&display=swap" rel="stylesheet">

  <style>
    /* Prevent system font scaling */
    html, body {
      font-size: ${14 / scaleFactor}px;
      -webkit-text-size-adjust: none !important;
      -moz-text-size-adjust: none !important;
      -ms-text-size-adjust: none !important;
      text-size-adjust: none !important;
    }

    body {
      margin: 0;
      padding: 20px;
      background-color: #fff;
      font-family: 'Noto Sans Gujarati', sans-serif;
      width: 210mm; /* A4 width */
      height: 297mm; /* A4 height */
      box-sizing: border-box;
    }

    .outer-border {
      border: 1px solid #000;
      padding: 10px;
    }

    .header-line {
      display: flex;
      justify-content: space-between;
      font-size: ${10 / scaleFactor}px;
      margin-bottom: 10px;
    }

    .title-driver-wrapper {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      flex-wrap: wrap;
      margin-bottom: 20px;
    }

    .fancy-title {
      display: flex;
      align-items: baseline;
      gap: 6px;
    }


    .right-info {
      font-size: ${12 / scaleFactor}px;
      text-align: right;
      line-height: 1.8;
    }

    .info-row {
      font-size: ${12 / scaleFactor}px;
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      margin: 10px 0;
      white-space: nowrap;
    }

    .table-wrapper {
      overflow-x: auto;
    }

    table {
      border-collapse: collapse;
      width: 100%;
      min-width: 700px;
      table-layout: fixed;
    }

     th, td {
      border: 1px solid #000;
      text-align: center;
      padding: 3px 2px; 
      font-size: ${14 / scaleFactor}px;
      white-space: normal;
      word-break: break-word;  
    }

    th:nth-child(1), td:nth-child(1) {   
      width: 90px;
    }
    th:nth-child(2), td:nth-child(1) {   
      width: 70px;
    }
    th:nth-child(3), td:nth-child(3) {  
      width: 90px;
    }
    th:nth-child(5), td:nth-child(5) {   /* બાકી */
      width: 90px;
    }
   

    th {
      background-color: #f2f2f2;
      font-weight: bold;
    }

    .total-section {
      margin-top: 5px;
      font-size: ${11 / scaleFactor}px;
    }
    
.title-driver-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 20px;
}

.logo {
  max-height: ${70 / scaleFactor}px;
  height: auto;
  width: auto;
  display: block;
  margin-left: 20px; 
}

.right-info {
  font-size: ${12 / scaleFactor}px;
  text-align: left;
  line-height: 1.8;
  flex-shrink: 0;
}
    
  </style>
</head>
<body>
  <div class="outer-border">

    <!-- Header -->
    <div class="header-line">
      <div>શ્રી બ્રહ્માણી માં</div>
      <div>|| શ્રી ગણેશાય નમઃ ||</div>
      <div>આઈ શ્રી ખોડિયાર માં</div>
    </div>

    <!-- Title + Driver Info -->
  <div class="title-driver-wrapper">
  <img
    src="data:image/png;base64,$base64Image"
    class="logo"
    alt="Logo"
  />
</div>
   
    <!-- Table -->
    <div class="table-wrapper">
      <table>
        <tr>
          <th>તારીખ</th>
          <th>ગાડી નંબર</th>
          <th>ટોટલ</th>
           <th>સહી</th>
          <th>કુલ ટોટલ</th>
          <th>જમા સહી</th>
        </tr>
        ${generateIncomeRows(incomeData)}
      </table>
    </div>

  </div>
</body>
</html>
''';
    return htmlContent;
  }

  static String generateIncomeRows(Map<String, Map<String, int>> incomeData) {
    final sortedDates = incomeData.keys.toList()
      ..sort((a, b) => DateFormat('dd/MM/yyyy')
          .parse(a)
          .compareTo(DateFormat('dd/MM/yyyy').parse(b)));

    String rows = '';

    int totalAmount = 0;

    for (int index = 0; index < sortedDates.length; index++) {
      final date = sortedDates[index];
      final busData = incomeData[date]!;
      int val = 0;
      busData.forEach((key, value) {
        val += value;
      });

      rows += '''
    <tr>
      <td>$date</td>
      <td>${getStringBusNumberList(busData)}</td>
      <td>${getStringBusIncome(busData)}</td>
      <td></td>
      <td>${getThousandValue(val)}</td>
      <td></td>
    </tr>
    ''';
      totalAmount += val;
    }

    String displayTotal = '''<tr>
    <td colspan="2" style="text-align: right; font-weight: bold;">કુલ રકમ</td>
    <td colspan="4" style="font-weight: bold;">${getThousandValue(totalAmount)}</td>
   
  </tr>''';

    rows += displayTotal;

    return rows;
  }

  static getStringBusNumberList(Map<String, int> busData) {
    String val = "";
    busData.forEach((key, value) {
      val += "$key<br>";
    });
    return val;
  }

  static getStringBusIncome(Map<String, int> busData) {
    String val = "";
    busData.forEach((key, value) {
      val += "${getThousandValue(value)}<br>";
    });
    return val;
  }

  static getTotalIncomeFromData(Map<String, int> busData) {
    int val = 0;
    busData.forEach((key, value) {
      val += value;
    });
    return getThousandValue(val);
  }

  static getThousandValue(int value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    ).format(value);
  }

  static Future<void> downloadIncomePDF(
      {required String htmlContent,
        required String date}) async {
    await requestPermission();

    Directory? dir;

    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download'); // Default Downloads path
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      dir!.path,
      "ગુરૂછાયા_આવક_$date",
    );

    AlertSnackBar.success("✅ PDF saved to: ${filePath.path}");
  }

  static Future<void> shareIncomePDF(
      {required String htmlContent,
        required String date}) async {
    await requestPermission();

    Directory? dir;

    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download'); // Default Downloads path
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      dir!.path,
      "ગુરૂછાયા_આવક_$date",
    );
    await Share.shareXFiles(
      [XFile(filePath.path)],
      text: 'ગુરૂછાયા',
      subject: 'Date : $date',
    );
  }

  static printTicket(){
    String htmlContent = '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Bus Ticket</title>
  <style>
    @page {
      size: 25cm 12.7cm;
      margin: 0;
    }

    body {
      margin: 0;
      width: 25cm;
      height: 12.7cm;
      font-family: Arial, sans-serif;
      font-size: 12pt;
      position: relative;

<!--      /* Fix the background image size */-->
<!--      background-image: url('ticket-bg.jpeg');-->
<!--      background-size: 20cm 10cm;-->
<!--      background-repeat: no-repeat;-->
<!--      background-position: top left;-->
    }

    .field {
      position: absolute;
    }
  </style>
</head>
<body>

  <!-- Left Ticket -->
  <div class="field" style="top: 6.7cm; left: 4.8cm;">29/07/25</div>
  <div class="field" style="top: 6.8cm; left: 11.4cm;">1234</div>
  <div class="field" style="top: 7.7cm; left: 3.8cm;">રમેશભાઈ</div>
  <div class="field" style="top: 8.7cm; left: 4.5cm;">10:30</div>
  <div class="field" style="top: 8.8cm; left: 8.7cm;">10:30</div>
  <div class="field" style="top: 8.8cm; left: 12.7cm;">પાલીતાણા</div>
  <div class="field" style="top: 9.7cm; left: 4.1cm;">10-11</div>
  <div class="field" style="top: 9.85cm; left: 14.7cm;">2</div>
  <div class="field" style="top: 10.75cm; left: 4.2cm;">₹500</div>
  <div class="field" style="top: 10.8cm; left: 11.6cm;">₹100</div>

  <!-- Right Ticket -->
  <div class="field" style="top: 6.7cm; left: 18.6cm;">29/07/25</div>
  <div class="field" style="top: 6.8cm; left: 22cm;">1234</div>
  <div class="field" style="top: 7.6cm; left: 18cm;">રમેશભાઈ</div>
  <div class="field" style="top: 8.6cm; left: 18.3cm;">પાલીતાણા</div>
  <div class="field" style="top: 9.7cm; left: 18.6cm;">10:30</div>
  <div class="field" style="top: 9.7cm; left: 22cm;">10:30</div>
  <div class="field" style="top: 10.7cm; left: 18.2cm;">10-11</div>
  <div class="field" style="top: 10.7cm; left: 23.6cm;">2</div>
  <div class="field" style="top: 11.7cm; left: 18.2cm;">₹500</div>
  <div class="field" style="top: 11.7cm; left: 21.9cm;">₹100</div>

</body>
</html>
''';
  }

}
