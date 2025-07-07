import 'package:flutter/material.dart';

abstract class Languages {

  static Languages? of(BuildContext context) {
    return Localizations.of<Languages>(context, Languages);
  }


  String get yes;
  String get no;
  String get language;
  String get login;
  String get loginContent;
  String get email;
  String get submit;
  String get emailRequired;
  String get password;
  String get passwordRequired;
  String get noUserFound;
  String get bookTicket;
  String get pleaseSelectSeat;
  String get upper;
  String get lower;
  String get passengerDetails;
  String get fullName;
  String get place;
  String get mobileNumber;
  String get village;
  String get cash;
  String get fullNameRequired;
  String get placeRequired;
  String get mobileNumberRequired;
  String get villageRequired;
  String get cancel;
  String get booked;
  String get available;
  String get allBooking;
  String get setting;
  String get amount;
  String get amountRequired;
  String get cancelBooking;
  String get cancelBookingContent;
  String get enterManually;
  String get pickPlace;
  String get seat;
  String get guruchhayaTravels;
  String get date;
  String get number;
  String get name;
  String get pending;
  String get seatNo;
  String get totalCollection;
  String get secondaryMobileNumber;
  String get split;
  String get changeBusNumberForAllBooking;
  String get changeBusNumber;
  String get selectBusNumberYouWantToChange;
  String get selectBusNumber;
  String get areYouSureYouWantToChangeThisBusNumberForAllBooking;
  String get changeBusNumberForThisSeat;
  String get details;
  String get driver;
  String get conductor;
  String get time;
  String get suratTo;
  String get saved;
  String get allBusBooking;
}