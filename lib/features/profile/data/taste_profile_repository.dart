import "package:cloud_firestore/cloud_firestore.dart";
import 'package:similar_eats_desktop/features/profile/models/taste_profile.dart';

/// Super simple Firestore repo. No auth yet; uses a fixed dev user ID.
/// Later, swap userId for FirebaseAuth.instance.currentUser!.uid.
class TasteProfileRepository {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection("tasteProfiles");

  Future<void> saveMyProfile(
    TasteProfile profile, {
    String userId = "local-dev-user",
  }) async {
    await _col.doc(userId).set(
          profile.toJson(),
          SetOptions(merge: true),
        );
  }

  Future<TasteProfile> loadMyProfile({String userId = "local-dev-user"}) async {
    final snap = await _col.doc(userId).get();
    if (!snap.exists) return TasteProfile.empty();
    return TasteProfile.fromJson(snap.data());
  }
}
