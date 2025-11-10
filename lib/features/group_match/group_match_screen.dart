import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import 'package:similar_eats_desktop/features/group_match/fry_hints.dart';

class GroupMatchScreen extends StatefulWidget {
  static const routeName = "/group";
  const GroupMatchScreen({super.key});
  factory GroupMatchScreen.sample() => const GroupMatchScreen();

  @override
  State<GroupMatchScreen> createState() => _GroupMatchScreenState();
}

class _R {
  final String id, name;
  final double lat, lng;
  const _R(this.id, this.name, this.lat, this.lng);
}

class _GroupMatchScreenState extends State<GroupMatchScreen> {
  final LatLng _center = const LatLng(37.7749, -122.4194);

  // Demo restaurants (tap markers to see hints)
  final List<_R> _restaurants = const [
    _R("r1", "Patty Palace", 37.7762, -122.4190),
    _R("r2", "Fry Factory", 37.7723, -122.4170),
  ];

  // Demo users (you + girlfriend) with fry prefs
  final List<UserProfileLite> _users = const [
    UserProfileLite(
      id: "u1",
      name: "You",
      categories: {
        "fries": MicroPrefs(
          like: {"crispy", "crinkle", "shoestring"},
          dislike: {"waffle"},
        ),
      },
    ),
    UserProfileLite(
      id: "u2",
      name: "GF",
      categories: {
        "fries": MicroPrefs(
          like: {"soft", "skin-on"},
          dislike: {"waffle", "crinkle", "shoestring"},
        ),
      },
    ),
  ];

  // Simple per-restaurant menu
  final Map<String, List<MenuItemLite>> _menuByRestaurant = const {
    "r1": [
      MenuItemLite(
          id: "f1",
          name: "Crinkle Fries",
          category: "fries",
          tags: {"fries", "crispy", "crinkle"}),
      MenuItemLite(
          id: "f2",
          name: "Shoestring Fries",
          category: "fries",
          tags: {"fries", "crispy", "shoestring"}),
      MenuItemLite(
          id: "s1",
          name: "Onion Rings",
          category: "sides",
          tags: {"onion-rings", "crispy"}),
    ],
    "r2": [
      MenuItemLite(
          id: "f3",
          name: "Skin-On Fries",
          category: "fries",
          tags: {"fries", "skin-on", "soft"}),
      MenuItemLite(
          id: "f4",
          name: "Waffle Fries",
          category: "fries",
          tags: {"fries", "waffle"}),
      MenuItemLite(
          id: "s2",
          name: "Tater Tots",
          category: "sides",
          tags: {"tots", "crispy"}),
    ],
  };

  void _showFryHintsFor(String rid, String rname) {
    final menu = _menuByRestaurant[rid] ?? const <MenuItemLite>[];
    final perUser = topPicksPerUser(
      category: "fries",
      users: _users,
      menu: menu,
      perUser: 2,
    );
    final consensus = itemsEveryoneLikes(
      category: "fries",
      users: _users,
      menu: menu,
      threshold: 0.25,
    );

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rname, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (consensus.isNotEmpty)
                Text(
                    "Everyone can enjoy: ${consensus.map((m) => m.name).join(", ")}")
              else
                const Text("Mixed tastes on fries here"),
              const SizedBox(height: 12),
              ...perUser.entries.map((e) {
                final user = e.key;
                final picks = e.value;
                final text = picks.isEmpty
                    ? "No good fry match — maybe try onion rings."
                    : picks.map(shortHint).join(" • ");
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text("${user.name}: $text"),
                );
              }),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Group Match (demo)")),
      body: FlutterMap(
        options: MapOptions(initialCenter: _center, initialZoom: 12),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ["a", "b", "c"],
            userAgentPackageName: "com.example.similar_eats_desktop",
          ),
          MarkerLayer(
            markers: _restaurants.map((r) {
              return Marker(
                point: LatLng(r.lat, r.lng),
                width: 42,
                height: 42,
                child: GestureDetector(
                  onTap: () => _showFryHintsFor(r.id, r.name),
                  child: const Icon(Icons.place, size: 36),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
