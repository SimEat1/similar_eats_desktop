import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../shared/remote_config.dart';
import '../../../firebase_options.dart';
import '../../../core/auth/anon_auth.dart';
import '../repo/quick_eats_repo.dart';
import '../models/restaurant.dart';
import '../widgets/restaurant_card.dart';
import '../../onboarding/screens/taste_quiz_screen.dart';
import '../../try_list/screens/try_list_screen.dart';

// 🔥 Import taste profile logic for smoke test
import '../../taste_profiles/taste_profile_logic.dart';

class QuickEatsScreen extends StatefulWidget {
  const QuickEatsScreen({super.key});

  @override
  State<QuickEatsScreen> createState() => _QuickEatsScreenState();
}

class _QuickEatsScreenState extends State<QuickEatsScreen> {
  int _lastCount = 0;
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
    try {
      await AnonAuth.instance.ensureSignedIn();
    } catch (_) {/* ignore */}
  }

  Future<List<Restaurant>> _load() async {
    await _ensureFirebase();
    final list = await _repo.loadRanked(quickMode: _quickMode);
    _lastCount = list.length;
    return list;
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    try {
      await _future;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: $e')),
        );
      }
    }
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
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'try') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TryListScreen()),
                );
              } else if (v == 'quiz') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TasteQuizScreen()),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'try', child: Text('Open Try List')),
              PopupMenuItem(value: 'quiz', child: Text('Open Taste Quiz')),
            ],
          ),
          const SizedBox(width: 8),
          ToggleButtons(
            isSelected: [_quickMode, !_quickMode],
            borderRadius: BorderRadius.circular(24),
            constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
            onPressed: (i) => _setMode(i == 0),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Quick')),
              Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Late Night')),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Restaurant>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: const [
                SizedBox(height: 120),
                Center(child: Text('Error loading'))
              ]);
            }
            final data = snap.data ?? const <Restaurant>[];
            if (data.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                Center(child: Text('No matches yet'))
              ]);
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
      ),
      floatingActionButton: QuickEatsDebugFab(quickMode: _quickMode, count: _lastCount),
    );
  }
}

class QuickEatsDebugFab extends StatelessWidget {
  const QuickEatsDebugFab({super.key, required this.quickMode, required this.count});
  final bool quickMode;
  final int count;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final rc = RemoteConfigService.instance;
        await rc.ensureReady();

        // 🔥 Run taste debug smoke test
        try {
          print(">>> Running taste debug smoke test...");
          await debugTaste();
        } catch (e, st) {
          print(">>> debugTaste failed: $e\n$st");
        }

        final enabled = rc.getBool('quick_eats_enabled', fallback: true);
        final minTags = rc.getInt('quick_eats_min_quick_tags', fallback: 0);
        final cut = rc.getInt('quick_eats_late_cutoff_hour', fallback: 23);

        showModalBottomSheet(
          context: context,
          builder: (_) => Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle.merge(
              style: Theme.of(context).textTheme.bodyMedium!,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mode: ' + (quickMode ? 'Quick' : 'Late Night')),
                  Text('Count: $count'),
                  const SizedBox(height: 8),
                  Text('RC quick_eats_enabled: $enabled'),
                  Text('RC quick_eats_min_quick_tags: $minTags'),
                  Text('RC quick_eats_late_cutoff_hour: $cut'),
                  const SizedBox(height: 8),
                  Text('User: ' + (FirebaseAuth.instance.currentUser?.uid ?? 'null')),
                ],
              ),
            ),
          ),
        );
      },
      label: const Text('Debug'),
      icon: const Icon(Icons.bug_report),
    );
  }
}



