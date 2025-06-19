class Booking {
  String? id;
  String? busNumber;
  String? seatNumber;
  String? date;
  String? fullName;
  String? place;
  String? cash;
  String? pending;
  String? mobileNumber;
  String? secondaryMobileNumber;
  String? villageName;
  DateTime? createdAt;
  bool? isSplit;

  Booking({
    this.id,
    this.busNumber,
    this.seatNumber,
    this.date,
    this.fullName,
    this.place,
    this.cash,
    this.mobileNumber,
    this.secondaryMobileNumber,
    this.villageName,
    this.createdAt,
    this.pending,
    this.isSplit,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
      id: json["id"],
      busNumber: json["bus_number"],
      seatNumber: json["seat_number"],
      date: json["date"],
      fullName: json["full_name"],
      place: json["place"],
      cash: json["cash"],
      mobileNumber: json["mobile_number"],
      secondaryMobileNumber: json["secondary_mobile"],
      villageName: json["village_name"],
      createdAt: json["created_at"] == null
          ? null
          : DateTime.parse(json["created_at"]),
      pending: json["pending"],
      isSplit: json["is_split"]
  );

  Map<String, dynamic> toJson() => {
        "id": id,
        "bus_number": busNumber,
        "seat_number": seatNumber,
        "date": date,
        "full_name": fullName,
        "place": place,
        "cash": cash,
        "mobile_number": mobileNumber,
        "secondary_mobile": secondaryMobileNumber,
        "village_name": villageName,
        "created_at": createdAt?.toIso8601String(),
        "pending": pending,
        "isSplit": isSplit,
      };
}
