import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:similar_eats_desktop/features/social/models/public_profile.dart';

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';
class FriendsRepository {
  final _db = FirebaseFirestore.instance;
  String? get _uid => PlatformHelper.getCurrentUid(firebaseUid: FirebaseAuth.instance.currentUser?.uid);

  // Ensure I have a public card with a friendCode
  Future<PublicProfile?> ensureMyPublicCard() async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null) return null;
    final doc = _db.collection("publicProfiles").doc(me.uid);
    final snap = await doc.get();
    if (snap.exists) {
      final data = snap.data()!;
      if ((data["friendCode"] ?? "") == "") {
        final code = PublicProfile.newFriendCode();
        await doc.set({
          "displayName": me.displayName ?? (me.email ?? "User"),
          "friendCode": code,
          "photoUrl": me.photoURL,
        }, SetOptions(merge: true));
      }
    } else {
      final code = PublicProfile.newFriendCode();
      await doc.set({
        "displayName": me.displayName ?? (me.email ?? "User"),
        "friendCode": code,
        "photoUrl": me.photoURL,
      });
    }
    final updated = await doc.get();
    return PublicProfile.fromJson(updated.id, updated.data()!);
  }

  Future<PublicProfile?> getPublic(String uid) async {
    final s = await _db.collection("publicProfiles").doc(uid).get();
    if (!s.exists) return null;
    return PublicProfile.fromJson(s.id, s.data()!);
  }

  Future<PublicProfile?> lookupByCode(String code) async {
    final q = await _db
        .collection("publicProfiles")
        .where("friendCode", isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    final d = q.docs.first;
    return PublicProfile.fromJson(d.id, d.data());
  }

  Future<void> follow(String otherUid) async {
    final me = _uid;
    if (me == null || me == otherUid) return;
    await _db
        .collection("users")
        .doc(me)
        .collection("following")
        .doc(otherUid)
        .set({"at": FieldValue.serverTimestamp()});
  }

  Future<void> unfollow(String otherUid) async {
    final me = _uid;
    if (me == null) return;
    await _db
        .collection("users")
        .doc(me)
        .collection("following")
        .doc(otherUid)
        .delete();
  }

  Future<void> sendFriendRequest(String toUid) async {
    final me = _uid;
    if (me == null || me == toUid) return;
    await _db.collection("users").doc(toUid).collection("friendRequests").add({
      "fromUid": me,
      "toUid": toUid,
      "status": "pending",
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(
      String myUid, String reqId, String fromUid) async {
    final me = _uid;
    if (me == null || me != myUid) return;
    final batch = _db.batch();
    final reqRef = _db
        .collection("users")
        .doc(myUid)
        .collection("friendRequests")
        .doc(reqId);
    batch.update(reqRef, {"status": "accepted"});
    final a =
        _db.collection("users").doc(myUid).collection("friends").doc(fromUid);
    final b =
        _db.collection("users").doc(fromUid).collection("friends").doc(myUid);
    batch.set(a, {"at": FieldValue.serverTimestamp()});
    batch.set(b, {"at": FieldValue.serverTimestamp()});
    await batch.commit();
  }

  Stream<List<PublicProfile>> streamFriends() {
    final me = _uid;
    if (me == null) return const Stream.empty();
    final c = _db.collection("users").doc(me).collection("friends");
    return c.snapshots().asyncMap((s) async {
      final ids = s.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return <PublicProfile>[];
      final snaps = await Future.wait(
          ids.map((id) => _db.collection("publicProfiles").doc(id).get()));
      return snaps
          .where((d) => d.exists)
          .map((d) => PublicProfile.fromJson(d.id, d.data()!))
          .toList();
    });
  }

  Stream<List<({String reqId, String fromUid, String status})>>
      streamRequests() {
    final me = _uid;
    if (me == null) return const Stream.empty();
    final c = _db
        .collection("users")
        .doc(me)
        .collection("friendRequests")
        .orderBy("createdAt", descending: true);
    return c.snapshots().map((s) => s.docs
        .map((d) => (
              reqId: d.id,
              fromUid: (d["fromUid"] ?? "") as String,
              status: (d["status"] ?? "pending") as String
            ))
        .toList());
  }
}


