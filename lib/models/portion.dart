enum Portion { xs, s, m, l, xl }

extension PortionX on Portion {
  String get wire => name.toUpperCase(); // "XS".."XL"

  static Portion? fromWire(String? s) {
    switch (s?.toUpperCase()) {
      case 'XS':
        return Portion.xs;
      case 'S':
        return Portion.s;
      case 'M':
        return Portion.m;
      case 'L':
        return Portion.l;
      case 'XL':
        return Portion.xl;
      default:
        return null;
    }
  }
}
