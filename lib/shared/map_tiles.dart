import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

class MapTiles {
  static const String key =
      String.fromEnvironment('MAPTILER_KEY', defaultValue: '');
  static const String userAgent = 'com.example.similar_eats_desktop';

  static TileLayer layer({bool satellite = true}) {
    final useMapTiler = key.isNotEmpty;

    if (kDebugMode) {
      debugPrint(
        '🗺️ Map provider: ${useMapTiler ? (satellite ? "MapTiler satellite" : "MapTiler streets") : "OpenStreetMap (fallback)"}',
      );
    }

    final url = useMapTiler
        ? (satellite
            ? 'https://api.maptiler.com/tiles/satellite/256/{z}/{x}/{y}.jpg?key=$key'
            : 'https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=$key')
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    return TileLayer(
      urlTemplate: url,
      userAgentPackageName: userAgent,
    );
  }
}
