import "package:cloud_firestore/cloud_firestore.dart";

class FriendRequest {
  final String fromUid;
  final String fromName;
  final DateTime createdAt;

  const FriendRequest({
    required this.fromUid,
    required this.fromName,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        "fromUid": fromUid,
        "fromName": fromName,
        "createdAt": createdAt,
      };

  static DateTime _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  factory FriendRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? {};
    return FriendRequest(
      fromUid: (j["fromUid"] ?? "").toString(),
      fromName: (j["fromName"] ?? "").toString(),
      createdAt: _ts(j["createdAt"]),
    );
  }
}
