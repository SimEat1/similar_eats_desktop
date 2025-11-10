import "dart:math";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

import 'package:similar_eats_desktop/features/friends/models/public_profile.dart';
import 'package:similar_eats_desktop/features/friends/models/friend_request.dart';

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';

class FriendsRepository {
  final _db = FirebaseFirestore.instance;
  String? get _uid => PlatformHelper.getCurrentUid(
      firebaseUid: FirebaseAuth.instance.currentUser?.uid);

  // --- Friend code helpers ---
  static String _randCode([int len = 8]) {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // no 0/1/O/I
    final r = Random.secure();
    return List.generate(len, (_) => chars[r.nextInt(chars.length)]).join();
  }

  // Ensure my public card exists (idempotent) and reserve a unique friend code.
  Future<PublicProfile?> ensureMyProfile({String? displayName}) async {
    final uid = _uid;
    if (uid == null) return null;
    final cardRef = _db.collection("publicProfiles").doc(uid);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(cardRef);
      String? code;
      final needCode =
          !existing.exists || (existing.data()?["friendCode"] == null);

      if (needCode) {
        // generate + reserve a unique code in /friendCodes/{code}
        while (true) {
          final cand = _randCode();
          final lock = _db.collection("friendCodes").doc(cand);
          final taken = await tx.get(lock);
          if (!taken.exists) {
            tx.set(lock, {"uid": uid});
            code = cand;
            break;
          }
        }
      }

      if (!existing.exists || displayName != null || code != null) {
        final name = displayName ??
            (FirebaseAuth.instance.currentUser?.displayName ??
                "Similar Eats user");
        tx.set(
            cardRef,
            {
              if (code != null) "friendCode": code,
              "displayName": name,
              "updatedAt": FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true));
      }
    });

    final got = await cardRef.get();
    return PublicProfile.fromDoc(got);
  }

  Stream<PublicProfile?> myProfileStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection("publicProfiles")
        .doc(uid)
        .snapshots()
        .map((d) => d.exists ? PublicProfile.fromDoc(d) : null);
  }

  // Lookup by friend code
  Future<PublicProfile?> findByCode(String code) async {
    final q = await _db
        .collection("publicProfiles")
        .where("friendCode", isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return PublicProfile.fromDoc(q.docs.first);
  }

  // --- Collections ---
  CollectionReference<Map<String, dynamic>> _reqCol(String uid) =>
      _db.collection("users").doc(uid).collection("friendRequests");
  CollectionReference<Map<String, dynamic>> _friendsCol(String uid) =>
      _db.collection("users").doc(uid).collection("friends");
  CollectionReference<Map<String, dynamic>> _followingCol(String uid) =>
      _db.collection("users").doc(uid).collection("following");

  // Send request
  Future<void> sendFriendRequest(String targetUid) async {
    final me = _uid;
    if (me == null || me == targetUid) return;
    final myCard = await _db.collection("publicProfiles").doc(me).get();
    final fromName =
        (myCard.data()?["displayName"] ?? "") as String? ?? "Similar Eats user";
    await _reqCol(targetUid).doc(me).set(
        FriendRequest(
          fromUid: me,
          fromName: fromName,
          createdAt: DateTime.now(),
        ).toJson(),
        SetOptions(merge: true));
  }

  // Accept request
  Future<void> acceptFriend(String fromUid) async {
    final me = _uid;
    if (me == null) return;
    final batch = _db.batch();
    batch.set(_friendsCol(me).doc(fromUid), {"since": DateTime.now()});
    batch.set(_friendsCol(fromUid).doc(me), {"since": DateTime.now()});
    batch.delete(_reqCol(me).doc(fromUid));
    await batch.commit();
  }

  // Follow/Unfollow
  Future<void> follow(String otherUid) async {
    final me = _uid;
    if (me == null || me == otherUid) return;
    await _followingCol(me).doc(otherUid).set({"since": DateTime.now()});
  }

  Future<void> unfollow(String otherUid) async {
    final me = _uid;
    if (me == null) return;
    await _followingCol(me).doc(otherUid).delete();
  }

  // --- Chunked lookups (>10) ---
  Stream<List<PublicProfile>> streamFriends() {
    final me = _uid;
    if (me == null) return const Stream.empty();
    return _friendsCol(me).snapshots().asyncMap((s) async {
      final ids = s.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return <PublicProfile>[];
      final chunks = <List<String>>[];
      for (int i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }
      final results = await Future.wait(chunks.map((c) => _db
          .collection("publicProfiles")
          .where(FieldPath.documentId, whereIn: c)
          .get()));
      return results
          .expand((qs) => qs.docs.map(PublicProfile.fromDoc))
          .toList();
    });
  }

  Stream<List<PublicProfile>> streamFollowing() {
    final me = _uid;
    if (me == null) return const Stream.empty();
    return _followingCol(me).snapshots().asyncMap((s) async {
      final ids = s.docs.map((d) => d.id).toList();
      if (ids.isEmpty) return <PublicProfile>[];
      final chunks = <List<String>>[];
      for (int i = 0; i < ids.length; i += 10) {
        chunks.add(ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10));
      }
      final results = await Future.wait(chunks.map((c) => _db
          .collection("publicProfiles")
          .where(FieldPath.documentId, whereIn: c)
          .get()));
      return results
          .expand((qs) => qs.docs.map(PublicProfile.fromDoc))
          .toList();
    });
  }

  // Pending friend requests addressed to me (newest first)
  Stream<List<FriendRequest>> streamRequests() {
    final me = _uid;
    if (me == null) return const Stream.empty();
    return _reqCol(me)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data();
              final ts = data["createdAt"];
              DateTime when;
              if (ts is Timestamp) {
                when = ts.toDate();
              } else if (ts is DateTime) {
                when = ts;
              } else {
                when = DateTime.now();
              }
              return FriendRequest(
                fromUid: d.id,
                fromName: (data["fromName"] ?? "Similar Eats user") as String,
                createdAt: when,
              );
            }).toList());
  }
}
