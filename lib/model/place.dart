class Place {
  String? id;
  String? name;
  DateTime? createdAt;

  Place({
    this.id,
    this.name,
    this.createdAt,
  });

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    id: json["id"].toString(),
    name: json["name"]  ?? '',
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt?.toIso8601String(),
  };
}
