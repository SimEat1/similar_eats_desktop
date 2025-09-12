import 'package:flutter/material.dart';
import '../quick_eats/screens/quick_eats_screen.dart';
import '../try_list/screens/try_list_screen.dart';
import '../onboarding/screens/taste_quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    QuickEatsScreen(),
    TryListScreen(),
    TasteQuizScreen(),
  ];

  final _titles = const [
    'Quick Eats',
    'Try List',
    'Taste Quiz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.fastfood_outlined), selectedIcon: Icon(Icons.fastfood), label: 'Quick'),
          NavigationDestination(icon: Icon(Icons.bookmark_add_outlined), selectedIcon: Icon(Icons.bookmark_add), label: 'Try'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz), label: 'Quiz'),
        ],
      ),
    );
  }
}
