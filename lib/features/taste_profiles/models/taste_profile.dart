import 'dart:convert';

class TasteProfile {
  final String uid;
  final Set<String> cuisines; // e.g., {"mexican","bbq","thai"}
  final Set<String> tags;     // future: dish/style keywords, etc.
  final int updatedAtMillis;

  const TasteProfile({
    required this.uid,
    required this.cuisines,
    required this.tags,
    required this.updatedAtMillis,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'cuisines': cuisines.toList()..sort(),
        'tags': tags.toList()..sort(),
        'updatedAtMillis': updatedAtMillis,
      };

  factory TasteProfile.fromJson(Map<String, dynamic> m) {
    return TasteProfile(
      uid: (m['uid'] ?? '') as String,
      cuisines: _toStringSet(m['cuisines']),
      tags: _toStringSet(m['tags']),
      updatedAtMillis: (m['updatedAtMillis'] ?? 0) as int,
    );
  }

  static Set<String> _toStringSet(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString().trim().toLowerCase()).toSet();
    }
    if (v is Map) {
      // if someone wrote as map-of-true
      return v.keys.map((e) => e.toString().trim().toLowerCase()).toSet();
    }
    if (v is String && v.isNotEmpty) {
      try {
        final list = (jsonDecode(v) as List).map((e) => e.toString()).toList();
        return list.map((e) => e.trim().toLowerCase()).toSet();
      } catch (_) {}
    }
    return <String>{};
  }
}

class SimilarUser {
  final String uid;
  final double score; // 0.0 - 1.0

  const SimilarUser(this.uid, this.score);
}

