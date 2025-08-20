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
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        chipTheme: const ChipThemeData(
          side: BorderSide(color: Colors.transparent),
          shape: StadiumBorder(),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          backgroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// ------------------------------------------------------------
/// Simple models & sample data
/// ------------------------------------------------------------

class Restaurant {
  final String name;
  final String cuisine;
  final double rating;
  final Color color;
  final List<String> tags;

  const Restaurant({
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.color,
    this.tags = const [],
  });
}

const _restaurants = <Restaurant>[
  Restaurant(
    name: 'Spicy Palace',
    cuisine: 'Thai',
    rating: 4.5,
    color: Color(0xFFF25C54),
    tags: ['🌶️ spicy', '🍋 lime', '🌿 cilantro'],
  ),
  Restaurant(
    name: 'Crispy Corner',
    cuisine: 'Fried Chicken',
    rating: 4.2,
    color: Color(0xFF2FB879),
    tags: ['🧀 cheesy', '🍗 crispy'],
  ),
  Restaurant(
    name: 'Cheesy Bites',
    cuisine: 'Pizza',
    rating: 4.8,
    color: Color(0xFFFFC107),
    tags: ['🧀 cheesy', '🍕 pizza'],
  ),
  Restaurant(
    name: 'Umami House Ramen',
    cuisine: 'Ramen',
    rating: 4.6,
    color: Color(0xFF2F6BFF),
    tags: ['🍜 noodles', '🥚 egg'],
  ),
];

/// ------------------------------------------------------------
/// Home
/// ------------------------------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Randomized prompt each launch
  late final String _prompt = _randomPrompt();
  // Example “dishes you want to try”
  final List<String> _toTry = ["🍗 Wings", "🍗 Johnny's Wings"];
  // Categories selected on the craving screen
  List<String> _selectedCravings = const [];

  String _randomPrompt() {
    const options = [
      "What’s for dinner tonight?",
      "Where do you want to eat?",
      "What are you craving?",
      "What sounds good right now?",
      "Pick something delicious!",
      "What should we try today?",
    ];
    final r = Random();
    return options[r.nextInt(options.length)];
  }

  Future<void> _openCravings() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => CategorySelectionScreen(
          initiallySelected: _selectedCravings,
        ),
      ),
    );
    if (result != null) {
      setState(() => _selectedCravings = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Similar Eats')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Avatar
          const SizedBox(height: 8),
          Center(
            child: CircleAvatar(
              radius: 56,
              backgroundColor: Colors.brown.shade200,
              child: const Text(
                'D',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Clickable prompt
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openCravings,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🍽️ ',
                        style: TextStyle(fontSize: 20, height: 1.1)),
                    Text(
                      _prompt,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE45748),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Dishes to try
          const _SectionTitle('Dishes you want to try'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _toTry.map((t) => Chip(label: Text(t))).toList(),
          ),

          // If user picked cravings, show them as chips
          if (_selectedCravings.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _SectionTitle('Your cravings'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _selectedCravings.map((t) => Chip(label: Text(t))).toList(),
            ),
          ],

          const SizedBox(height: 18),
          const _SectionTitle('Suggested matches'),
          const SizedBox(height: 8),
          for (final r in _restaurants) _RestaurantTile(r),

          const SizedBox(height: 22),
          Center(
            child: Text(
              'Mock data · offline',
              style: TextStyle(color: cs.outline),
            ),
          ),
        ],
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
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

class _RestaurantTile extends StatelessWidget {
  final Restaurant r;
  const _RestaurantTile(this.r);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFEAE3),
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: r.color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        title: Text(
          r.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use “·” so we don’t hit weird bullet encodings
              Text("${r.cuisine} · ⭐ ${r.rating.toStringAsFixed(1)}"),
              const SizedBox(height: 6),
              if (r.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: r.tags.map((t) => Chip(label: Text(t))).toList(),
                ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {},
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Category selection (multi‑select + write‑in)
/// ------------------------------------------------------------

class CategorySelectionScreen extends StatefulWidget {
  final List<String> initiallySelected;
  const CategorySelectionScreen({super.key, this.initiallySelected = const []});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<_Cat> _cats = const [
    _Cat('🍗', 'Chicken'),
    _Cat('🍔', 'Burgers'),
    _Cat('🍕', 'Pizza'),
    _Cat('🥗', 'Salad'),
    _Cat('🍣', 'Sushi'),
    _Cat('🌮', 'Tacos'),
    _Cat('🍜', 'Ramen'),
    _Cat('🍝', 'Pasta'),
    _Cat('🍰', 'Dessert'),
    _Cat('☕', 'Cafe'),
  ];

  late final Set<String> _selected =
      widget.initiallySelected.toSet(); // keeps state on return
  final TextEditingController _writeIn = TextEditingController();

  void _toggle(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
    });
  }

  void _addCustom() {
    final text = _writeIn.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _selected.add(text);
      _writeIn.clear();
    });
  }

  void _finish() {
    Navigator.pop(context, _selected.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Pick cravings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Pick one or more:',
            style: TextStyle(
              color: cs.onSurface.withOpacity(.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Grid of categories
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final cross = w > 720
                  ? 5
                  : w > 520
                      ? 4
                      : 3;
              return GridView.count(
                crossAxisCount: cross,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _cats.map((c) {
                  final label = "${c.emoji} ${c.label}";
                  final on = _selected.contains(label);
                  return _CategoryCard(
                    emoji: c.emoji,
                    label: c.label,
                    selected: on,
                    onTap: () => _toggle(label),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Write‑in option
          const Text(
            'Can’t find it? Write it in:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _writeIn,
                  decoration: InputDecoration(
                    hintText: 'e.g., Ethiopian, BBQ, Bubble tea…',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _addCustom(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _addCustom,
                child: const Text('Add'),
              ),
            ],
          ),

          if (_selected.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _selected.map((s) => Chip(label: Text(s))).toList(),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _finish,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cat {
  final String emoji;
  final String label;
  const _Cat(this.emoji, this.label);
}

class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFFDE4E1) : Colors.white;
    final border = selected ? const Color(0xFFF25C54) : const Color(0xFFE6E2DF);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFFE45748) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
