import "package:flutter/material.dart";
import 'package:similar_eats_desktop/features/recommendations/domain/restaurant.dart';

class RestaurantDetailScreen extends StatelessWidget {
  static const route = "/restaurantDetail";
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is! Restaurant) {
      return const Scaffold(
        body: Center(child: Text("No restaurant provided")),
      );
    }
    final r = args;

    Widget bar(String k, double v) => Row(
          children: [
            SizedBox(width: 90, child: Text(k)),
            Expanded(
                child: LinearProgressIndicator(value: (v.clamp(0, 5)) / 5)),
            const SizedBox(width: 12),
            Text(v.toStringAsFixed(1)),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: Text(r.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(r.cuisine, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: -8,
            children: r.tags.take(12).map((t) => Chip(label: Text(t))).toList(),
          ),
          const SizedBox(height: 20),
          Text("Taste profile", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          bar("Sweet", r.tasteVector[0]),
          const SizedBox(height: 8),
          bar("Salty", r.tasteVector[1]),
          const SizedBox(height: 8),
          bar("Sour", r.tasteVector[2]),
          const SizedBox(height: 8),
          bar("Spicy", r.tasteVector[3]),
          const SizedBox(height: 8),
          bar("Umami", r.tasteVector[4]),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Coming soon: Save to Favorites / Try List")),
              );
            },
            child: const Text("Save to Favorites"),
          ),
        ],
      ),
    );
  }
}
