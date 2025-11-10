import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SoloMapScreen extends StatefulWidget {
  static const routeName = '/map';
  const SoloMapScreen({super.key});

  @override
  State<SoloMapScreen> createState() => _SoloMapScreenState();
}

class _SoloMapScreenState extends State<SoloMapScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(37.7749, -122.4194);
  final double _zoom = 13;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.similar_eats',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _center,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin, size: 40),
                  ),
                ],
              ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solo search TBD')),
                      );
                    },
                    child: const Text('Find nearby'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
