import 'package:flutter/material.dart';
import '../models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, required this.showQuickBadge, required this.showLateBadge});

  final Restaurant restaurant;
  final bool showQuickBadge;
  final bool showLateBadge;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];
    if (showQuickBadge) {
      badges.add(_pill(context, 'Quick'));
    }
    if (showLateBadge) {
      badges.add(_pill(context, 'Late'));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restaurant, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, runSpacing: 6, children: badges),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext ctx, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(ctx).textTheme.labelMedium),
    );
  }
}
