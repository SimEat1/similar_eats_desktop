import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_database/firebase_database.dart";

import 'package:similar_eats_desktop/firebase_options.dart';
import 'package:similar_eats_desktop/core/auth/anon_auth.dart';

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';
class TasteQuizScreen extends StatefulWidget {
  const TasteQuizScreen({super.key});
  @override
  State<TasteQuizScreen> createState() => _TasteQuizScreenState();
}

class _TasteQuizScreenState extends State<TasteQuizScreen> {
  final Set<String> _likes = {};
  final Set<String> _avoids = {};
  double _spice = 50;
  bool _saving = false;

  // Simple catalogs – tweak freely
  static const _cuisines = <String>[
    "bbq",
    "burgers",
    "pizza",
    "tacos",
    "salads",
    "japanese",
    "chinese",
    "thai",
    "indian",
    "mediterranean",
  ];

  static const _avoidTags = <String>[
    "spicy",
    "greasy",
    "dairy",
    "nuts",
    "gluten",
  ];

  Future<void> _ensureFirebase() async {
    try {
      Firebase.app();
    } catch (_) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await AnonAuth.instance.ensureSignedIn();
  }

  FirebaseDatabase _db() => FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL ??
            "https://similar-eats-default-rtdb.firebaseio.com",
      );

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _ensureFirebase();
      final uid = PlatformHelper.getCurrentUid(firebaseUid: FirebaseAuth.instance.currentUser?.uid);
      if (uid == null) throw "No user";

      final payload = {
        "likedCuisines": _likes.toList(),
        "avoidTags": _avoids.toList(),
        "spiceTolerance": _spice.round(),
      };

      await _db().ref("userTaste/$uid").set(payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved preferences ✓")),
      );
      Navigator.of(context).pop(); // back to previous screen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Taste Quiz")),
      body: AbsorbPointer(
        absorbing: _saving,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text("What do you like?", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cuisines.map((c) {
                final sel = _likes.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      v ? _likes.add(c) : _likes.remove(c);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text("Anything to avoid?", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _avoidTags.map((t) {
                final sel = _avoids.contains(t);
                return FilterChip(
                  label: Text(t),
                  selected: sel,
                  onSelected: (v) {
                    setState(() {
                      v ? _avoids.add(t) : _avoids.remove(t);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text("Spice tolerance", style: theme.textTheme.titleMedium),
            Row(
              children: [
                const Text("Mild"),
                Expanded(
                  child: Slider(
                    value: _spice,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: _spice.round().toString(),
                    onChanged: (v) => setState(() => _spice = v),
                  ),
                ),
                const Text("Hot"),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(_saving ? "Saving..." : "Save & Apply"),
            ),
          ],
        ),
      ),
    );
  }
}


