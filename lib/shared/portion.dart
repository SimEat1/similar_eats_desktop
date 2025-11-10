import 'package:similar_eats_desktop/shared/portion_size.dart';

class Portion {
  final PortionSize size;
  final double? grams;

  const Portion({required this.size, this.grams});

  Portion copyWith({PortionSize? size, double? grams}) =>
      Portion(size: size ?? this.size, grams: grams);

  Map<String, Object?> toJson() => {
        'size': size.code,
        if (grams != null) 'grams': grams,
      };

  static Portion fromJson(Object? data) {
    if (data is Map) {
      return Portion(
        size: PortionSizeX.parse(data['size'] as String?),
        grams:
            (data['grams'] is num) ? (data['grams'] as num).toDouble() : null,
      );
    }
    return const Portion(size: PortionSize.m);
  }

  @override
  String toString() =>
      'Portion(${size.label}${grams != null ? ", ${grams!.toStringAsFixed(0)}g" : ""})';
}
