// lib/main.dart
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const SimilarEatsApp());

class SimilarEatsApp extends StatelessWidget {
  const SimilarEatsApp({super.key});

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
          centerTitle: false,
          elevation: 0,
        ),
        chipTheme: const ChipThemeData(
          side: BorderSide(color: Colors.transparent),
          shape: StadiumBorder(),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      home: const _RootNav(),
    );
  }
}

/* =============================== ROOT NAV =============================== */

class _RootNav extends StatefulWidget {
  const _RootNav({super.key});
  @override
  State<_RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<_RootNav> {
  int _index = 0;

  // We keep Home as a single instance to preserve its state (chips, etc.)
  final _home = const HomeScreen();

  List<Widget> get _pages => [
        _home,
        const CompareScreen(),
        const HeatmapScreen(),
        const PremiumScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Compare'),
          NavigationDestination(
              icon: Icon(Icons.local_fire_department_rounded), label: 'Heatmap'),
          NavigationDestination(
              icon: Icon(Icons.workspace_premium_rounded), label: 'Premium'),
        ],
      ),
    );
  }
}

/* =============================== DATA =============================== */

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
    tags: ['🧀 cheesy', '🍕 pizza'],
    color: Color(0xFFFFC107),
  ),
  Restaurant(
    name: 'Umami House Ramen',
    category: 'Ramen',
    rating: 4.6,
    tags: ['🍜 umami', '🥩 pork', '🥚 egg'],
    color: Color(0xFF2F6BFF),
  ),
];

/* =============================== HOME =============================== */

/// We store the last dinner choice here so the chips can show it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DinnerChoice? _lastChoice;

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
          _HomeHeader(
            lastChoice: _lastChoice,
            onTapPrompt: () async {
              final result = await Navigator.of(context).push<DinnerChoice>(
                MaterialPageRoute(builder: (_) => const DinnerPickerScreen()),
              );
              if (!mounted) return;
              if (result != null) {
                setState(() => _lastChoice = result);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result.summary.isEmpty
                          ? "Choice saved."
                          : "Saved: ${result.summary}",
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Recommended Restaurants'),
          const SizedBox(height: 8),
          for (final r in _restaurants) _RestaurantRow(r),
          const SizedBox(height: 24),
          Center(
            child: Text('Mock data • offline', style: TextStyle(color: cs.outline)),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final DinnerChoice? lastChoice;
  final VoidCallback onTapPrompt;
  const _HomeHeader({required this.lastChoice, required this.onTapPrompt});

  static const _prompts = [
    "What’s for dinner tonight?",
    "Where do you want to eat?",
    "What are you craving?",
    "What sounds good right now?",
    "Pick a vibe for tonight’s meal",
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final prompt = _prompts[Random().nextInt(_prompts.length)];

    // Build the chip list: from last choice, otherwise nice defaults.
    final chips = <String>[];
    if (lastChoice != null) {
      chips.addAll(lastChoice!.categories);
      if ((lastChoice!.custom ?? '').isNotEmpty) chips.add(lastChoice!.custom!);
    } else {
      chips.addAll(const ['Wings', "Johnny's Wings"]);
    }

    return Card(
      elevation: 0,
      color: const Color(0xFFFFEAE3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          children: [
            // Big avatar back in action
            CircleAvatar(
              radius: 48,
              backgroundColor: cs.primary.withOpacity(.15),
              child: Text(
                'D',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clickable prompt row
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTapPrompt,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_rounded, color: Color(0xFFF25C54)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        prompt,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black54),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Dishes you want to try',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in chips) _Pill(t),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

class _RestaurantRow extends StatelessWidget {
  final Restaurant r;
  const _RestaurantRow(this.r);

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
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: r.color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
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
                          .map((t) => Chip(
                                label: Text(t),
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ))
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

/* =============================== DINNER PICKER =============================== */

class DinnerChoice {
  final Set<String> categories;
  final String? custom;
  const DinnerChoice({required this.categories, this.custom});

  String get summary {
    final parts = <String>[];
    if (categories.isNotEmpty) parts.add(categories.join(', '));
    if (custom != null && custom!.trim().isNotEmpty) parts.add(custom!.trim());
    return parts.join(' • ');
  }
}

class DinnerPickerScreen extends StatefulWidget {
  const DinnerPickerScreen({super.key});

  @override
  State<DinnerPickerScreen> createState() => _DinnerPickerScreenState();
}

class _DinnerPickerScreenState extends State<DinnerPickerScreen> {
  final _selected = <String>{};
  final _controller = TextEditingController();

  final _items = const [
    ('🍗', 'Chicken'),
    ('🍕', 'Pizza'),
    ('🍔', 'Burgers'),
    ('🌯', 'Mexican'),
    ('🍣', 'Sushi'),
    ('🥗', 'Salads'),
    ('🍜', 'Noodles'),
    ('🍰', 'Dessert'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final canSubmit =
        _selected.isNotEmpty || _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: const Text(
          "What's for dinner?",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pick one or more categories',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final (emoji, label) in _items)
                  _CategoryChip(
                    emoji: emoji,
                    label: label,
                    selected: _selected.contains(label),
                    onTap: () => _toggle(label),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // === Map preview section (static, no keys needed) ===
            SizedBox(
              height: 170,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  painter: _MapPreviewPainter(),
                  child: Container(
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Nearby area (mock map)',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "Can't find it? Write it in (e.g., 'Pad See Ew')",
                prefixIcon: const Icon(Icons.edit_rounded),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit
                    ? () {
                        Navigator.of(context).pop(
                          DinnerChoice(
                            categories: _selected,
                            custom: _controller.text.trim().isEmpty
                                ? null
                                : _controller.text.trim(),
                          ),
                        );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor:
                      canSubmit ? const Color(0xFFF25C54) : cs.surfaceVariant,
                ),
                child: Text(
                  'Find options',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: canSubmit ? Colors.white : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFFDE2DE) : Colors.white;
    final border = selected ? const Color(0xFFF25C54) : Colors.transparent;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Simple “map” painter: light grid + a few orange hotspots and pins.
/// This keeps the app offline and key‑free but gives a real sense of place.
class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // background
    final bg = Paint()..color = const Color(0xFFEDE7E3);
    canvas.drawRect(Offset.zero & size, bg);

    // grid
    final grid = Paint()
      ..color = const Color(0xFFD8D2CE)
      ..strokeWidth = 1;
    const gap = 20.0;
    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // hotspots (soft glows)
    final rnd = Random(7);
    final centers = List.generate(
      6,
      (_) => Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
    );
    for (final c in centers) {
      for (var i = 3; i >= 1; i--) {
        final paint = Paint()
          ..color = Colors.orange.withOpacity(0.07 * i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
        canvas.drawCircle(c, 35.0 * i, paint);
      }
      final core = Paint()..color = Colors.orange.shade700;
      canvas.drawCircle(c, 6, core);
    }

    // a couple of “pins”
    final pin = Paint()..color = const Color(0xFFEF5350);
    for (final c in centers.take(3)) {
      canvas.drawCircle(c.translate(8, -8), 4, pin);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/* =============================== STUB PAGES =============================== */

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _StubScaffold(title: 'Compare Menu Items');
  }
}

class HeatmapScreen extends StatelessWidget {
  const HeatmapScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _StubScaffold(title: 'Nightlife Heatmap');
  }
}

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const _StubScaffold(title: 'Similar Eats Premium');
  }
}

class _StubScaffold extends StatelessWidget {
  final String title;
  const _StubScaffold({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
      ),
      body: Center(
        child: Text('Mock screen', style: TextStyle(color: cs.onSurfaceVariant)),
      ),
    );
  }
}
