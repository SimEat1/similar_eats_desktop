import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import 'package:similar_eats_desktop/features/favorites/models/phenom_nom.dart';

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';

class PhenomNomsRepository {
  static String keyFor(String name, String? id) {
    final base = (id ?? name).trim().toLowerCase();
    return base.replaceAll(RegExp(r"\s+"), "_");
  }

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("phenomNoms");

  DocumentReference<Map<String, dynamic>> _doc(String uid, String key) =>
      _col(uid).doc(key);

  Future<void> add(PhenomNom item) async {
    final uid = PlatformHelper.getCurrentUid(
        firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    if (uid == null) return;
    final key = keyFor(item.restaurantName, item.restaurantId);
    await _doc(uid, key).set(item.toJson(), SetOptions(merge: true));
  }

  Future<void> removeByKey(String key) async {
    final uid = PlatformHelper.getCurrentUid(
        firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    if (uid == null) return;
    await _doc(uid, key).delete();
  }

  Future<void> toggleByKey(String key, PhenomNom data) async {
    final uid = PlatformHelper.getCurrentUid(
        firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    if (uid == null) return;
    final d = _doc(uid, key);
    final snap = await d.get();
    if (snap.exists) {
      await d.delete();
    } else {
      await d.set(data.toJson(), SetOptions(merge: true));
    }
  }

  Stream<Set<String>> streamKeys() {
    final uid = PlatformHelper.getCurrentUid(
        firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    if (uid == null) return Stream.value(<String>{});
    return _col(uid).snapshots().map((s) => s.docs.map((d) => d.id).toSet());
  }

  Stream<List<PhenomNom>> streamAll() {
    final uid = PlatformHelper.getCurrentUid(
        firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    if (uid == null) return Stream.value(const <PhenomNom>[]);
    return _col(uid).orderBy("createdAt", descending: true).snapshots().map(
        (s) => s.docs.map((d) => PhenomNom.fromJson(d.data(), d.id)).toList());
  }
}
