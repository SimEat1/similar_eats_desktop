import 'package:similar_eats_desktop/shared/portion.dart';

/// Canonical wire code: XS/S/M/L/XL regardless of enum case naming.
extension PortionWire on Portion {
  String get wire {
    final name = toString().split('.').last; // xs, XS, extraSmall, medium, etc.
    switch (name) {
      case 'xs':
      case 'XS':
      case 'extraSmall':
      case 'extra_small':
        return 'XS';
      case 's':
      case 'S':
      case 'small':
        return 'S';
      case 'm':
      case 'M':
      case 'medium':
        return 'M';
      case 'l':
      case 'L':
      case 'large':
        return 'L';
      case 'xl':
      case 'XL':
      case 'extraLarge':
      case 'extra_large':
        return 'XL';
      default:
        return name.toUpperCase(); // safe fallback
    }
  }
}
