import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import 'package:similar_eats_desktop/features/group_match/services/firestore_match_repo.dart';
import 'package:similar_eats_desktop/features/group_match/match_engine.dart';

class GroupMatchFromProfilesScreen extends StatefulWidget {
  const GroupMatchFromProfilesScreen({super.key});

  @override
  State<GroupMatchFromProfilesScreen> createState() =>
      _GroupMatchFromProfilesScreenState();
}

class _GroupMatchFromProfilesScreenState
    extends State<GroupMatchFromProfilesScreen> {
  final _friendIdsCtl = TextEditingController(text: "user1,user2,user3");
  final _latCtl = TextEditingController(text: "37.7749"); // SF sample
  final _lngCtl = TextEditingController(text: "-122.4194");
  double _radiusKm = 5.0;

  bool _loading = false;
  List<Restaurant> _results = [];
  LatLng get _center => LatLng(double.tryParse(_latCtl.text.trim()) ?? 0.0,
      double.tryParse(_lngCtl.text.trim()) ?? 0.0);

  final _repo = FirestoreMatchRepo();

  Future<void> _runMatch() async {
    final ids = _friendIdsCtl.text
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (ids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Enter at least one friend ID (comma-separated)")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final users = await _repo.loadUserPrefs(ids);
      if (users.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No profiles found for those IDs.")),
        );
        setState(() => _loading = false);
        return;
      }

      final radiusMeters = _radiusKm * 1000.0;
      final candidates = await _repo.loadRestaurantsAndFilter(
        center: _center,
        radiusMeters: radiusMeters,
      );

      final recs = GroupMatcher.recommend(
        users: users,
        candidates: candidates,
        centerLat: _center.latitude,
        centerLng: _center.longitude,
        radiusMeters: radiusMeters,
        limit: 20,
      );

      setState(() => _results = recs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Match failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _center;
    return Scaffold(
      appBar: AppBar(title: const Text("Group match (from profiles)")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _friendIdsCtl,
                  decoration: const InputDecoration(
                    labelText: "Friend User IDs (comma separated)",
                    hintText: "e.g., uidA, uidB, uidC",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _latCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Center lat",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _lngCtl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Center lng",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 25,
                        divisions: 24,
                        value: _radiusKm,
                        label: "${_radiusKm.toStringAsFixed(0)} km",
                        onChanged: (v) => setState(() => _radiusKm = v),
                      ),
                    ),
                    Text("${_radiusKm.toStringAsFixed(0)} km"),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _loading ? null : _runMatch,
                      icon: const Icon(Icons.search),
                      label: _loading
                          ? const Text("Matching…")
                          : const Text("Find"),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Map
                Expanded(
                  flex: 3,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: "com.example.similar_eats",
                      ),
                      MarkerLayer(
                        markers: [
                          // center pin
                          Marker(
                            point: center,
                            width: 28,
                            height: 28,
                            child: const Icon(Icons.my_location, size: 24),
                          ),
                          // restaurant pins
                          ..._results.map((r) => Marker(
                                point: LatLng(r.lat, r.lng),
                                width: 28,
                                height: 28,
                                child: const Icon(Icons.restaurant),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                // List
                Expanded(
                  flex: 2,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = _results[i];
                      return ListTile(
                        title: Text(r.name),
                        subtitle: Text([
                          if (r.cuisines.isNotEmpty)
                            "Cuisines: ${r.cuisines.join(", ")}",
                          if (r.supportsDiets.isNotEmpty)
                            "Diets: ${r.supportsDiets.join(", ")}",
                          if (r.unsafeAllergens.isNotEmpty)
                            "Allergens: ${r.unsafeAllergens.join(", ")}",
                        ].join(" · ")),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {/* push details later */},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
