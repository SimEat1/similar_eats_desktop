import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:similar_eats_desktop/features/recommendations/data/mock_restaurants.dart';
import 'package:similar_eats_desktop/features/recommendations/domain/restaurant.dart';
import 'package:similar_eats_desktop/features/recommendations/presentation/restaurant_detail_screen.dart';
import 'package:similar_eats_desktop/features/try_list/presentation/try_list_controller.dart';

class TryListScreen extends StatelessWidget {
  static const route = '/tryList';
  const TryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TryListController>();
    final all = MockRestaurants.all;
    final list = all.where((r) => ctrl.ids.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Try List')),
      body: list.isEmpty
          ? const Center(child: Text('Your Try List is empty'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final Restaurant r = list[i];
                return Dismissible(
                  key: ValueKey(r.id),
                  background: Container(color: Theme.of(context).colorScheme.error),
                  onDismissed: (_) => context.read<TryListController>().toggle(r.id),
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
