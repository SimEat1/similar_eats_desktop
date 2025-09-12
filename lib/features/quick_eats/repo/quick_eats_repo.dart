import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../firebase_options.dart';
import '../../shared/remote_config.dart';
import '../models/restaurant.dart';

class QuickEatsRepo {
  QuickEatsRepo({
    FirebaseDatabase? db,
    RemoteConfigService? rc,
  })  : _db = db ?? _dbForOptions(),
        _rc = rc ?? RemoteConfigService.instance;

  final FirebaseDatabase _db;
  final RemoteConfigService _rc;

  /// MAIN: fetch + filter + score + sort
  Future<List<Restaurant>> loadRanked({required bool quickMode}) async {
    // 1) Guard with Remote Config
    await _rc.ensureReady();
    final enabled = _rc.getBool('quick_eats_enabled', fallback: true);
    if (!enabled) return const <Restaurant>[];

    // 2) Fetch restaurants
    final items = await _fetchRestaurants();

    // 3) Fetch taste prefs (non-fatal if missing)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final prefs = (uid == null) ? TastePrefs.empty() : await _fetchTaste(uid);

    // 4) Filter by mode
    final filtered = items.where((r) {
      if (quickMode) {
        // Quick means explicit flag OR quick-ish tags
        final isQuick = r.quickServiceFlag == true ||
            r.serviceTags.any((t) => _quickTagSet.contains(t));
        return isQuick;
      } else {
        // Late night means openLateFlag
        return r.openLateFlag == true;
      }
    }).toList();

    // 5) Score with taste prefs (keep scores in a local map)
    final Map<Restaurant, int> scores = {};
    for (final r in filtered) {
      scores[r] = _scoreRestaurant(r, prefs, quickMode);
    }

    // 6) Sort: score desc, then name
    filtered.sort((a, b) {
      final byScore = (scores[b] ?? 0).compareTo(scores[a] ?? 0);
      if (byScore != 0) return byScore;
      return (a.name).compareTo(b.name);
    });

    return filtered;
  }

  // ---- internals -----------------------------------------------------------

  Future<List<Restaurant>> _fetchRestaurants() async {
    final snap = await _db.ref('restaurants').get();
    final list = <Restaurant>[];
    if (snap.value is Map) {
      final map = (snap.value as Map).cast<String, dynamic>();
      map.forEach((_, v) {
        if (v is Map) {
          list.add(Restaurant.fromJson(Map<String, dynamic>.from(v)));
        }
      });
    }
    return list;
  }

  Future<TastePrefs> _fetchTaste(String uid) async {
    try {
      final snap = await _db.ref('userTaste/').get();
      if (snap.value is Map) {
        final m = (snap.value as Map).cast<String, dynamic>();
        return TastePrefs.fromJson(m);
      }
    } catch (_) {}
    return TastePrefs.empty();
  }

  static const Set<String> _quickTagSet = {
    'drive_thru',
    'grab_and_go',
    'counter',
    'fast_service',
  };

  /// Simple linear score you can tweak freely.
  int _scoreRestaurant(Restaurant r, TastePrefs prefs, bool quickMode) {
    // Likes: +2 per matching tag
    final likeHits =
        r.serviceTags.where((t) => prefs.likes.contains(t)).length;
    final likeScore = likeHits * 2;

    // Avoids: −3 per matching tag
    final avoidHits =
        r.serviceTags.where((t) => prefs.avoids.contains(t)).length;
    final avoidScore = avoidHits * -3;

    // Mode bonus
    final modeBonus = quickMode
        ? (r.quickServiceFlag == true ? 2 : 0)
        : (r.openLateFlag == true ? 2 : 0);

    // Quick-ish bonus (helps sort ties in Quick)
    final quickishBonus =
        r.serviceTags.any((t) => _quickTagSet.contains(t)) ? 1 : 0;

    // (Optional) spice could be used later if we add a restaurant “spiceLevel” tag
    // final spiceAdj = _spiceAdjust(r, prefs.spiceTolerance);

    return likeScore + avoidScore + modeBonus + quickishBonus;
  }

  // If you later add per-restaurant spice tags, you can use this:
  // int _spiceAdjust(Restaurant r, int tolerance01to100) { ... }

  // -- Firebase DB instance with proper URL (web needs explicit URL)
  static FirebaseDatabase _dbForOptions() {
    final url = DefaultFirebaseOptions.currentPlatform.databaseURL ??
        'https://similar-eats-default-rtdb.firebaseio.com';
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: url,
    );
  }
}

/// Minimal taste prefs model for RTDB /userTaste/{uid}
class TastePrefs {
  TastePrefs({
    required this.likes,
    required this.avoids,
    required this.spiceTolerance,
  });

  final Set<String> likes;
  final Set<String> avoids;
  final int spiceTolerance; // 0..100

  factory TastePrefs.empty() =>
      TastePrefs(likes: const {}, avoids: const {}, spiceTolerance: 50);

  factory TastePrefs.fromJson(Map<String, dynamic> json) {
    final likes = <String>{
      ...(json['likedCuisines'] is List
          ? List.from(json['likedCuisines']).whereType<String>()
          : const Iterable<String>.empty())
    };
    final avoids = <String>{
      ...(json['avoidTags'] is List
          ? List.from(json['avoidTags']).whereType<String>()
          : const Iterable<String>.empty())
    };
    final spice = (json['spiceTolerance'] is num)
        ? (json['spiceTolerance'] as num).toInt()
        : 50;
    return TastePrefs(likes: likes, avoids: avoids, spiceTolerance: spice);
  }
}
