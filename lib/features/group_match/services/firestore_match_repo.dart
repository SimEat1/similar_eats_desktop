import "package:cloud_firestore/cloud_firestore.dart";
import "package:latlong2/latlong.dart";
import 'package:similar_eats_desktop/features/group_match/match_engine.dart';

class FirestoreMatchRepo {
  final FirebaseFirestore _db;
  final Distance _dist = const Distance();

  FirestoreMatchRepo({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// profiles/{uid} document shape (arrays of strings):
  /// cuisines, flavors, diets, allergies
  Future<List<UserPrefs>> loadUserPrefs(List<String> uids) async {
    final results = <UserPrefs>[];
    for (final uid in uids) {
      final snap = await _db.collection("profiles").doc(uid).get();
      if (!snap.exists) continue;
      final data = snap.data() ?? {};
      results.add(
        UserPrefs(
          cuisines: _toSet(data["cuisines"]),
          flavors: _toSet(data["flavors"]),
          diets: _toSet(data["diets"]),
          allergies: _toSet(data["allergies"]),
        ),
      );
    }
    return results;
  }

  /// restaurants collection shape:
  /// { name, lat, lng, cuisines[], flavors[], supportsDiets[], unsafeAllergens[] }
  ///
  /// NOTE: For MVP we fetch up to [fetchLimit] and filter in memory by radius.
  /// For production, switch to a geohash lib (e.g., geoflutterfire2) to query by circle.
  Future<List<Restaurant>> loadRestaurantsAndFilter({
    required LatLng center,
    required double radiusMeters,
    int fetchLimit = 200,
  }) async {
    final qs = await _db.collection("restaurants").limit(fetchLimit).get();
    final out = <Restaurant>[];
    for (final doc in qs.docs) {
      final d = doc.data();
      final lat = (d["lat"] as num?)?.toDouble();
      final lng = (d["lng"] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final meters = _dist(LatLng(lat, lng), center);
      if (meters > radiusMeters) continue;

      out.add(
        Restaurant(
          id: doc.id,
          name: (d["name"] as String?) ?? "Unnamed",
          lat: lat,
          lng: lng,
          cuisines: _toSet(d["cuisines"]),
          flavors: _toSet(d["flavors"]),
          supportsDiets: _toSet(d["supportsDiets"]),
          unsafeAllergens: _toSet(d["unsafeAllergens"]),
        ),
      );
    }
    return out;
  }

  Set<String> _toSet(dynamic v) {
    if (v is Iterable) {
      return v.map((e) => e.toString()).toSet();
    }
    return <String>{};
  }
}
