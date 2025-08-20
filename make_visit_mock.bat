import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SimilarEatsMockApp());

class SimilarEatsMockApp extends StatelessWidget {
  const SimilarEatsMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Similar Eats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF25C54),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF4EF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
        ),
        chipTheme: const ChipThemeData(
          side: BorderSide(color: Colors.transparent),
          shape: StadiumBorder(),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const _LoginScreen(),
    );
  }
}

/* ----------------------------- LOGIN ----------------------------- */

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({super.key});
  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _user = TextEditingController(text: 'david');
  final _pass = TextEditingController(text: 'david');
  bool _err = false;
  bool _loading = false;

  Future<void> _doLogin() async {
    setState(() {
      _err = false;
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 300));
    if (_user.text.trim().toLowerCase() == 'david' &&
        _pass.text.trim().toLowerCase() == 'david') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      );
    } else {
      setState(() {
        _err = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 0,
            color: const Color(0xFFFFEAE3),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Similar Eats — Mock Login',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: _user,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _doLogin(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _doLogin(),
                ),
                if (_err) ...[
                  const SizedBox(height: 10),
                  Text('Invalid credentials',
                      style: TextStyle(color: cs.error)),
                ],
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _loading ? null : _doLogin,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.login),
                  label: const Text('Sign in (david/david)'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/* ------------------------------ HOME ------------------------------ */

class _HomeScreen extends StatefulWidget {
  const _HomeScreen({super.key});
  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  late final String _question;

  static const _questions = [
    "What's for dinner tonight?",
    "Where do you want to eat?",
    "What are you craving?",
    "Pick a couple of things you’re into.",
    "What sounds good right now?",
    "What should we hunt down?",
  ];

  @override
  void initState() {
    super.initState();
    final rnd = Random(DateTime.now().millisecondsSinceEpoch);
    _question = _questions[rnd.nextInt(_questions.length)];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Eats',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Avatar + Random question button
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: _avatarColorFrom('David'),
                  child: const Text('D', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF25C54),
                  ),
                  onPressed: () async {
                    final res = await Navigator.of(context).push<List<String>>(
                      MaterialPageRoute(
                        builder: (_) => const CategorySelectScreen(),
                      ),
                    );
                    if (!mounted || res == null) return;
                    // For now, just show what was picked.
                    final snack = SnackBar(
                      content: Text('Picked: ${res.join(", ")}'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snack);
                  },
                  icon: const Icon(Icons.fastfood_rounded),
                  label: Text(_question,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const _SectionTitle('Dishes you want to try'),
          const SizedBox(height: 8),
          _pill('Wings'),
          _pill("Johnny's Wings"),
          const SizedBox(height: 18),

          const _SectionTitle('Suggested matches'),
          const SizedBox(height: 8),
          _suggestionCard(
            color: const Color(0xFFF25C54),
            title: 'Spicy Palace',
            subtitle: 'Thai • 🌶️ spicy • 🍋 lime',
            rating: 4.5,
          ),
          _suggestionCard(
            color: const Color(0xFF41B883),
            title: 'Crispy Corner',
            subtitle: 'Fried Chicken • 🍗 crispy',
            rating: 4.2,
          ),
          _suggestionCard(
            color: const Color(0xFFFFC107),
            title: 'Cheesy Bites',
            subtitle: 'Pizza • 🧀 cheesy',
            rating: 4.8,
          ),
          const SizedBox(height: 12),
          Center(
            child:
                Text('Mock data • offline', style: TextStyle(color: cs.outline)),
          ),
        ],
      ),
    );
  }

  Widget _pill(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            backgroundColor: Colors.white,
            label: Text(text),
          ),
        ),
      );

  Widget _suggestionCard({
    required Color color,
    required String title,
    required String subtitle,
    required double rating,
  }) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFEAE3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber),
            Text(rating.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }
}

/* --------------------- CATEGORY SELECT (MULTI) --------------------- */

class CategorySelectScreen extends StatefulWidget {
  const CategorySelectScreen({super.key});

  @override
  State<CategorySelectScreen> createState() => _CategorySelectScreenState();
}

class _CategorySelectScreenState extends State<CategorySelectScreen> {
  final Set<String> _picked = {};
  final _otherCtl = TextEditingController();

  static const _cats = <_Cat>[
    _Cat('Chicken', Icons.set_meal_rounded),
    _Cat('Pizza', Icons.local_pizza_rounded),
    _Cat('Burgers', Icons.lunch_dining_rounded),
    _Cat('Tacos', Icons.restaurant_rounded),
    _Cat('Noodles', Icons.ramen_dining_rounded),
    _Cat('BBQ', Icons.outdoor_grill_rounded),
    _Cat('Seafood', Icons.set_meal),
    _Cat('Salads', Icons.eco_rounded),
    _Cat('Dessert', Icons.icecream_rounded),
    _Cat('Breakfast', Icons.free_breakfast_rounded),
  ];

  @override
  void dispose() {
    _otherCtl.dispose();
    super.dispose();
  }

  void _toggle(String name) {
    setState(() {
      if (_picked.contains(name)) {
        _picked.remove(name);
      } else {
        _picked.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _picked.isNotEmpty || _otherCtl.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tonight's picks",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          const Text(
            'Choose one or more categories:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),

          // Chips grid (wrap)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _cats.map((c) {
              final selected = _picked.contains(c.name);
              return FilterChip(
                label: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(c.icon, size: 18),
                  const SizedBox(width: 6),
                  Text(c.name),
                ]),
                selected: selected,
                onSelected: (_) => _toggle(c.name),
                showCheckmark: true,
                selectedColor: const Color(0xFFF25C54).withOpacity(.15),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
          const Text('Or write in your craving:',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _otherCtl,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g., “falafel”, “shakes”, “sushi burrito”',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: canContinue
                ? () {
                    final all = <String>[
                      ..._picked,
                      if (_otherCtl.text.trim().isNotEmpty)
                        _otherCtl.text.trim(),
                    ];
                    Navigator.of(context).pop(all);
                  }
                : null,
            icon: const Icon(Icons.check_rounded),
            label: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}

class _Cat {
  final String name;
  final IconData icon;
  const _Cat(this.name, this.icon);
}

/* ---------------------------- HELPERS ---------------------------- */

Color _avatarColorFrom(String text) {
  final h = text.runes.fold<int>(0, (a, b) => a + b);
  const swatches = <MaterialColor>[
    Colors.orange,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.green,
    Colors.brown,
    Colors.deepPurple,
  ];
  return swatches[h % swatches.length].shade200;
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      );
}

