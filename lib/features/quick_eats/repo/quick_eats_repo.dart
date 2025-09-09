import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../firebase_options.dart';
import '../../../shared/remote_config.dart';
import '../models/restaurant.dart';

/// Repository that loads + ranks Quick/Late restaurants from RTDB,
/// while obeying Remote Config flags.
class QuickEatsRepo {
  QuickEatsRepo({RemoteConfigService? rc})
      : _rc = rc ?? RemoteConfigService.instance;

  final RemoteConfigService _rc;

  static const _quickTagSet = <String>{
    'fast_service',
    'grab_and_go',
    'drive_thru',
    'counter',
  };

  /// Ensure Firebase is initialized and return a Database instance that
  /// explicitly targets our RTDB URL (works on Web/Desktop too).
  Future<FirebaseDatabase> _db() async {
    // init app if needed
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final app = Firebase.app();
    final url = DefaultFirebaseOptions.currentPlatform.databaseURL ??
        'https://similar-eats-default-rtdb.firebaseio.com';
    return FirebaseDatabase.instanceFor(app: app, databaseURL: url);
  }

  /// Loads and ranks restaurants for either Quick or Late mode.
  Future<List<Restaurant>> loadRanked({required bool quickMode}) async {
    // Remote Config first
    await _rc.ensureReady();
    final enabled = _rc.getBool('quick_eats_enabled', fallback: true);
    if (!enabled) {
      // Disabled by RC -> empty list
      return <Restaurant>[];
    }
    final minQuickTags =
        _rc.getInt('quick_eats_min_quick_tags', fallback: 0);
    // kept for future: late cutoff hour
    // final lateCutoff = _rc.getInt('quick_eats_late_cutoff_hour', fallback: 23);

    // RTDB fetch
    final db = await _db();
    final snap = await db.ref('restaurants').get();
    if (!snap.exists || snap.value is! Map) return <Restaurant>[];

    final raw = Map<String, dynamic>.from(snap.value as Map);
    final items = <Restaurant>[];
    raw.forEach((id, v) {
      if (v is Map) {
        final m = Map<String, dynamic>.from(v);
        m['id'] = id;
        items.add(Restaurant.fromJson(m));
      }
    });

    // Filter by mode
    List<Restaurant> filtered;
    if (quickMode) {
      filtered = items.where((r) {
        final quickTags =
            r.serviceTags.where((t) => _quickTagSet.contains(t)).length;
        return (r.quickServiceFlag == true) || quickTags >= minQuickTags;
      }).toList();
    } else {
      filtered = items.where((r) => r.openLateFlag == true).toList();
    }

    // Rank
    filtered.sort((a, b) {
      final as = _score(a, quickMode);
      final bs = _score(b, quickMode);
      if (bs != as) return bs.compareTo(as);

      if (quickMode) {
        final at = a.serviceTags.where((t) => _quickTagSet.contains(t)).length;
        final bt = b.serviceTags.where((t) => _quickTagSet.contains(t)).length;
        if (bt != at) return bt.compareTo(at);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }

  double _score(Restaurant r, bool quickMode) {
    if (quickMode) {
      final quickTags =
          r.serviceTags.where((t) => _quickTagSet.contains(t)).length;
      return (r.quickServiceFlag ? 2.0 : 0.0) + quickTags * 0.5;
    } else {
      var s = r.openLateFlag ? 2.0 : 0.0;
      final n = r.name.toLowerCase();
      if (n.contains('late') || n.contains('24/7') || n.contains('night')) {
        s += 0.25;
      }
      return s;
    }
  }
}

