Write-Host "=== Step 2: Migrate to modular entry (Home + Explore) ==="

# Ensure folders
New-Item -ItemType Directory -Force -Path "lib/features/home" | Out-Null
New-Item -ItemType Directory -Force -Path "lib/features/explore" | Out-Null

# ---- lib/app.dart ----
@'
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
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        ChooseCategoriesScreen.route: (_) => const ChooseCategoriesScreen(),
      },
    );
  }
}
'@ | Set-Content -Encoding UTF8 lib/app.dart

# ---- lib/main_modular.dart ----
@'
import 'package:flutter/material.dart';
import 'app.dart';

void main() => runApp(const SimilarEatsApp());
'@ | Set-Content -Encoding UTF8 lib/main_modular.dart

# ---- lib/features/home/home_screen.dart ----
@'
import 'package:flutter/material.dart';
import '../explore/choose_categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Similar Eats")),
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.pushNamed(context, ChooseCategoriesScreen.route),
          child: const Text("What’s for dinner?"),
        ),
      ),
    );
  }
}
'@ | Set-Content -Encoding UTF8 lib/features/home/home_screen.dart

# ---- lib/features/explore/choose_categories_screen.dart ----
@'
import 'package:flutter/material.dart';

class ChooseCategoriesScreen extends StatelessWidget {
  static const route = "/choose-categories";
  const ChooseCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick one or more categories")),
      body: const Center(child: Text("TODO: categories + map here")),
    );
  }
}
'@ | Set-Content -Encoding UTF8 lib/features/explore/choose_categories_screen.dart

Write-Host "[OK] Modular files generated."
Write-Host "Run: flutter run -d windows -t lib/main_modular.dart"

