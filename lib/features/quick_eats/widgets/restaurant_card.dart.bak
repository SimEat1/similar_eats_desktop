import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/features/quick_eats/models/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onLike,
    this.onDislike,
    this.onSpiceTooHot,
    this.onPricePicked,
    this.showQuickBadge = false,
  });

  final Restaurant restaurant;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onSpiceTooHot;
  final void Function(int priceLevel)? onPricePicked;
  final bool showQuickBadge;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.restaurant_menu, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (showQuickBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Quick',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: -6,
                    children: restaurant.serviceTags
                        .map((t) => Chip(
                              label: Text(t),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Like',
                        icon: const Icon(Icons.thumb_up_outlined),
                        onPressed: onLike,
                      ),
                      IconButton(
                        tooltip: 'Dislike',
                        icon: const Icon(Icons.thumb_down_outlined),
                        onPressed: onDislike,
                      ),
                      IconButton(
                        tooltip: 'Too spicy',
                        icon: const Icon(Icons.local_fire_department_outlined),
                        onPressed: onSpiceTooHot,
                      ),
                      const Spacer(),
                      PopupMenuButton<int>(
                        tooltip: 'Price comfort',
                        onSelected: onPricePicked,
                        itemBuilder: (ctx) => const [
                          PopupMenuItem(value: 1, child: Text(r'$  (budget)')),
                          PopupMenuItem(
                              value: 2,
                              child: Text(
                                  r'$root\lib\features\quick_eats\widgets\restaurant_card.dart (casual)')),
                          PopupMenuItem(
                              value: 3,
                              child: Text(
                                  r'$root\lib\features\quick_eats\widgets\restaurant_card.dart$ (nice)')),
                          PopupMenuItem(
                              value: 4,
                              child: Text(
                                  r'$root\lib\features\quick_eats\widgets\restaurant_card.dart$root\lib\features\quick_eats\widgets\restaurant_card.dart (premium)')),
                        ],
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.attach_money),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
