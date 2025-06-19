import 'dart:io';

import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../model/booking.dart';
import '../provider/booking_provider.dart';

class Global {
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
    'K',
    'K',
    'K',
    'K',
    'K',
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
    'K',
    'K',
    'K',
    'K',
    'K',
    'Total'
  ];

  static String getHtmlContent(
      {required String date, required String busNumber}) {
    String htmlContent = '''
<!DOCTYPE html>
<html lang="gu">
<head>
  <meta charset="UTF-8">
  <title>Gujarati Table - Mobile View</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Google Fonts -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Gujarati&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Kumar+One&display=swap" rel="stylesheet">

  <style>
    body {
      margin: 0;
      background-color: #fff;
      font-family: 'Noto Sans Gujarati', sans-serif;
    }

    .outer-border {
      border: 1px solid #000;
      margin: 16px;
      padding: 0;
    }

    .header-line {
      display: flex;
      justify-content: space-between;
      font-size: 10px;
      margin: 10px;
    }
    
    .fancy-title-centered-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  margin: 10px auto;
  flex-wrap: wrap;
}

.fancy-title {
  display: inline-flex;
  align-items: baseline;
  gap: 6px;
}

    .fancy-title-centered-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
  margin-top: 5px;
  margin-bottom: 5px;
}


.title-driver-wrapper {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  position: relative;
  margin: 10px 10px 0 10px;
  flex-wrap: wrap;
  margin-bottom: 20px; 
}

.fancy-title {
  display: inline-flex;
  align-items: baseline;
  gap: 6px;
  position: absolute;
  left: 50%;
  transform: translateX(-50%);
  text-align: center;
}

.fancy-title .big {
  font-family: 'Kumar One', cursive;
  font-size: 48px;
  color: #B80000;
  text-shadow: 1px 1px 2px rgba(255, 0, 0, 0.3);
}

.fancy-title .small {
  font-family: 'Kumar One', cursive;
  font-size: 24px;
  font-weight: 500;
  color: #B80000;
  text-shadow: 1px 1px 2px rgba(255, 0, 0, 0.3);
}

.right-info {
  font-size: 12px;
  text-align: right;
  margin-left: auto;
  line-height: 2.2;
  margin-top: 20px; 
}
   

    .info-line {
      font-size: 14px;
      display: flex;
      justify-content: space-between;
      flex-wrap: wrap;
      margin: 10px;
    }
    
    .info-row {
  font-size: 12px;
  display: flex;
  flex-wrap: nowrap;
  justify-content: space-between;
  gap: 10px;
  margin: 10px;
  overflow-x: auto;
  white-space: nowrap;
}

    .table-wrapper {
      overflow-x: auto;
      margin: 0;
    }

    table {
      border-collapse: collapse;
      width: 100%;
      min-width: 600px;
      table-layout: fixed;
    }

    th, td {
      border: 1px solid #000;
      text-align: center;
      padding: 3px 2px; 
      font-size: 14px;
      white-space: normal;
      word-break: break-word;  
    }

    /* Make the name column wider */
    th:nth-child(1), td:nth-child(1) {   /* સંખ્યા */
      width: 20px;
    }
    th:nth-child(3), td:nth-child(2) {
      width: 100px;
    }
    th:nth-child(4), td:nth-child(4) {   /* રોકડા */
      width: 45px;
    }
    th:nth-child(5), td:nth-child(5) {   /* બાકી */
      width: 45px;
    }
    th:nth-child(6), td:nth-child(6) {   /* સીટ નંબર */
      width: 40px;
    }
    th:nth-child(8), td:nth-child(6) {   /* સીટ નંબર */
      width: 80px;
    }

    th {
      background-color: #f2f2f2;
      font-weight: bold;
    }

    .total-section {
      margin-top: 5px;
      font-size: 11px;
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
  <div class="fancy-title">
    <span class="big">ગુરૂછાયા</span>
    <span class="small">ટ્રાવેલ્સ</span>
  </div>
  <div class="right-info">
    ડ્રાઈવર : ________________________________<br>
    કન્ડક્ટર : ________________________________
  </div>
</div>

    <!-- Info Line -->
    <div class="info-line info-row">
        <span>તા. $date</span>
        <span>સમય : ___________________</span>
        <span>ગાડી નં. $busNumber</span>
        <span>સુરત થી ______________________________________________________</span>
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

  static String generateTableRows() {
    var bookingStore = getBookingStore(NavigationService.context);
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

    double totalAmount = bookingStore.bookingList.fold(0.0, (sum, booking) {
      return sum + (int.parse(booking.cash ?? "0"));
    });
    double totalPendingAmount =
        bookingStore.bookingList.fold(0.0, (sum, booking) {
      return sum + (int.parse(booking.pending ?? "0"));
    });

    String rows = '';

    for (int index = 0; index < seatLayout.length; index++) {
      final seat = seatLayout[index];
      final gujaratiSeat = gujaratiSeatLayout[index];
      Booking? booking;
      if (seat.contains("-")) {
        List splitSeatNo = bookingStore.getSplitSeatNo(seat);
        if (splitSeatNo.isEmpty) {
          booking = lists.firstWhere((b) {
              return b.seatNumber == seat;
            },
            orElse: () => Booking(),
          );
        } else {
          List<Booking> list = bookingStore.getListOfBookingInfo(splitSeatNo) ?? [];
          if (list.isEmpty) {
            booking = lists.firstWhere((b) {
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
              mobileNumber: '${list[0].mobileNumber ?? "-"}<br>${list[1].mobileNumber ?? "-"}',
              secondaryMobileNumber: '${list[0].secondaryMobileNumber ?? "-"}<br>${list[1].secondaryMobileNumber ?? "-"}',
              place: '${list[0].place!.split("(").first}<br>${list[1].place!.split("(").first}',
              villageName: '${list[0].villageName}<br>${list[1].villageName}',
            );
          } else {
            booking = lists.firstWhere((b) {
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

      final no = seat == 'K'
          ? 'K'
          : seat.contains('-')
              ? '૨'
              : '૧';

      String mobileNumber = booking.mobileNumber ?? '';
      if(booking.mobileNumber != null && !booking.mobileNumber!.contains("<br>")){
        if (booking.secondaryMobileNumber != null && booking.secondaryMobileNumber!.isNotEmpty) {
          mobileNumber = '$mobileNumber / ${booking.secondaryMobileNumber}';
        }
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
      <td>${seat == 'K' ? '' : gujaratiSeat}</td>
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
    }else if(Platform.isMacOS){

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
}
