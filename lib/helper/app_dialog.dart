import 'package:flutter/material.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/screens/dialog/driver_details_dialog.dart';
import 'package:guruchaya/screens/dialog/place_dialog.dart';
import 'package:guruchaya/screens/dialog/village_dialog.dart';
import '../language/language_data.dart';
import '../screens/dialog/change_bus_number_dialog.dart';
import '../screens/dialog/confirmation_dialog.dart';
import '../screens/dialog/language_dialog.dart';
import '../screens/dialog/passenger_details_dialog.dart';
import '../screens/dialog/selected_bus_number_dialog.dart';


class AppDialog {

  static languageDialog(BuildContext context,
      {required Function(LanguageData value) onTap}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LanguageDialog(onTap);
      },
    );
  }

  static confirmationDialog(BuildContext context,
      {required String title,required String msg,required Function(bool value) onTap}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(title,msg,onTap);
      },
    );
  }

  static passengerDetailsDialog(BuildContext context,
      {bool isSplitOption = false,String? seatNo,String? selectedSplitSeatNo,Booking? booking,required Function(String name, String place, String number, String village, String cash, String pending,String secondaryNumber,bool? isSplit, String? splitSeatNumber) onSubmit,Function(bool? isSplit, String? splitSeatNumber)? onCancel,required List<Booking> bookingList}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PassengerDetailsDialog(onSubmit,booking,onCancel,isSplitOption,seatNo,selectedSplitSeatNo,bookingList);
      },
    );
  }

  static driverDetailsDialog(BuildContext context,String busNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DriverDetailsDialog(busNumber);
      },
    );
  }

  static placeDialog(BuildContext context,{required Function(String name) onSubmit}){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlaceDialog(onSubmit);
      },
    );
  }

  static villageDialog(BuildContext context,{required Function(String name) onSubmit}){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return VillageDialog(onSubmit);
      },
    );
  }

  static changeBusNumberDialog(BuildContext context,
      {required String currentBusNumber,required Function(String changeBusNumber) onSubmit,}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangeBusNumberDialog(currentBusNumber,onSubmit);
      },
    );
  }

  static selectBusNumbersDialog(BuildContext context,{required List<String> selectedNumber , required Function(List<String> val) onSubmit}){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SelectedBusNumberDialog(selectedNumber, onSubmit);
      },
    );
  }


}
