import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/shared/geo/map_open.dart';
import 'package:similar_eats_desktop/shared/geo/location.dart';
import 'package:geolocator/geolocator.dart';

class ExploreMapScreen extends StatefulWidget {
  static const routeName = "/explore_map";
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  Position? _me;

  // Mock places (SF) until we wire real data
  final _places = const [
    _Place('Bob\'s Burgers', 37.77490, -122.41940),
    _Place('Sushi Spot', 37.78100, -122.41120),
    _Place('Green Bowl', 37.76800, -122.42900),
  ];

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
  }

  Future<void> _loadMyLocation() async {
    final pos = await getCurrentPositionOrNull();
    if (!mounted) return;
    setState(() => _me = pos);
  }

  Future<void> _toPlace(_Place p) async {
    await openMapPlace(lat: p.lat, lng: p.lng, label: p.name);
  }

  Future<void> _directionsTo(_Place p) async {
    await openMapDirections(
      fromLat: _me?.latitude,
      fromLng: _me?.longitude,
      toLat: p.lat,
      toLng: p.lng,
      label: p.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore map'),
        actions: [
          IconButton(
            tooltip: _me == null ? 'Locate me (uses maps “Your location”)' : 'Directions from my location',
            icon: const Icon(Icons.explore_outlined),
            onPressed: () async {
              // Open a generic “near me” view in Maps.
              // If we know _me, open directions to the first mock place
              // just to demo; otherwise just open maps web/app.
              final p = _places.first;
              await _directionsTo(p);
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _places.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final p = _places[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(p.name),
              subtitle: Text('${p.lat.toStringAsFixed(5)}, ${p.lng.toStringAsFixed(5)}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Open pin',
                    icon: const Icon(Icons.place),
                    onPressed: () => _toPlace(p),
                  ),
                  IconButton(
                    tooltip: 'Directions',
                    icon: const Icon(Icons.directions_outlined),
                    onPressed: () => _directionsTo(p),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Place {
  final String name;
  final double lat;
  final double lng;
  const _Place(this.name, this.lat, this.lng);
}




