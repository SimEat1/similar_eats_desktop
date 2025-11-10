import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:geolocator/geolocator.dart";

import 'package:similar_eats_desktop/features/friends/data/friends_repository.dart';

const String _mapTilerKey =
    String.fromEnvironment("MAPTILER_KEY", defaultValue: "");

class FriendMapScreen extends StatefulWidget {
  final String? initialUid;
  const FriendMapScreen({super.key, this.initialUid});
  @override
  State<FriendMapScreen> createState() => _FriendMapScreenState();
}

class _FriendMapScreenState extends State<FriendMapScreen> {
  final _db = FirebaseFirestore.instance;
  final _me = FirebaseAuth.instance.currentUser;
  final _map = MapController();
  final _repo = FriendsRepository();

  LatLng _center = const LatLng(39.5, -98.35);
  double _zoom = 4;
  bool _loading = true;
  List<Map<String, dynamic>> _items = const [];

  Future<void> _setMyPoint(LatLng p) async {
    final uid = _me?.uid;
    if (uid == null) return;
    try {
      await _db.collection("publicProfiles").doc(uid).set({
        "lastLat": p.latitude,
        "lastLng": p.longitude,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Location updated")));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not update location")),
      );
    }
    await _load();
  }

  Future<void> _load() async {
    final myUid = _me?.uid;
    if (myUid == null) {
      setState(() {
        _loading = false;
        _items = const [];
      });
      return;
    }
    setState(() => _loading = true);

    final friends = await _repo.streamFriends().first;
    final following = await _repo.streamFollowing().first;

    final ids = <String>{
      myUid,
      ...friends.map((p) => p.uid),
      ...following.map((p) => p.uid)
    };
    if (ids.isEmpty) {
      setState(() {
        _loading = false;
        _items = const [];
      });
      return;
    }

    final list = ids.toList();
    final chunks = <List<String>>[];
    for (var i = 0; i < list.length; i += 10) {
      chunks
          .add(list.sublist(i, (i + 10 > list.length) ? list.length : i + 10));
    }

    final results = <QuerySnapshot<Map<String, dynamic>>>[];
    for (final chunk in chunks) {
      final qs = await _db
          .collection("publicProfiles")
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.add(qs);
    }

    final items = <Map<String, dynamic>>[];
    for (final qs in results) {
      for (final d in qs.docs) {
        final j = d.data();
        items.add({
          "uid": d.id,
          "name": (j["displayName"] ?? "SE user").toString(),
          "lat":
              (j["lastLat"] is num) ? (j["lastLat"] as num).toDouble() : null,
          "lng":
              (j["lastLng"] is num) ? (j["lastLng"] as num).toDouble() : null,
        });
      }
    }

    setState(() {
      _items = items;
      _loading = false;
    });

    if (widget.initialUid != null) {
      final t = items.firstWhere(
        (e) =>
            e["uid"] == widget.initialUid &&
            e["lat"] != null &&
            e["lng"] != null,
        orElse: () => {},
      );
      if (t.isNotEmpty) {
        final p = LatLng(t["lat"], t["lng"]);
        _center = p;
        _zoom = 14;
        _map.move(_center, _zoom);
      }
    }
  }

  Future<void> _locateMe() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied.")),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      final p = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _center = p;
        _zoom = 14;
      });
      _map.move(_center, _zoom);
      await _setMyPoint(p);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not get location: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = _me?.uid;
    final markers = <Marker>[];
    for (final e in _items) {
      final lat = e["lat"] as double?;
      final lng = e["lng"] as double?;
      if (lat == null || lng == null) continue;
      final isMe = e["uid"] == myUid;
      markers.add(Marker(
        point: LatLng(lat, lng),
        width: 44,
        height: 44,
        child: Semantics(
          label: isMe ? "Your location" : "Location of ${e["name"]}",
          button: true,
          child: Tooltip(
            message: isMe ? "You" : (e["name"] as String),
            child:
                Icon(isMe ? Icons.my_location : Icons.location_pin, size: 36),
          ),
        ),
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends map"),
        actions: [
          IconButton(
              tooltip: "Locate me",
              icon: const Icon(Icons.my_location),
              onPressed: _locateMe),
          IconButton(
              tooltip: "Refresh",
              icon: const Icon(Icons.refresh),
              onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    mapController: _map,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: _zoom,
                      onLongPress: (tapPos, p) => _setMyPoint(p),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: _mapTilerKey.isNotEmpty
                            ? "https://api.maptiler.com/maps/streets-v2/256/{z}/{x}/{y}.png?key=$_mapTilerKey"
                            : "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName:
                            "com.example.similar_eats_desktop",
                      ),
                      MarkerLayer(markers: markers),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Long-press on the map to set your pin. Friends appear if they’ve set theirs.",
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
    );
  }
}
