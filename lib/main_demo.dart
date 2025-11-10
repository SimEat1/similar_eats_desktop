import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:similar_eats_desktop/firebase_options.dart';

import 'package:similar_eats_desktop/bootstrap_providers.dart';
import 'package:similar_eats_desktop/features/favorites/presentation/favorites_screen.dart';
import 'package:similar_eats_desktop/features/try_list/presentation/try_list_screen.dart';
import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';
// Screens
import 'package:similar_eats_desktop/features/auth/anon_sign_in_screen.dart';
import 'package:similar_eats_desktop/features/quiz/taste_quiz_screen.dart';
import 'package:similar_eats_desktop/features/visits/screens/quick_visit_screen.dart';
import 'package:similar_eats_desktop/features/visits/screens/recent_visits_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(withAppProviders(const DemoApp()));
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(routes: { RecommendationsScreen.route: (_) => const RecommendationsScreen(),  RecommendationsScreen.route: (_) => const RecommendationsScreen(),  FavoritesScreen.route: (_) => const FavoritesScreen(), TryListScreen.route: (_) => const TryListScreen(), }, 
      title: 'Similar Eats Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6B57)),
        useMaterial3: true,
      ),
      home: const DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _DemoTile(
        icon: Icons.login_rounded,
        label: 'Login (Anonymous)',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnonSignInScreen()),
        ),
      ),
      _DemoTile(
        icon: Icons.emoji_food_beverage_rounded,
        label: 'Taste Quiz',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasteQuizScreen()),
        ),
      ),
      _DemoTile(
        icon: Icons.flash_on_rounded,
        label: 'Quick Visit',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuickVisitScreen()),
        ),
      ),
      _DemoTile(
        icon: Icons.update_rounded,
        label: 'Recent Visits',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecentVisitsScreen()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Demo Home')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: GridView.count(
            padding: const EdgeInsets.all(24),
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: tiles,
          ),
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DemoTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48),
              const SizedBox(height: 12),
              Text(label, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}






