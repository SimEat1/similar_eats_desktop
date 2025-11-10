import "package:cloud_firestore/cloud_firestore.dart";

class PhenomNom {
  final String? id;
  final String restaurantName;
  final String? restaurantId;
  final DateTime createdAt;

  const PhenomNom({
    this.id,
    required this.restaurantName,
    this.restaurantId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "restaurantName": restaurantName,
        "restaurantId": restaurantId,
        "createdAt": createdAt, // Firestore plugin stores DateTime as Timestamp
      };

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }

  factory PhenomNom.fromJson(Map<String, dynamic> j, String id) => PhenomNom(
        id: id,
        restaurantName: (j["restaurantName"] ?? "").toString(),
        restaurantId: j["restaurantId"] as String?,
        createdAt: _ts(j["createdAt"]),
      );
}
