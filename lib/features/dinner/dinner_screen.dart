// ignore_for_file: unused_local_variable
import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/shared/geo/map_open.dart';

class DinnerScreen extends StatelessWidget {
  static const routeName = "/dinner";

  const DinnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Demo cuisine tiles; tap -> open the native map app searching that cuisine near you
    final cuisines = <_Cuisine>[
      const _Cuisine('Steak', Icons.restaurant),
      const _Cuisine('Burgers', Icons.lunch_dining),
      const _Cuisine('Pizza', Icons.local_pizza),
      const _Cuisine('Sushi', Icons.set_meal),
      const _Cuisine('Tacos', Icons.fastfood),
      const _Cuisine('BBQ', Icons.outdoor_grill),
      const _Cuisine('Ramen', Icons.ramen_dining),
      const _Cuisine('Indian', Icons.rice_bowl),
      const _Cuisine('Thai', Icons.dinner_dining),
      const _Cuisine('Mediterranean', Icons.kebab_dining),
      const _Cuisine('Seafood', Icons.food_bank),
      const _Cuisine('Vegan', Icons.eco),
      const _Cuisine('Salads', Icons.local_florist),
      const _Cuisine('Wings', Icons.restaurant_menu),
      const _Cuisine('Breakfast', Icons.free_breakfast),
      const _Cuisine('Desserts', Icons.icecream),
      const _Cuisine('Coffee', Icons.coffee),
      const _Cuisine('Sandwiches', Icons.lunch_dining),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("What’s for dinner?"),
        actions: [
          // App bar actions to jump out to maps quickly
          IconButton(
            tooltip: 'Open map search (near me)',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => openMapSearch(query: 'restaurants'),
          ),
          IconButton(
            tooltip: 'Open directions to “Best nearby” (demo)',
            icon: const Icon(Icons.near_me_outlined),
            onPressed: () => openMapDirections(
              toLat: 37.7749, // demo fallback if platform can’t geolocate
              toLng: -122.4194,
              label: 'Best Nearby',
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive grid: 1–2–3+ columns depending on width
          int columns = 1;
          final w = constraints.maxWidth;
          if (w >= 580 && w < 900) {
            columns = 2;
          } else if (w >= 900 && w < 1200) {
            columns = 3;
          } else if (w >= 1200) {
            columns = 4;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: cuisines.length,
            itemBuilder: (_, i) {
              final c = cuisines[i];
              return _CuisineCard(
                cuisine: c,
                onTap: () => openMapSearch(query: c.label),
              );
            },
          );
        },
      ),
    );
  }
}

class _Cuisine {
  final String label;
  final IconData icon;
  const _Cuisine(this.label, this.icon);
}

class _CuisineCard extends StatelessWidget {
  final _Cuisine cuisine;
  final VoidCallback onTap;
  const _CuisineCard({required this.cuisine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(cuisine.icon, size: 56, color: theme.colorScheme.onSurface),
              const SizedBox(height: 16),
              Text(
                cuisine.label,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
