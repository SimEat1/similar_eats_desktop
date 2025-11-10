param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Adding mock recommender + Recommendations screen ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

flutter pub add shared_preferences provider | Out-Null

$dirs = @(
  "lib/features/recommendations",
  "lib/features/recommendations/domain",
  "lib/features/recommendations/data",
  "lib/features/recommendations/presentation",
  "test"
)
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }

# domain/restaurant.dart  (non-const constructor so mock data doesn't need const)
@"
class Restaurant {
  final String id;
  final String name;
  final String cuisine;
  final List<double> tasteVector; // [sweet, salty, sour, spicy, umami]
  final List<String> tags;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.tasteVector,
    required this.tags,
  }) : assert(tasteVector.length == 5);
}
"@ | Set-Content -Encoding UTF8 lib/features/recommendations/domain/restaurant.dart

# data/recommender.dart
@"
import '../../taste_quiz/domain/taste_profile.dart';
import '../domain/restaurant.dart';
import 'dart:math';

double _cosine(List<double> a, List<double> b) {
  double dot = 0, na = 0, nb = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  final denom = sqrt(na) * sqrt(nb);
  if (denom == 0) return 0;
  return dot / denom;
}

class ScoredRestaurant {
  final Restaurant restaurant;
  final double score; // 0..1
  const ScoredRestaurant(this.restaurant, this.score);
}

class Recommender {
  List<ScoredRestaurant> recommend({
    required TasteProfile profile,
    required List<Restaurant> candidates,
    int topN = 20,
  }) {
    final user = profile.asVector();
    final scored = candidates
        .map((r) => ScoredRestaurant(r, _cosine(user, r.tasteVector)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    if (topN <= 0 || topN >= scored.length) return scored;
    return scored.sublist(0, topN);
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/recommendations/data/recommender.dart

# data/mock_restaurants.dart  (no consts anywhere)
@"
import '../domain/restaurant.dart';

class MockRestaurants {
  static List<Restaurant> get all => [
    Restaurant(
      id: "r1",
      name: "Bangkok Spice",
      cuisine: "Thai",
      tasteVector: [1.5, 2.0, 1.2, 4.6, 2.2],
      tags: ["thai","curry","basil","spicy","noodles"],
    ),
    Restaurant(
      id: "r2",
      name: "Sweet Cravings Bakery",
      cuisine: "Bakery",
      tasteVector: [4.8, 0.8, 0.5, 0.1, 1.0],
      tags: ["cakes","cookies","pastry","sweet"],
    ),
    Restaurant(
      id: "r3",
      name: "Umami House Ramen",
      cuisine: "Japanese",
      tasteVector: [1.2, 2.4, 0.8, 1.2, 4.6],
      tags: ["ramen","broth","umami","pork","noodles"],
    ),
    Restaurant(
      id: "r4",
      name: "La Taquería El Fuego",
      cuisine: "Mexican",
      tasteVector: [1.6, 2.2, 1.2, 4.2, 2.0],
      tags: ["tacos","al pastor","salsa","spicy","cilantro","lime"],
    ),
    Restaurant(
      id: "r5",
      name: "Lemon Grove",
      cuisine: "Mediterranean",
      tasteVector: [1.0, 2.2, 4.4, 0.8, 2.2],
      tags: ["lemon","olive oil","grill","sour","fresh"],
    ),
    Restaurant(
      id: "r6",
      name: "Salt & Smoke",
      cuisine: "BBQ",
      tasteVector: [1.2, 4.2, 0.6, 2.0, 3.2],
      tags: ["bbq","ribs","brisket","smoky","savory"],
    ),
    Restaurant(
      id: "r7",
      name: "Crispy Wok",
      cuisine: "Chinese",
      tasteVector: [2.2, 2.6, 1.2, 2.4, 3.0],
      tags: ["stir-fry","crispy","garlic","ginger"],
    ),
    Restaurant(
      id: "r8",
      name: "Dolce Vita Gelato",
      cuisine: "Italian Desserts",
      tasteVector: [4.6, 0.6, 0.4, 0.1, 1.2],
      tags: ["gelato","sweet","dessert","creamy"],
    ),
    Restaurant(
      id: "r9",
      name: "Pho Real",
      cuisine: "Vietnamese",
      tasteVector: [1.2, 2.2, 1.0, 1.4, 4.2],
      tags: ["pho","herbs","broth","umami","fresh"],
    ),
    Restaurant(
      id: "r10",
      name: "Citrus & Co.",
      cuisine: "Modern",
      tasteVector: [1.0, 1.8, 4.8, 0.4, 1.8],
      tags: ["citrus","bright","salads","sour"],
    ),
  ];
}
"@ | Set-Content -Encoding UTF8 lib/features/recommendations/data/mock_restaurants.dart

# presentation/recommendations_screen.dart
@"
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../taste_quiz/presentation/taste_quiz_controller.dart";
import "../data/recommender.dart";
import "../data/mock_restaurants.dart";

class RecommendationsScreen extends StatelessWidget {
  static const route = "/recommendations";
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TasteQuizController>();
    final profile = ctrl.current;

    return Scaffold(
      appBar: AppBar(title: const Text("Recommendations")),
      body: profile == null
          ? const Center(child: Text("Set your Taste Profile first from the Taste Quiz."))
          : _List(profile),
    );
  }
}

class _List extends StatelessWidget {
  final dynamic profile;
  const _List(this.profile);

  @override
  Widget build(BuildContext context) {
    final recs = Recommender()
        .recommend(profile: profile, candidates: MockRestaurants.all, topN: 30);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final item = recs[i];
        final r = item.restaurant;
        final pct = (item.score * 100).clamp(0, 100).toStringAsFixed(0);

        return ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          title: Text("${r.name}  •  ${r.cuisine}"),
          subtitle: Text(r.tags.take(6).join(" · ")),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("$pct%", style: Theme.of(context).textTheme.titleLarge),
              const Text("match"),
            ],
          ),
          onTap: () {},
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: recs.length,
    );
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/recommendations/presentation/recommendations_screen.dart

# test/recommender_test.dart
@"
import "package:flutter_test/flutter_test.dart";
import "package:similar_eats_desktop/features/taste_quiz/domain/taste_profile.dart";
import "package:similar_eats_desktop/features/recommendations/data/mock_restaurants.dart";
import "package:similar_eats_desktop/features/recommendations/data/recommender.dart";

void main() {
  test("recommender ranks spicy places higher for spicy profile", () {
    final spicy = const TasteProfile(sweet:1, salty:1.5, sour:1, spicy:5, umami:2.5);
    final recs = Recommender().recommend(profile: spicy, candidates: MockRestaurants.all, topN: 5);
    expect(recs.isNotEmpty, true);
    final top = recs.first.restaurant.cuisine.toLowerCase();
    expect(top.contains("thai") || top.contains("mexican") || top.contains("bbq"), true);
  });
}
"@ | Set-Content -Encoding UTF8 test/recommender_test.dart

# Integration snippet
@"
import 'features/recommendations/presentation/recommendations_screen.dart';

routes: {
  RecommendationsScreen.route: (_) => const RecommendationsScreen(),
  // ...
}

// From TasteTypeResultScreen button:
Navigator.of(context).pushNamed(RecommendationsScreen.route);
"@ | Set-Content -Encoding UTF8 lib/features/recommendations/INTEGRATION_SNIPPETS_RECS.txt

Write-Host "`nFiles written. Next steps:" -ForegroundColor Green
Write-Host "  1) Add route for RecommendationsScreen (see INTEGRATION_SNIPPETS_RECS.txt)" -ForegroundColor Yellow
Write-Host "  2) Change TasteTypeResultScreen button to pushNamed(RecommendationsScreen.route)" -ForegroundColor Yellow
Write-Host "  3) Run just our tests:  flutter test test/recommender_test.dart" -ForegroundColor Yellow
Write-Host "  4) Run app:           flutter run -d windows" -ForegroundColor Yellow
