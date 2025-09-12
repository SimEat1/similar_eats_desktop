import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/home/home_screen.dart';
import 'features/shared/remote_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Firebase.app();
  } catch (_) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  // Warm up Remote Config so feature flags are ready
  await RemoteConfigService.instance.ensureReady();

  runApp(const SimilarEatsApp());
}

class SimilarEatsApp extends StatelessWidget {
  const SimilarEatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF1BA39C);
    return MaterialApp(
      title: 'Similar Eats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
