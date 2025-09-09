# Writes/overwrites three files with improved ranking + RC behavior.

$proj = $env:PROJ
if (-not $proj) { $proj = "C:\projects\similar_eats_desktop" }

# 1) quick_eats_repo.dart (ranking + remote config read)
$repoPath = Join-Path $proj "lib\features\quick_eats\repo\quick_eats_repo.dart"
$repoCode = @"
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../shared/remote_config.dart';
import '../models/restaurant.dart';

class QuickEatsRepo {
  QuickEatsRepo({
    FirebaseDatabase? db,
    RemoteConfigService? rc,
  })  : _db = db ?? FirebaseDatabase.instance,
        _rc = rc ?? RemoteConfigService.instance;

  final FirebaseDatabase _db;
  final RemoteConfigService _rc;

  static const _quickTagSet = {
    'fast_service',
    'grab_and_go',
    'drive_thru',
    'counter',
  };

  /// Loads and ranks restaurants for either 'quick' or 'late' mode.
  Future<List<Restaurant>> loadRanked({required bool quickMode}) async {
    // RC defaults + fetch
    await _rc.ensureReady();
    final enabled = _rc.getBool('quick_eats_enabled', fallback: true);
    if (!enabled) return <Restaurant>[];

    final minQuickTags = _rc.getInt('quick_eats_min_quick_tags', fallback: 0);
    // late cutoff reserved for future open-hours logic
    final _ = _rc.getInt('quick_eats_late_cutoff_hour', fallback: 23);

    final snap = await _db.ref('restaurants').get();
    if (!snap.exists || snap.value is! Map) return <Restaurant>[];

    final map = Map<String, dynamic>.from(snap.value as Map);
    final items = <Restaurant>[];
    map.forEach((id, v) {
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
        final quickTags = r.serviceTags.where((t) => _quickTagSet.contains(t)).length;
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

      // tie-breakers
      if (quickMode) {
        final atags = a.serviceTags.where((t) => _quickTagSet.contains(t)).length;
        final btags = b.serviceTags.where((t) => _quickTagSet.contains(t)).length;
        if (btags != atags) return btags.compareTo(atags);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }

  double _score(Restaurant r, bool quickMode) {
    if (quickMode) {
      final quickTags = r.serviceTags.where((t) => _quickTagSet.contains(t)).length;
      return (r.quickServiceFlag ? 2.0 : 0.0) + quickTags * 0.5;
    } else {
      var s = r.openLateFlag ? 2.0 : 0.0;
      final n = r.name.toLowerCase();
      if (n.contains('late') || n.contains('24/7') || n.contains('night')) s += 0.25;
      return s;
    }
  }
}
"@
Set-Content -Path $repoPath -Value $repoCode -Encoding UTF8

# 2) restaurant_card.dart (badges + tidy layout)
$cardPath = Join-Path $proj "lib\features\quick_eats\widgets\restaurant_card.dart"
$cardCode = @"
import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, required this.showQuickBadge, required this.showLateBadge});

  final Restaurant restaurant;
  final bool showQuickBadge;
  final bool showLateBadge;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    if (showQuickBadge) {
      badges.add(_pill(context, 'Quick'));
    }
    if (showLateBadge) {
      badges.add(_pill(context, 'Late'));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restaurant, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: badges),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext ctx, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(ctx).textTheme.labelMedium),
    );
  }
}
"@
Set-Content -Path $cardPath -Value $cardCode -Encoding UTF8

# 3) quick_eats_screen.dart (calls ranked loader, shows empty state nicely)
$screenPath = Join-Path $proj "lib\features\quick_eats\screens\quick_eats_screen.dart"
$screenCode = @"
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import '../repo/quick_eats_repo.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';

class QuickEatsScreen extends StatefulWidget {
  const QuickEatsScreen({super.key});

  @override
  State<QuickEatsScreen> createState() => _QuickEatsScreenState();
}

class _QuickEatsScreenState extends State<QuickEatsScreen> {
  bool _quickMode = true;
  late final QuickEatsRepo _repo;
  late Future<List<Restaurant>> _future;

  @override
  void initState() {
    super.initState();
    _repo = QuickEatsRepo();
    _future = _load();
  }

  Future<void> _ensureFirebase() async {
    try {
      Firebase.app();
    } catch (_) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  }

  Future<List<Restaurant>> _load() async {
    await _ensureFirebase();
    return _repo.loadRanked(quickMode: _quickMode);
  }

  void _setMode(bool quick) {
    if (quick == _quickMode) return;
    setState(() {
      _quickMode = quick;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Eats'),
        actions: [
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [_quickMode, !_quickMode],
            borderRadius: BorderRadius.circular(24),
            constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
            onPressed: (i) => _setMode(i == 0),
            children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Quick')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Late Night')),],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data ?? const <Restaurant>[];
          if (data.isEmpty) {
            return const Center(child: Text('No matches yet'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (ctx, i) {
              final r = data[i];
              return RestaurantCard(
                restaurant: r,
                showQuickBadge: _quickMode && (r.quickServiceFlag || r.serviceTags.isNotEmpty),
                showLateBadge: !_quickMode && r.openLateFlag,
              );
            },
          );
        },
      ),
    );
  }
}
"@
Set-Content -Path $screenPath -Value $screenCode -Encoding UTF8

Write-Host "Updated:" -ForegroundColor Green
Write-Host " - $repoPath"
Write-Host " - $cardPath"
Write-Host " - $screenPath"
