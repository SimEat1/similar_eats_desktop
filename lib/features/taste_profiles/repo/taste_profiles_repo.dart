import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../firebase_options.dart';
import '../models/taste_profile.dart';

/// RTDB layout used here:
/// /userTaste/{uid}
///    { uid, cuisines: [..], tags: [..], updatedAtMillis: 123 }
class TasteProfilesRepo {
  TasteProfilesRepo({
    FirebaseDatabase? db,
  }) : _db = db ?? _dbForOptions();

  final FirebaseDatabase _db;

  static FirebaseDatabase _dbForOptions() {
    // Build a concrete database instance with explicit app + URL
    final app = Firebase.apps.isNotEmpty
        ? Firebase.apps.first
        : (throw StateError('Firebase app not initialized'));
    final url = DefaultFirebaseOptions.currentPlatform.databaseURL ??
        'https://similar-eats-default-rtdb.firebaseio.com';
    return FirebaseDatabase.instanceFor(app: app, databaseURL: url);
  }

  DatabaseReference _profileRef(String uid) => _db.ref('userTaste/$uid');

  /// Read the current user's profile (or null if none).
  Future<TasteProfile?> getProfile(String uid) async {
    final snap = await _profileRef(uid).get();
    if (!snap.exists || snap.value is! Map) return null;
    final m = Map<String, dynamic>.from(snap.value as Map);
    return TasteProfile.fromJson(m);
  }

  /// Stream the current user's profile (null if deleted/not set).
  Stream<TasteProfile?> watchProfile(String uid) {
    return _profileRef(uid).onValue.map((ev) {
      final v = ev.snapshot.value;
      if (v == null || v is! Map) return null;
      final m = Map<String, dynamic>.from(v as Map);
      return TasteProfile.fromJson(m);
    });
  }

  /// Upsert a profile for uid.
  Future<void> saveProfile(TasteProfile profile) async {
    await _profileRef(profile.uid).set(profile.toJson());
  }

  /// Merge cuisines/tags and bump updatedAt.
  Future<void> mergeProfile({
    required String uid,
    Set<String>? cuisines,
    Set<String>? tags,
  }) async {
    final current = await getProfile(uid);
    final merged = TasteProfile(
      uid: uid,
      cuisines: {...(current?.cuisines ?? {}), ...(cuisines ?? {})},
      tags: {...(current?.tags ?? {}), ...(tags ?? {})},
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await saveProfile(merged);
  }

  /// Compute top N similar users to [uid] by Jaccard similarity
  /// over the union of cuisines+tags.
  Future<List<SimilarUser>> topSimilarUsers(
    String uid, {
    int limit = 10,
    bool includeZero = false,
  }) async {
    final me = await getProfile(uid);
    if (me == null) return <SimilarUser>[];

    final allSnap = await _db.ref('userTaste').get();
    if (!allSnap.exists || allSnap.value is! Map) return <SimilarUser>[];

    final mySet = {...me.cuisines, ...me.tags};
    final results = <SimilarUser>[];

    final map = Map<String, dynamic>.from(allSnap.value as Map);
    map.forEach((otherUid, raw) {
      if (otherUid == uid) return;
      if (raw is! Map) return;
      final m = Map<String, dynamic>.from(raw);
      final p = TasteProfile.fromJson(m);
      final theirSet = {...p.cuisines, ...p.tags};
      final score = _jaccard(mySet, theirSet);
      if (includeZero || score > 0) {
        results.add(SimilarUser(otherUid, score));
      }
    });

    results.sort((b, a) => a.score.compareTo(b.score)); // desc
    if (results.length > limit) {
      return results.sublist(0, limit);
    }
    return results;
  }

  // Useful later to boost lists (e.g., QuickEats) for a user.
  double scoreTagsAgainstProfile(Set<String> itemTags, TasteProfile p) {
    final base = {...p.cuisines, ...p.tags};
    return _jaccard(base, itemTags);
  }

  static double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty && b.isEmpty) return 0.0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    return union == 0 ? 0.0 : inter / union;
  }
}

