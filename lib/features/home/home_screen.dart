import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_state.dart';

/// Home screen (avatar + prompt + dishes + matches)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Eats'),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _HeroCard(
            onPromptTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _ChooseCategoriesScreen()),
              );
            },
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Recommended Restaurants'),
          const SizedBox(height: 8),

          // Listen for selection and filter restaurants
          ValueListenableBuilder<Set<String>>(
            valueListenable: AppState.instance.selectedCategories,
            builder: (context, selected, _) {
              final filtered = _filterRestaurants(selected);
              if (filtered.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    selected.isEmpty
                        ? 'Pick some categories to personalize suggestions.'
                        : 'No exact matches. Try a different combo.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: [for (final r in filtered) _RestaurantCard(r)],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.tune_rounded), label: 'Compare'),
          NavigationDestination(icon: Icon(Icons.local_fire_department_rounded), label: 'Heatmap'),
          NavigationDestination(icon: Icon(Icons.workspace_premium_rounded), label: 'Premium'),
        ],
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        backgroundColor: const Color(0xFFFFE9E1),
        indicatorColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}

/// Top card: avatar + rotating “What’s for dinner?” + “Dishes you want to try”
class _HeroCard extends StatefulWidget {
  const _HeroCard({required this.onPromptTap});
  final VoidCallback onPromptTap;

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  late String _prompt;
  static const _prompts = [
    "What's for dinner tonight?",
    "What sounds good right now?",
    "Where do you want to eat?",
    "Craving anything specific?",
    "What should we try today?",
  ];

  @override
  void initState() {
    super.initState();
    _prompt = _prompts[DateTime.now().day % _prompts.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFE9E1),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFFC9B7B0),
                child: const Text('D',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6E3E37),
                    )),
              ),
            ),
            const SizedBox(height: 14),

            // Prompt button
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onPromptTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_bubble_rounded,
                        color: Color(0xFFF25C54)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _prompt,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),
            const _SectionTitle('Dishes you want to try'),
            const SizedBox(height: 10),

            // Show selected categories as chips
            ValueListenableBuilder<Set<String>>(
              valueListenable: AppState.instance.selectedCategories,
              builder: (context, selected, _) {
                if (selected.isEmpty) {
                  return const Text('Pick some categories to get started.',
                      style: TextStyle(color: Colors.black54));
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: selected
                      .map((d) => Chip(
                            label: Text(d),
                            backgroundColor: Colors.white,
                            side: BorderSide.none,
                            shape: const StadiumBorder(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

/// ---------------------- Restaurants (mock) ----------------------

class _Restaurant {
  final String name;
  final String category;
  final double rating;
  final List<String> tags;
  final Color color;

  const _Restaurant({
    required this.name,
    required this.category,
    required this.rating,
    required this.tags,
    required this.color,
  });
}

const _allRestaurants = <_Restaurant>[
  _Restaurant(
    name: 'Spicy Palace',
    category: 'Thai',
    rating: 4.5,
    tags: ['spicy', 'crispy', 'cilantro', 'lime'],
    color: Color(0xFFF25C54),
  ),
  _Restaurant(
    name: 'Crispy Corner',
    category: 'Chicken',
    rating: 4.2,
    tags: ['cheesy', 'crispy'],
    color: Color(0xFF41B883),
  ),
  _Restaurant(
    name: 'Cheesy Bites',
    category: 'Pizza',
    rating: 4.8,
    tags: ['cheesy', 'crispy', 'pizza'],
    color: Color(0xFFFFC107),
  ),
  _Restaurant(
    name: 'Umami House Ramen',
    category: 'Noodles',
    rating: 4.6,
    tags: ['umami', 'noodles', 'pork', 'egg'],
    color: Color(0xFF2F6BFF),
  ),
];

List<_Restaurant> _filterRestaurants(Set<String> selected) {
  if (selected.isEmpty) return _allRestaurants;

  bool matches(_Restaurant r) {
    final s = selected.map((e) => e.toLowerCase()).toSet();
    final cat = r.category.toLowerCase();
    if (s.contains(cat)) return true;

    final tagSet = r.tags.map((e) => e.toLowerCase()).toSet();
    return s.intersection(tagSet).isNotEmpty;
  }

  return _allRestaurants.where(matches).toList();
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard(this.r);
  final _Restaurant r;

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
              // Logo color block
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
                                label: Text(_emojiFor(t) + t),
                                backgroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
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

  String _emojiFor(String t) {
    final m = {
      'spicy': '🌶 ',
      'crispy': '🍗 ',
      'cilantro': '🌿 ',
      'lime': '🍋 ',
      'cheesy': '🧀 ',
      'pizza': '🍕 ',
      'umami': '🍜 ',
      'noodles': '🍜 ',
      'pork': '🥩 ',
      'egg': '🥚 ',
    };
    return m[t.toLowerCase()] ?? '';
  }
}

/// ---------------------- Category picker (writes to AppState) ----------------------

class _ChooseCategoriesScreen extends StatefulWidget {
  const _ChooseCategoriesScreen();

  @override
  State<_ChooseCategoriesScreen> createState() =>
      _ChooseCategoriesScreenState();
}

class _ChooseCategoriesScreenState extends State<_ChooseCategoriesScreen> {
  late Set<String> _working;

  static const _cats = [
    ('🍗', 'Chicken'),
    ('🍕', 'Pizza'),
    ('🍔', 'Burgers'),
    ('🍣', 'Sushi'),
    ('🌮', 'Tacos'),
    ('🥗', 'Salads'),
    ('🍜', 'Noodles'),
    ('🍰', 'Dessert'),
  ];

  @override
  void initState() {
    super.initState();
    // Start with current selection so edits are friendly
    _working = {...AppState.instance.selectedCategories.value};
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("What's for dinner?"),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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
              children: [
                for (final (emoji, label) in _cats)
                  _CategoryPill(
                    emoji: emoji,
                    label: label,
                    selected: _working.contains(label),
                    onTap: () {
                      setState(() {
                        _working.contains(label)
                            ? _working.remove(label)
                            : _working.add(label);
                      });
                    },
                  ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  AppState.instance.selectedCategories.value = {..._working};
                  Navigator.pop(context);
                },
                child: const Text('Find options'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? Colors.white : const Color(0xFFFFF4EF);
    final border = selected ? const Color(0xFFF25C54) : Colors.transparent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 1.2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
