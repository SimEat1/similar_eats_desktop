import 'dart:math' as math;

/// Simple taste profile utilities + a smoke test.
class TasteProfileLogic {
  /// Cosine similarity of two sparse taste vectors (key -> weight).
  static double cosine(Map<String, num> a, Map<String, num> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Use the union of keys so missing entries count as 0.
    final keys = <String>{...a.keys, ...b.keys};

    double dot = 0, magA = 0, magB = 0;
    for (final k in keys) {
      final x = (a[k] ?? 0).toDouble();
      final y = (b[k] ?? 0).toDouble();
      dot += x * y;
      magA += x * x;
      magB += y * y;
    }
    final denom = (math.sqrt(magA) * math.sqrt(magB));
    if (denom == 0) return 0.0;
    return dot / denom;
  }
}

/// Quick smoke test you can call from anywhere (e.g., Debug FAB).
Future<void> debugTaste() async {
  print('>>> [debugTaste] starting…');

  final user = <String, num>{
    'spicy': 3,
    'crispy': 5,
    'cheesy': 2,
  };
  final other = <String, num>{
    'spicy': 2,
    'crispy': 4,
    'cheesy': 1,
  };

  final sim = TasteProfileLogic.cosine(user, other);
  print('>>> [debugTaste] cosine(user, other) = ');

  print('>>> [debugTaste] done.');
}
