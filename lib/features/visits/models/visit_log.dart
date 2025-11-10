import 'package:similar_eats_desktop/shared/portion.dart';
import 'package:similar_eats_desktop/shared/portion_size.dart';

class VisitLog {
  final String id;
  final DateTime createdAt;
  final Portion portion;
  final int tasteRating; // 1..5
  final int portionRating; // 1..5
  final String placeId;
  final String itemId;

  const VisitLog({
    required this.id,
    required this.createdAt,
    this.portion = const Portion(size: PortionSize.m),
    this.tasteRating = 3,
    this.portionRating = 3,
    this.placeId = '',
    this.itemId = '',
  });

  factory VisitLog.fromJson(Map<String, dynamic> json, {String? id}) {
    final portionJson = json['portion'] as Map<String, dynamic>?;
    return VisitLog(
      id: id ?? (json['id'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      portion: portionJson != null
          ? Portion.fromJson(portionJson)
          : const Portion(size: PortionSize.m),
      tasteRating: (json['taste_rating'] is num)
          ? (json['taste_rating'] as num).toInt()
          : 3,
      portionRating: (json['portion_rating'] is num)
          ? (json['portion_rating'] as num).toInt()
          : 3,
      placeId: json['place_id'] as String? ?? '',
      itemId: json['item_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'portion': portion.toJson(),
      'taste_rating': tasteRating,
      'portion_rating': portionRating,
      'place_id': placeId,
      'item_id': itemId,
    };
  }

  VisitLog copyWith({
    String? id,
    DateTime? createdAt,
    Portion? portion,
    int? tasteRating,
    int? portionRating,
    String? placeId,
    String? itemId,
  }) {
    return VisitLog(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      portion: portion ?? this.portion,
      tasteRating: tasteRating ?? this.tasteRating,
      portionRating: portionRating ?? this.portionRating,
      placeId: placeId ?? this.placeId,
      itemId: itemId ?? this.itemId,
    );
  }
}
