@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo === Step 2 (fixed): Migrate to modular entry (Home + Explore) ===

REM ----- Ensure folders -----
if not exist "lib\features\home" mkdir "lib\features\home"
if not exist "lib\features\explore" mkdir "lib\features\explore"

REM ===== lib\app.dart =====
powershell -NoLogo -NoProfile -Command ^
"@'
import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';
import 'features/explore/choose_categories_screen.dart';

class SimilarEatsApp extends StatelessWidget {
  const SimilarEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Similar Eats (Modular)',
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
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        ChooseCategoriesScreen.route: (_) => const ChooseCategoriesScreen(),
      },
    );
  }
}
'@ | Set-Content -Encoding UTF8 lib/app.dart"

if errorlevel 1 goto :err

REM ===== lib\main_modular.dart =====
powershell -NoLogo -NoProfile -Command ^
"@'
import 'package:flutter/material.dart';
import 'app.dart';

void main() => runApp(const SimilarEatsApp());
'@ | Set-Content -Encoding UTF8 lib/main_modular.dart"

if errorlevel 1 goto :err

REM ===== lib\features\home\home_screen.dart =====
powershell -NoLogo -NoProfile -Command ^
"@'
import 'dart:math';
import 'package:flutter/material.dart';
import '../explore/choose_categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final greetings = [
      'What sounds good right now?',
      'Where do you want to eat?',
      'What are you craving tonight?',
      'What’s for dinner?',
      'Pick your vibe for today',
    ];
    final msg = greetings[DateTime.now().millisecondsSinceEpoch % greetings.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Eats'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SizedBox(height: 8),
          _HeaderCard(message: msg),
          const SizedBox(height: 16),
          const _SectionTitle('Dishes you want to try'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _DishPill(label: 'Wings'),
              _DishPill(label: 'Johnny\'s Wings'),
              _DishPill(label: 'Truffle Fries'),
              _DishPill(label: 'Miso Ramen'),
            ],
          ),
          const SizedBox(height: 18),
          const _SectionTitle('Suggested matches'),
          const SizedBox(height: 8),
          for (final r in _restaurants) _RestaurantCard(r),
          const SizedBox(height: 24),
          Center(child: Text('Mock data • offline • no sign‑in', style: TextStyle(color: cs.outline))),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String message;
  const _HeaderCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: const Color(0xFFFFEAE3),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.orange.shade200,
              child: const Text('S', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi there!', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, ChooseCategoriesScreen.route),
                    icon: const Icon(Icons.explore_rounded),
                    label: Text(message, style: const TextStyle(fontWeight: FontWeight.w700)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
}

class _DishPill extends StatelessWidget {
  final String label;
  const _DishPill({required this.label});
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class Restaurant {
  final String name;
  final String category;
  final double rating;
  final Color color;
  const Restaurant(this.name, this.category, this.rating, this.color);
}

const _restaurants = <Restaurant>[
  Restaurant('Spicy Palace', 'Thai', 4.5, Color(0xFFF25C54)),
  Restaurant('Crispy Corner', 'Fried Chicken', 4.2, Color(0xFF41B883)),
  Restaurant('Cheesy Bites', 'Pizza', 4.8, Color(0xFFFFC107)),
  Restaurant('Umami House Ramen', 'Ramen', 4.6, Color(0xFF2F6BFF)),
];

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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 84, height: 84, decoration: BoxDecoration(color: r.color, borderRadius: BorderRadius.circular(10))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Text('${r.category} • ', style: TextStyle(color: cs.onSurfaceVariant)),
                    const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                    Text(' ${r.rating.toStringAsFixed(1)}', style: TextStyle(color: cs.onSurfaceVariant)),
                  ]),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 lib/features/home/home_screen.dart"

if errorlevel 1 goto :err

REM ===== lib\features\explore\choose_categories_screen.dart =====
powershell -NoLogo -NoProfile -Command ^
"@'
import 'package:flutter/material.dart';

class ChooseCategoriesScreen extends StatefulWidget {
  static const route = '/choose-categories';
  const ChooseCategoriesScreen({super.key});
  @override
  State<ChooseCategoriesScreen> createState() => _ChooseCategoriesScreenState();
}

class _ChooseCategoriesScreenState extends State<ChooseCategoriesScreen> {
  final Set<String> _selected = {};
  final _cats = const ['Burgers','Pizza','Chicken','Sushi','Tacos','Dessert','Salads','BBQ'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick one or more categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cats.map((c) {
                final isSel = _selected.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: isSel,
                  onSelected: (v) => setState(() => v ? _selected.add(c) : _selected.remove(c)),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: Text(_selected.isEmpty ? 'Skip' : 'See suggestions'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 lib/features/explore/choose_categories_screen.dart"

if errorlevel 1 goto :err

echo [OK] Files generated.

echo.
echo === Build & Run (modular entry) ===
flutter clean 1>nul
flutter pub get
if errorlevel 1 goto :err

flutter run -d windows -t lib/main_modular.dart
goto :eof

:err
echo [X] Something failed. Check messages above.
exit /b 1



