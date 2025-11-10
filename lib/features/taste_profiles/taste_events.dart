import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';

/// Simple event logger to RTDB at /tasteEvents/{uid}/autoId
class TasteEvents {
  static Future<void> log({
    required String uid,
    required String
        type, // e.g., like_tag, dislike_tag, spice_feedback, price_feedback
    required String value, // e.g., bbq, greasy, too_spicy, 2
    Map<String, Object?> context = const {},
  }) async {
    final ref = FirebaseDatabase.instance.ref('tasteEvents/$uid').push();
    await ref.set({
      'type': type,
      'value': value,
      'context': jsonEncode(context),
      'ts': ServerValue.timestamp,
      'v': 1,
    });
  }
}

/// Lightweight, opinionated profile updater at /userTaste/{uid}
class TasteAdaptiveUpdater {
  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  Future<void> apply({
    required String uid,
    required String type,
    required String value,
  }) async {
    final userTasteRef = _root.child('userTaste/$uid');

    switch (type) {
      case 'like_tag':
        await userTasteRef.child('likedTags/$value').set(true);
        break;
      case 'dislike_tag':
        await userTasteRef.child('avoidTags/$value').set(true);
        break;
      case 'spice_feedback':
        // value: "too_spicy" or "mild_ok" etc. Here we treat "too_spicy" as reduce tolerance by 10.
        final tolSnap = await userTasteRef.child('spiceTolerance').get();
        final current =
            (tolSnap.value is num) ? (tolSnap.value as num).toInt() : 50;
        final next = (value == 'too_spicy')
            ? (current - 10).clamp(0, 100)
            : (current + 5).clamp(0, 100);
        await userTasteRef.child('spiceTolerance').set(next);
        break;
      case 'price_feedback':
        // value: "1".."4" (comfort ceiling). Persist as int.
        final priceLevel = int.tryParse(value) ?? 2;
        await userTasteRef.child('priceComfort').set(priceLevel);
        break;
      default:
        // no-op for unknown types
        break;
    }
  }
}
