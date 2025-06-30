import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:guruchaya/helper/navigation.dart';
import 'package:guruchaya/helper/shared_preference.dart';
import 'package:guruchaya/helper/snackbar.dart';
import 'package:guruchaya/language/localization/language/languages.dart';
import 'package:guruchaya/model/booking.dart';
import 'package:guruchaya/model/place.dart';
import 'package:guruchaya/screens/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

BookingController getBookingStore(BuildContext context) {
  var store = Provider.of<BookingController>(context, listen: false);
  return store;
}

class BookingController extends ChangeNotifier {
  bool loading = false;

  changeLoadingStatus(bool status) {
    loading = status;
    notifyListeners();
  }

  String selectedBusNumber = "";

  changeBusNumber(String val) {
    selectedBusNumber = val;
    notifyListeners();
  }

  Future<void> bookSeat({
    required String busNumber,
    required String seatNumber,
    required String date,
    required String fullName,
    required String place,
    required String cash,
    required String pending,
    required String mobileNumber,
    required String villageName,
    required String secondaryNumber,
    bool isSplit = false,
  }) async {
    changeLoadingStatus(true);
    final supabase = Supabase.instance.client;

    await supabase.from('bus_bookings').insert({
      'cash': cash,
      'bus_number': busNumber,
      'seat_number': seatNumber,
      'date': date,
      'full_name': fullName,
      'place': place,
      'mobile_number': mobileNumber,
      'village_name': villageName,
      'pending': pending,
      'secondary_mobile': secondaryNumber,
      'is_split': isSplit
    }).then((val) {
      changeLoadingStatus(false);
    });
  }

  List<Booking> bookingList = [];

  Future<void> getBookedSeats(String busNumber, String date) async {
    changeLoadingStatus(true);
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('bus_bookings')
        .select()
        .eq('date', date)
        .eq('bus_number', busNumber);
    changeLoadingStatus(false);
    if (response == null) {
      throw Exception('No data found');
    }

    bookingList.clear();
    for (var item in response) {
      Booking booking = Booking.fromJson(item);
      bookingList.add(booking);
    }
    notifyListeners();
  }

  bool checkAlreadyBook(String seatNumber) {
    for (var element in bookingList) {
      if (element.isSplit ?? false) {
        if (seatNumber.contains("-")) {
          String seatA = seatNumber.split('-')[0].trim();
          String seatB = seatNumber.split('-')[1].trim();
          if (element.seatNumber!.trim() == seatA ||
              element.seatNumber!.trim() == seatB) {
            return true;
          }
        }
      } else {
        if (element.seatNumber!.trim() == seatNumber.trim()) {
          return true;
        }
      }
    }
    return false;
  }

  bool checkIsSplit(String seatNumber) {
    for (var element in bookingList) {
      if (element.isSplit ?? false) {
        if (seatNumber.contains("-")) {
          String seatA = seatNumber.split('-')[0].trim();
          String seatB = seatNumber.split('-')[1].trim();
          if (element.seatNumber!.trim() == seatA ||
              element.seatNumber!.trim() == seatB) {
            return true;
          }
        }
      }
    }
    return false;
  }

  List getSplitSeatNo(String seatNumber) {
    return bookingList
        .where((booking) => booking.isSplit ?? false)
        .expand((booking) {
      String seatA = seatNumber.split('-')[0].trim();
      String seatB = seatNumber.split('-')[1].trim();
      if (booking.seatNumber!.trim() == seatA ||
          booking.seatNumber!.trim() == seatB) {
        return [booking.seatNumber!];
      } else {
        return [];
      }
    }).toList();
  }

  Booking? getBookingInfo(String seatNumber) {
    for (var element in bookingList) {
      if (element.isSplit ?? false) {
        if (seatNumber.contains("-")) {
          String seatA = seatNumber.split('-')[0].trim();
          String seatB = seatNumber.split('-')[1].trim();
          if (element.seatNumber!.trim() == seatA ||
              element.seatNumber!.trim() == seatB) {
            return element;
          }
        }
      } else {
        if (element.seatNumber!.trim() == seatNumber.trim()) {
          return element;
        }
      }
    }
    return null;
  }

  List<Booking>? getListOfBookingInfo(List seatNumber) {
    return bookingList.where((booking) {
      if (booking.isSplit != true) return false;
      final seats = booking.seatNumber!.split('-');
      return seats.any((seat) => seatNumber.contains(seat));
    }).toList();
  }

  Future<void> updateBooking({
    required String id,
    required String fullName,
    required String villageName,
    required String place,
    required String cash,
    required String pendingAmount,
    required String mobileNumber,
    required String secondaryMobileNumber,
    bool isSplit = false,
  }) async {
    print("mobileNumber : ${mobileNumber}");
    changeLoadingStatus(true);
    final updates = {
      'cash': cash,
      'full_name': fullName,
      'place': place,
      'mobile_number': mobileNumber,
      'secondary_mobile': secondaryMobileNumber,
      'village_name': villageName,
      'pending': pendingAmount
    };
    final supabase = Supabase.instance.client;
    await supabase.from('bus_bookings').update(updates).eq('id', id);
    changeLoadingStatus(false);
  }

  Future<void> deleteBooking({
    required String busNumber,
    required String seatNumber,
    required String date,
  }) async {
    changeLoadingStatus(true);
    final supabase = Supabase.instance.client;
    await supabase
        .from('bus_bookings')
        .delete()
        .eq('bus_number', busNumber)
        .eq('seat_number', seatNumber)
        .eq('date', date);
    changeLoadingStatus(false);
  }

  List<Place> placeList = [];

  Future<void> getAllPlace() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('place')
        .select('*')
        .eq('bus_number', selectedBusNumber);

    placeList.clear();
    for (var item in response) {
      Place place = Place.fromJson(item);
      placeList.add(place);
    }
    notifyListeners();
  }

  List<dynamic> villageList = [];

  Future<void> getAllVillage() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('village')
        .select('*')
        .eq('bus_number', selectedBusNumber);

    villageList = response.map((row) => (row['village'] ?? '')).toList();
    notifyListeners();
  }

  List<dynamic> busNumberList = [];

  Future<void> getAllBusNumber() async {
    final supabase = Supabase.instance.client;
    final response = await supabase.from('bus_numbers').select('bus_number');

    busNumberList = response.map((row) => (row['bus_number'] ?? '')).toList();
    changeBusNumber(busNumberList.first);
    notifyListeners();
  }

  Future<void> changeAllBookingBusNumber({
    required String oldBusNumber,
    required String newBusNumber,
    required String date,
    String? seatNumber,
  }) async {
    changeLoadingStatus(true);
    final supabase = Supabase.instance.client;
    if(seatNumber != null){
      await supabase
          .from('bus_bookings')
          .update({'bus_number':newBusNumber})
          .eq('bus_number', oldBusNumber)
          .eq('seat_number', seatNumber)
          .eq('date', date);
    }else{
      await supabase
          .from('bus_bookings')
          .update({'bus_number':newBusNumber})
          .eq('bus_number', oldBusNumber)
          .eq('date', date);
    }

    changeLoadingStatus(false);
  }

}
