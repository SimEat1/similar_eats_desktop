import "package:cloud_firestore/cloud_firestore.dart";

class PublicProfile {
  final String uid;
  final String displayName;
  final String friendCode;
  final String? photoUrl;
  final DateTime? updatedAt;

  const PublicProfile({
    required this.uid,
    required this.displayName,
    required this.friendCode,
    this.photoUrl,
    this.updatedAt,
  });

  static DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  factory PublicProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? <String, dynamic>{};
    return PublicProfile(
      uid: d.id,
      displayName: (j["displayName"] ?? "").toString(),
      friendCode: (j["friendCode"] ?? "").toString(),
      photoUrl: j["photoUrl"] as String?,
      updatedAt: _ts(j["updatedAt"]),
    );
  }
}
