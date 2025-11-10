// lib/main_modular.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Screens we split out earlier
import 'package:similar_eats_desktop/features/heatmap/heatmap_screen.dart';

void main() => runApp(const SimilarEatsApp());

class SimilarEatsApp extends StatelessWidget {
  const SimilarEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFF25C54),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF4EF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: false,
        elevation: 0,
      ),
      chipTheme: const ChipThemeData(
        side: BorderSide(color: Colors.transparent),
        shape: StadiumBorder(),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
    );

    return MaterialApp(
      title: 'Similar Eats',
      debugShowCheckedModeBanner: false,
      theme: base,
      home: const _RootNav(),
    );
  }
}

/// ========================= ROOT NAV =========================

class _RootNav extends StatefulWidget {
  const _RootNav();
  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  /// Global “what sounds good” selection, shared between Home and Heatmap.
  final ValueNotifier<Set<String>> selectedCategories = ValueNotifier({});

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onAskDinner: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) =>
                ChooseCategoriesScreen(selection: selectedCategories),
          ));
        },
        selectedCategories: selectedCategories,
      ),
      const _CompareScreen(),
      // NOTE: pass the notifier with the new constructor name: `selection:`
      HeatmapScreen(selection: selectedCategories),
      const _PremiumScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.tune_rounded), label: 'Compare'),
          NavigationDestination(
              icon: Icon(Icons.local_fire_department_rounded),
              label: 'Heatmap'),
          NavigationDestination(
              icon: Icon(Icons.workspace_premium_rounded), label: 'Premium'),
        ],
      ),
    );
  }
}

/// ========================= DATA =========================

class Restaurant {
  final String name;
  final String category;
  final double rating;
  final List<String> tags;
  final Color color;

  const Restaurant({
    required this.name,
    required this.category,
    required this.rating,
    required this.tags,
    required this.color,
  });
}

const _restaurants = <Restaurant>[
  Restaurant(
    name: 'Spicy Palace',
    category: 'Thai',
    rating: 4.5,
    tags: ['🌶️ spicy', '🍗 crispy', '🌿 cilantro', '🍋 lime'],
    color: Color(0xFFF25C54),
  ),
  Restaurant(
    name: 'Crispy Corner',
    category: 'Fried Chicken',
    rating: 4.2,
    tags: ['🧀 cheesy', '🍗 crispy'],
    color: Color(0xFF41B883),
  ),
  Restaurant(
    name: 'Cheesy Bites',
    category: 'Pizza',
    rating: 4.8,
    tags: ['🧀 cheesy', '🍗 crispy', '🍕 pizza'],
    color: Color(0xFFFFC107),
  ),
  Restaurant(
    name: 'Umami House Ramen',
    category: 'Ramen',
    rating: 4.6,
    tags: ['🍜 umami', '🍜 noodles', '🥩 pork', '🥚 egg'],
    color: Color(0xFF2F6BFF),
  ),
];

class SimilarUser {
  final String name;
  final int match; // %
  const SimilarUser(this.name, this.match);
}

const _similarUsers = <SimilarUser>[
  SimilarUser('Alice', 92),
  SimilarUser('Bob', 87),
  SimilarUser('Charlie', 85),
];

/// Common category list for the chooser + heatmap coloring
const _allCategories = <String, String>{
  'chicken': '🍗',
  'pizza': '🍕',
  'burgers': '🍔',
  'bbq': '🍖',
  'tacos': '🌮',
  'salad': '🥗',
  'sushi': '🍣',
  'dessert': '🍰',
};

/// ========================= HOME =========================

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onAskDinner,
    required this.selectedCategories,
  });

  final VoidCallback onAskDinner;
  final ValueListenable<Set<String>> selectedCategories;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Similar Eats',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _HeroCard(onAskDinner: onAskDinner),
          const SizedBox(height: 16),
          const _SectionTitle('Dishes you want to try'),
          const SizedBox(height: 8),
          _SelectedChips(listenable: selectedCategories),
          const SizedBox(height: 18),
          const _SectionTitle('Recommended Restaurants'),
          const SizedBox(height: 8),
          for (final r in _restaurants) _RestaurantCard(r),
          const SizedBox(height: 24),
          const _SectionTitle('Users with Similar Taste'),
          const SizedBox(height: 8),
          for (final u in _similarUsers) _UserTile(u),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Mock data • offline • no sign‑in',
              style: TextStyle(color: cs.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onAskDinner});
  final VoidCallback onAskDinner;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEAE3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: cs.secondaryContainer,
            child: const Text('D',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28)),
          ),
          const SizedBox(height: 14),
          // Clickable prompt
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAskDinner,
              icon:
                  const Icon(Icons.chat_bubble_rounded, color: Colors.black87),
              label: Text(
                _promptText(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _promptText() {
    const options = [
      "What's for dinner tonight?",
      "What sounds good right now?",
      "Where do you want to eat?",
    ];
    final i = DateTime.now().millisecondsSinceEpoch % options.length;
    return options[i];
  }
}

class _SelectedChips extends StatelessWidget {
  const _SelectedChips({required this.listenable});
  final ValueListenable<Set<String>> listenable;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: listenable,
      builder: (context, set, _) {
        if (set.isEmpty) {
          return const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _GhostPill(width: 110),
              _GhostPill(width: 140),
              _GhostPill(width: 120),
            ],
          );
        }
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: set.map((key) {
            final emoji = _allCategories[key] ?? '🍽️';
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                // ✅ Border.all instead of Border(side: …)
                border: Border.all(
                    color: cs.outlineVariant.withOpacity(.4), width: 1),
              ),
              child: Text('$emoji  ${_titleCase(key)}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            );
          }).toList(),
        );
      },
    );
  }
}

class _GhostPill extends StatelessWidget {
  const _GhostPill({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant r;
  const _RestaurantCard(this.r);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: const Color(0xFFFFEAE3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored lead block (logo placeholder)
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: r.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 16),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('${r.category} • ',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                        const Icon(Icons.star_rounded,
                            size: 18, color: Colors.amber),
                        Text(' ${r.rating.toStringAsFixed(1)}',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: r.tags
                          .map(
                            (t) => Chip(
                              label: Text(t),
                              backgroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final SimilarUser u;
  const _UserTile(this.u);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: const Color(0xFFFFEAE3),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: _avatarColorFrom(u.name),
          child: Text(
            u.name.characters.first,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        title:
            Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Taste match: ${u.match}%',
            style: TextStyle(color: cs.onSurfaceVariant)),
        trailing: const Icon(Icons.person_add_alt_1_rounded),
        onTap: () {},
      ),
    );
  }
}

/// Deterministic avatar color from text.
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

/// ========================= CHOOSE CATEGORIES =========================

class ChooseCategoriesScreen extends StatefulWidget {
  const ChooseCategoriesScreen({super.key, required this.selection});
  final ValueNotifier<Set<String>> selection;

  @override
  State<ChooseCategoriesScreen> createState() => _ChooseCategoriesScreenState();
}

class _ChooseCategoriesScreenState extends State<ChooseCategoriesScreen> {
  late Set<String> working;

  @override
  void initState() {
    super.initState();
    working = {...widget.selection.value};
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "What's for dinner?",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick one or more categories',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _allCategories.entries.map((e) {
                final key = e.key;
                final emoji = e.value;
                final selected = working.contains(key);
                return FilterChip(
                  selected: selected,
                  label: Text('$emoji ${_titleCase(key)}'),
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        working.remove(key);
                      } else {
                        working.add(key);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: working.isEmpty
                    ? null
                    : () {
                        widget.selection.value = {...working};
                        Navigator.pop(context);
                      },
                child: const Text('Find options',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ========================= COMPARE (placeholder) =========================

class _CompareScreen extends StatelessWidget {
  const _CompareScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Menu Items',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Center(
        child: Text('Compare mock coming soon',
            style: TextStyle(color: cs.outline)),
      ),
    );
  }
}

/// ========================= PREMIUM (placeholder) =========================

class _PremiumScreen extends StatelessWidget {
  const _PremiumScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Similar Eats Premium',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Center(
        child: Text('Marketing mock • no billing',
            style: TextStyle(color: cs.outline)),
      ),
    );
  }
}

/// ========================= HELPERS =========================

String _titleCase(String key) {
  if (key.isEmpty) return key;
  return key[0].toUpperCase() + key.substring(1);
}

/// (kept from earlier heatmap painter logic)
class SimpleGlowPainter extends CustomPainter {
  SimpleGlowPainter(this.seedColor);
  final Color seedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);
    final centers = List.generate(
      9,
      (_) =>
          Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
    );

    // draw glows
    for (final c in centers) {
      for (var i = 4; i >= 1; i--) {
        final paint = Paint()
          ..color = seedColor.withOpacity(0.08 * i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
        canvas.drawCircle(c, 60.0 * i, paint);
      }
      final core = Paint()..color = seedColor;
      canvas.drawCircle(c, 10, core);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
