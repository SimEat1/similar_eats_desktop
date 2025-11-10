$ErrorActionPreference = 'Stop'
$root   = "lib"
$quiz   = Join-Path $root "features/quiz/taste_quiz_screen.dart"
$main   = Join-Path $root "main_demo.dart"

# --- Make sure folders exist
New-Item -ItemType Directory -Force -Path (Split-Path $quiz) | Out-Null

# --- Taste Quiz screen (writes to /taste_prefs/{uid})
@'
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class TasteQuizScreen extends StatefulWidget {
  static const route = "/taste_quiz";
  const TasteQuizScreen({super.key});
  @override
  State<TasteQuizScreen> createState() => _TasteQuizScreenState();
}

class _TasteQuizScreenState extends State<TasteQuizScreen> {
  // Simple demo sliders (0..5)
  final Map<String, double> _prefs = {
    "sweet": 3,
    "salty": 3,
    "sour":  3,
    "spicy": 3,
    "umami": 3,
  };
  bool _saving = false;

  Future<void> _savePrefs() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user == null) {
        throw Exception("Anonymous sign-in failed");
      }

      final payload = {
        "updated_at": DateTime.now().toIso8601String(),
        "prefs": _prefs.map((k, v) => MapEntry(k, v.toInt())),
      };

      debugPrint("[taste_quiz] about to save for uid=${user.uid}: $payload");

      await FirebaseFirestore.instance
          .collection("taste_prefs")
          .doc(user.uid)
          .set(payload, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Taste preferences saved")),
      );
      debugPrint("[taste_quiz] saved OK");
    } catch (e, st) {
      debugPrint("[taste_quiz] save failed: $e");
      debugPrintStack(label: "[taste_quiz] stack", stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Taste Quiz")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("How much do you like each? (0–5)"),
          const SizedBox(height: 12),
          ..._prefs.keys.map((k) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(k[0].toUpperCase() + k.substring(1)),
                    Slider(
                      value: _prefs[k]!,
                      min: 0, max: 5, divisions: 5,
                      label: _prefs[k]!.round().toString(),
                      onChanged: (v) => setState(() => _prefs[k] = v),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : _savePrefs,
            icon: const Icon(Icons.save),
            label: Text(_saving ? "Saving..." : "Save"),
          ),
        ],
      ),
    );
  }
}
'@ | Set-Content $quiz -Encoding UTF8
Write-Host "Wrote $quiz"

# --- Demo home (adds a button to open the Taste Quiz)
@'
import "package:flutter/material.dart";
import "package:firebase_core/firebase_core.dart";
import "features/quiz/taste_quiz_screen.dart";
// Keep your other demo imports if you have them:
// import "features/visits/screens/quick_visit_screen.dart";
// import "features/visits/screens/recent_visits_screen.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Similar Eats — Demo",
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      routes: {
        "/": (_) => const DemoHome(),
        TasteQuizScreen.route: (_) => const TasteQuizScreen(),
      },
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demo Home")),
      body: Center(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, TasteQuizScreen.route),
              child: const Text("Taste Quiz"),
            ),
            // Keep or add other demo entry points as needed:
            // FilledButton(onPressed: () => Navigator.pushNamed(context, "/quick_visit"), child: const Text("Quick Visit")),
            // FilledButton(onPressed: () => Navigator.pushNamed(context, "/recent_visits"), child: const Text("Recent Visits")),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content $main -Encoding UTF8
Write-Host "Wrote $main"

# --- Format (best effort)
try { dart format $quiz, $main | Out-Host } catch {}
Write-Host "`nNext:"
Write-Host "  flutter run -d windows -t lib/main_demo.dart"
