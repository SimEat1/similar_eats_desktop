import "dart:math";

class PublicProfile {
  final String uid;
  final String displayName;
  final String friendCode;
  final String? photoUrl;
  final String? handle;
  final String? city;

  const PublicProfile({
    required this.uid,
    required this.displayName,
    required this.friendCode,
    this.photoUrl,
    this.handle,
    this.city,
  });

  factory PublicProfile.fromJson(String uid, Map<String, dynamic> j) =>
      PublicProfile(
        uid: uid,
        displayName: (j["displayName"] ?? "") as String,
        friendCode: (j["friendCode"] ?? "") as String,
        photoUrl: j["photoUrl"] as String?,
        handle: j["handle"] as String?,
        city: j["city"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "displayName": displayName,
        "friendCode": friendCode,
        "photoUrl": photoUrl,
        "handle": handle,
        "city": city,
      };

  // Simple base32 (no 0/O/I/1) code generator
  static String newFriendCode({int len = 8}) {
    const alphabet = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
    final r = Random.secure();
    return List.generate(len, (_) => alphabet[r.nextInt(alphabet.length)])
        .join();
  }
}
