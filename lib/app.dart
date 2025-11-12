import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/widgets/offline_banner.dart';
import 'package:similar_eats_desktop/features/home/home_screen.dart';
import 'package:similar_eats_desktop/features/explore/choose_categories_screen.dart';

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
        ),
        chipTheme: const ChipThemeData(
          shape: StadiumBorder(),
          side: BorderSide(color: Colors.transparent),
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      // Overlay OfflineBanner on top of every screen
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OfflineBanner(),
            ),
          ],
        );
      },
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        ChooseCategoriesScreen.route: (_) => const ChooseCategoriesScreen(),
      },
    );
  }
}

