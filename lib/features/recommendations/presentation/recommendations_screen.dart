import "package:flutter/material.dart";
import "package:provider/provider.dart";

import 'package:similar_eats_desktop/features/taste_quiz/presentation/taste_quiz_controller.dart';
import 'package:similar_eats_desktop/features/recommendations/data/recommender.dart';
import 'package:similar_eats_desktop/features/recommendations/data/mock_restaurants.dart';
import 'package:similar_eats_desktop/features/recommendations/domain/restaurant.dart';
import 'package:similar_eats_desktop/features/recommendations/presentation/restaurant_detail_screen.dart';
import 'package:similar_eats_desktop/features/favorites/presentation/favorites_controller.dart';

class RecommendationsScreen extends StatelessWidget {
  static const route = "/recommendations";
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<TasteQuizController>();
    final profile = quiz.current;

    return Scaffold(
      appBar: AppBar(title: const Text("Recommendations")),
      body:
          profile == null ? const _NeedsProfile() : _RecList(profile: profile),
    );
  }
}

class _NeedsProfile extends StatelessWidget {
  const _NeedsProfile();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          "Set your Taste Profile first from the Taste Quiz.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _RecList extends StatelessWidget {
  final dynamic profile; // TasteProfile
  const _RecList({required this.profile});

  @override
  Widget build(BuildContext context) {
    final recs = Recommender()
        .recommend(profile: profile, candidates: MockRestaurants.all, topN: 30);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final item = recs[i];
        final Restaurant r = item.restaurant;
        final pct = (item.score * 100).clamp(0, 100).toStringAsFixed(0);

        return ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          title: Text("${r.name}  •  ${r.cuisine}"),
          subtitle: Text(r.tags.take(6).join(" · ")),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("$pct%", style: Theme.of(context).textTheme.titleLarge),
                  const Text("match"),
                ],
              ),
              const SizedBox(width: 8),
              Consumer<FavoritesController>(
                builder: (_, fav, __) {
                  final isFav = fav.isFavorite(r.id);
                  return IconButton(
                    tooltip: isFav ? "Remove favorite" : "Save to favorites",
                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                    onPressed: () => fav.toggle(r.id),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).pushNamed(
              RestaurantDetailScreen.route,
              arguments: r,
            );
          },
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: recs.length,
    );
  }
}
