import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../firebase_options.dart';
import '../../../core/auth/anon_auth.dart';

class TasteQuizScreen extends StatefulWidget {
  const TasteQuizScreen({super.key});

  @override
  State<TasteQuizScreen> createState() => _TasteQuizScreenState();
}

class _TasteQuizScreenState extends State<TasteQuizScreen> {
  // UI state
  final Set<String> _loves = {'Burgers', 'BBQ'};
  final Set<String> _avoids = {'Too Spicy', 'Expensive'};
  double _spice = 2; // 0–4

  // Infra state
  DatabaseReference? _ref; // points to /userTaste/<uid>
  String? _uid;

  @override
  void initState() {
    super.initState();
    _ensureReady();
  }

  Future<void> _ensureReady() async {
    // Initialize Firebase app if needed
    try {
      Firebase.app();
    } catch (_) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Ensure an anonymous user (needed for secure rules)
    try {
      await AnonAuth.instance.ensureSignedIn();
    } catch (e) {
      _showSnack('Sign-in failed: $e');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('No Firebase user after sign-in.');
      return;
    }
    _uid = user.uid;

    // Build a DB instance with explicit databaseURL (web-safe)
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: DefaultFirebaseOptions.currentPlatform.databaseURL ??
          'https://similar-eats-default-rtdb.firebaseio.com',
    );

    _ref = db.ref('userTaste/$_uid');

    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (_ref == null || _uid == null) {
      _showSnack('Save failed: not initialized yet.');
      return;
    }

    final payload = {
      'loves': _loves.toList(),
      'avoids': _avoids.toList(),
      'spice': _spice.round(),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      await _ref!.set(payload);
      _showSnack('Saved!');
    } catch (e) {
      _showSnack('Save failed: $e');
    }
  }

  void _reset() {
    setState(() {
      _loves
        ..clear()
        ..addAll(['Burgers', 'BBQ']);
      _avoids
        ..clear()
        ..addAll(['Too Spicy', 'Expensive']);
      _spice = 2;
    });
  }

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ready = _ref != null && _uid != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Taste Quiz'),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Reset')),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: ready ? _save : null,
            child: const Text('Save'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text('Taste Quiz', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          // Loves
          const Text('What do you love?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in const [
                'Burgers','Pizza','Tacos','BBQ','Sushi','Ramen','Thai','Indian','Mediterranean','Vegan','Vegetarian','Seafood'
              ])
                FilterChip(
                  selected: _loves.contains(s),
                  label: Text(s),
                  onSelected: (_) => _toggle(_loves, s),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Avoids
          const Text('What should we avoid?', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in const [
                'Too Spicy','Greasy','Crowded','Long Wait','Noisy','Expensive'
              ])
                FilterChip(
                  selected: _avoids.contains(s),
                  label: Text(s),
                  onSelected: (_) => _toggle(_avoids, s),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Spice
          const Text('Spice tolerance', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: _spice,
            min: 0,
            max: 4,
            divisions: 4,
            label: ['Mild','Low','Medium','Hot','Blazing'][_spice.round()],
            onChanged: (v) => setState(() => _spice = v),
          ),

          const SizedBox(height: 8),
          const Text(
            'Tip: these choices steer Quick Eats ranking and future recommendations.',
            style: TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 24),
          if (!ready)
            const Center(child: Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(),
            )),
        ],
      ),
    );
  }
}
