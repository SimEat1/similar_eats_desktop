import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:similar_eats_desktop/firebase_options.dart';

import 'package:similar_eats_desktop/bootstrap_providers.dart';
import 'package:similar_eats_desktop/features/home/welcome_screen.dart';

// Core features already in your app
import 'package:similar_eats_desktop/features/dinner/dinner_screen.dart';
import 'package:similar_eats_desktop/features/taste_quiz/screens/taste_quiz_screen.dart';
import 'package:similar_eats_desktop/features/group_match/group_match_screen.dart';
import 'package:similar_eats_desktop/features/explore/explore_map_screen.dart';
import 'package:similar_eats_desktop/features/favorites/presentation/favorites_screen.dart';
import 'package:similar_eats_desktop/features/try_list/presentation/try_list_screen.dart';
import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';
import 'package:similar_eats_desktop/features/buds/screens/taste_buds_screen.dart';
import 'package:similar_eats_desktop/features/receipts/receipt_scan_screen.dart';
import 'package:similar_eats_desktop/features/receipts/receipts_home_screen.dart';

// New innovation screens
import 'package:similar_eats_desktop/features/taste_graph/taste_graph_screen.dart';
import 'package:similar_eats_desktop/features/concierge/tonight_screen.dart';
import 'package:similar_eats_desktop/features/voice/voice_search_screen.dart';
import 'package:similar_eats_desktop/features/menu_reader/menu_reader_screen.dart';
import 'package:similar_eats_desktop/features/profiles/public_profile_screen.dart';
import 'package:similar_eats_desktop/features/challenges/challenges_screen.dart';
import 'package:similar_eats_desktop/features/communities/communities_screen.dart';
import 'package:similar_eats_desktop/features/tags/smart_tag_demo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await _ensureSignedIn();
  await _firestoreSmokeTest();

  runApp(withAppProviders(const MyApp()));
}

Future<void> _ensureSignedIn() async {
  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
  debugPrint('AUTH UID => ${auth.currentUser!.uid}');
}

Future<void> _firestoreSmokeTest() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  debugPrint('SMOKE about to write: debug/$uid/smoke/ping');
  await FirebaseFirestore.instance
      .collection('debug')
      .doc(uid)
      .collection('smoke')
      .doc('ping')
      .set({
    'ts': FieldValue.serverTimestamp(),
    'platform': 'windows',
    'message': 'hello from smoke test',
  }, SetOptions(merge: true));
  debugPrint('FIRESTORE_SMOKE_OK');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Similar Eats (Dev)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        // Core existing
        RecommendationsScreen.route: (_) => const RecommendationsScreen(),
        FavoritesScreen.route: (_) => const FavoritesScreen(),
        TryListScreen.route: (_) => const TryListScreen(),
        DinnerScreen.routeName: (_) => const DinnerScreen(),
        WelcomeScreen.routeName: (_) => const WelcomeScreen(),
        TasteQuizScreen.routeName: (_) => const TasteQuizScreen(),
        GroupMatchScreen.routeName: (_) => const GroupMatchScreen(),
        ExploreMapScreen.routeName: (_) => const ExploreMapScreen(),
        TasteBudsScreen.route: (_) => const TasteBudsScreen(),
        ReceiptScanScreen.route: (_) => const ReceiptScanScreen(),
        ReceiptsHomeScreen.route: (_) => const ReceiptsHomeScreen(),

        // Innovation screens
        TasteGraphScreen.route: (_) => const TasteGraphScreen(),
        TonightConciergeScreen.route: (_) => const TonightConciergeScreen(),
        VoiceSearchScreen.route: (_) => const VoiceSearchScreen(),
        MenuReaderScreen.route: (_) => const MenuReaderScreen(),
        PublicProfileScreen.route: (_) => const PublicProfileScreen(),
        ChallengesScreen.route: (_) => const ChallengesScreen(),
        CommunitiesScreen.route: (_) => const CommunitiesScreen(),
        SmartTagDemoScreen.route: (_) => const SmartTagDemoScreen(),
      },
    );
  }
}


