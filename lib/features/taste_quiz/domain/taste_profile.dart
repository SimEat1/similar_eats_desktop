class TasteProfile {
  final double sweet;
  final double salty;
  final double sour;
  final double spicy;
  final double umami;

  const TasteProfile({
    required this.sweet,
    required this.salty,
    required this.sour,
    required this.spicy,
    required this.umami,
  });

  /// clamp each to 0..5
  TasteProfile normalized() {
    double c(double v) => v.clamp(0.0, 5.0);
    return TasteProfile(
      sweet: c(sweet),
      salty: c(salty),
      sour: c(sour),
      spicy: c(spicy),
      umami: c(umami),
    );
  }

  Map<String, double> toMap() => {
        'sweet': sweet,
        'salty': salty,
        'sour': sour,
        'spicy': spicy,
        'umami': umami,
      };

  factory TasteProfile.fromMap(Map<String, dynamic> m) => TasteProfile(
        sweet: (m['sweet'] ?? 0).toDouble(),
        salty: (m['salty'] ?? 0).toDouble(),
        sour: (m['sour'] ?? 0).toDouble(),
        spicy: (m['spicy'] ?? 0).toDouble(),
        umami: (m['umami'] ?? 0).toDouble(),
      );

  /// Handy vector form for cosine similarity, etc.
  List<double> asVector() => [sweet, salty, sour, spicy, umami];

  @override
  String toString() => 'TasteProfile(${toMap()})';
}

enum TasteBadge {
  spiceChaser,
  sweetTooth,
  saltSeeker,
  sourScout,
  umamiExplorer,
  balanced
}

extension TasteBadgeX on TasteBadge {
  String get emoji => {
        TasteBadge.spiceChaser: "🔥",
        TasteBadge.sweetTooth: "🍭",
        TasteBadge.saltSeeker: "🧂",
        TasteBadge.sourScout: "🍋",
        TasteBadge.umamiExplorer: "🍜",
        TasteBadge.balanced: "🎯",
      }[this]!;

  String get label => {
        TasteBadge.spiceChaser: "Spice Chaser",
        TasteBadge.sweetTooth: "Sweet Tooth",
        TasteBadge.saltSeeker: "Salt Seeker",
        TasteBadge.sourScout: "Sour Scout",
        TasteBadge.umamiExplorer: "Umami Explorer",
        TasteBadge.balanced: "Balanced Palette",
      }[this]!;
}

/// Very simple badge rule: pick the max taste; if all near mid, call it balanced.
TasteBadge computeBadge(TasteProfile p) {
  final v = p.normalized();
  final entries = {
    'sweet': v.sweet,
    'salty': v.salty,
    'sour': v.sour,
    'spicy': v.spicy,
    'umami': v.umami,
  }.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = entries.first;
  final avg =
      entries.map((e) => e.value).reduce((a, b) => a + b) / entries.length;
  final spread = top.value - avg;
  if (spread.abs() < 0.6) return TasteBadge.balanced;

  switch (top.key) {
    case 'spicy':
      return TasteBadge.spiceChaser;
    case 'sweet':
      return TasteBadge.sweetTooth;
    case 'salty':
      return TasteBadge.saltSeeker;
    case 'sour':
      return TasteBadge.sourScout;
    case 'umami':
      return TasteBadge.umamiExplorer;
  }
  return TasteBadge.balanced;
}
