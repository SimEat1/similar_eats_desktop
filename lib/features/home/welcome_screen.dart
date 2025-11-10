import "package:flutter/material.dart";
import 'package:similar_eats_desktop/features/dinner/dinner_screen.dart';
import 'package:similar_eats_desktop/features/explore/explore_map_screen.dart';
import 'package:similar_eats_desktop/features/group_match/group_match_screen.dart';
import 'package:similar_eats_desktop/features/taste_quiz/screens/taste_quiz_screen.dart';
import 'package:similar_eats_desktop/features/buds/screens/taste_buds_screen.dart';
import 'package:similar_eats_desktop/features/receipts/receipt_scan_screen.dart';
import 'package:similar_eats_desktop/features/receipts/receipts_home_screen.dart';
import 'package:similar_eats_desktop/features/taste_profile/screens/diet_allergy_screen.dart';

// New stubs
import 'package:similar_eats_desktop/features/taste_graph/taste_graph_screen.dart';
import 'package:similar_eats_desktop/features/concierge/tonight_screen.dart';
import 'package:similar_eats_desktop/features/voice/voice_search_screen.dart';
import 'package:similar_eats_desktop/features/menu_reader/menu_reader_screen.dart';
import 'package:similar_eats_desktop/features/profiles/public_profile_screen.dart';
import 'package:similar_eats_desktop/features/challenges/challenges_screen.dart';
import 'package:similar_eats_desktop/features/communities/communities_screen.dart';
import 'package:similar_eats_desktop/features/tags/smart_tag_demo_screen.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = "/welcome";
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget bigButton(
        String title, String subtitle, IconData icon, VoidCallback onTap) {
      return Card(
        child: ListTile(
          leading: Icon(icon, size: 28),
          title: Text(title, style: theme.textTheme.titleMedium),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Taste Buds',
        child: const Icon(Icons.group_outlined),
        onPressed: () => Navigator.pushNamed(context, TasteBudsScreen.route),
      ),
      appBar: AppBar(title: const Text("Similar Eats")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("What's for dinner?", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          bigButton(
            "Find spots that match me",
            "Uses your taste profile (cuisines, flavors, diet, allergies)",
            Icons.restaurant,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DinnerScreen()),
            ),
          ),
          const SizedBox(height: 8),

          // Essentials
          Text("Essentials", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          bigButton(
            "Explore map",
            "Browse by map near you",
            Icons.map,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExploreMapScreen()),
            ),
          ),
          bigButton(
            "Group match",
            "Pick a restaurant everyone can enjoy",
            Icons.groups,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GroupMatchScreen()),
            ),
          ),
          bigButton(
            "Taste quiz",
            "Update flavors, cuisines, budget & dietary info",
            Icons.quiz,
            () => Navigator.pushNamed(context, TasteQuizScreen.routeName),
          ),
          bigButton(
            "Diet & allergy prefs",
            "Hard no’s, dietary patterns, allergens",
            Icons.healing_outlined,
            () => Navigator.pushNamed(context, DietAllergyScreen.route),
          ),

          // Receipts
          const SizedBox(height: 8),
          Text("Receipts", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          bigButton(
            "Scan receipt",
            "Paste text, drop image, or use camera (mobile) — auto-parse",
            Icons.document_scanner_outlined,
            () => Navigator.pushNamed(context, ReceiptScanScreen.route),
          ),
          bigButton(
            "Receipts",
            "See saved receipts & items",
            Icons.receipt_long,
            () => Navigator.pushNamed(context, ReceiptsHomeScreen.route),
          ),

          // Labs / Next-gen
          const SizedBox(height: 8),
          Text("Labs", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          bigButton(
            "Tonight (Concierge)",
            "LLM-powered: “What should I eat tonight?”",
            Icons.auto_awesome,
            () => Navigator.pushNamed(context, TonightConciergeScreen.route),
          ),
          bigButton(
            "Visual menu reader",
            "Snap a menu — we highlight dishes you’d love",
            Icons.menu_book_outlined,
            () => Navigator.pushNamed(context, MenuReaderScreen.route),
          ),
          bigButton(
            "Voice search",
            "“Show me spicy noodles under \$20 near me”",
            Icons.keyboard_voice_outlined,
            () => Navigator.pushNamed(context, VoiceSearchScreen.route),
          ),
          bigButton(
            "Taste graph",
            "See your evolving flavor map",
            Icons.graphic_eq,
            () => Navigator.pushNamed(context, TasteGraphScreen.route),
          ),
          bigButton(
            "Public profile",
            "Shareable taste page (opt-in)",
            Icons.person_outline,
            () => Navigator.pushNamed(context, PublicProfileScreen.route),
          ),
          bigButton(
            "Challenges",
            "Try new things — earn badges",
            Icons.military_tech_outlined,
            () => Navigator.pushNamed(context, ChallengesScreen.route),
          ),
          bigButton(
            "Communities",
            "Join local flavor micro-groups",
            Icons.forum_outlined,
            () => Navigator.pushNamed(context, CommunitiesScreen.route),
          ),
          bigButton(
            "Smart tags (demo)",
            "Auto-tag photos: crispy, spicy, saucy…",
            Icons.tag_outlined,
            () => Navigator.pushNamed(context, SmartTagDemoScreen.route),
          ),
        ],
      ),
    );
  }
}
