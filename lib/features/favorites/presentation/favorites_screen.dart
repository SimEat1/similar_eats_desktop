import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:similar_eats_desktop/features/recommendations/data/mock_restaurants.dart';
import 'package:similar_eats_desktop/features/recommendations/domain/restaurant.dart';
import 'package:similar_eats_desktop/features/recommendations/presentation/restaurant_detail_screen.dart';
import 'package:similar_eats_desktop/features/favorites/presentation/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  static const route = '/favorites';
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FavoritesController>();
    final all = MockRestaurants.all;
    final favs = all.where((r) => ctrl.ids.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favs.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final Restaurant r = favs[i];
                return Dismissible(
                  key: ValueKey(r.id),
                  background: Container(color: Theme.of(context).colorScheme.error),
                  onDismissed: (_) => context.read<FavoritesController>().toggle(r.id),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    title: Text(r.name),
                    subtitle: Text(r.cuisine),
                    onTap: () => Navigator.of(context).pushNamed(
                      RestaurantDetailScreen.route,
                      arguments: r,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
