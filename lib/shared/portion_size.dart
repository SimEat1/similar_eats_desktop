enum PortionSize { xs, s, m, l, xl }

extension PortionSizeX on PortionSize {
  String get label {
    switch (this) {
      case PortionSize.xs:
        return 'XS';
      case PortionSize.s:
        return 'S';
      case PortionSize.m:
        return 'M';
      case PortionSize.l:
        return 'L';
      case PortionSize.xl:
        return 'XL';
    }
  }

  String get code => toString().split('.').last;
  static PortionSize parse(String? code,
      {PortionSize fallback = PortionSize.m}) {
    switch (code) {
      case 'xs':
        return PortionSize.xs;
      case 's':
        return PortionSize.s;
      case 'm':
        return PortionSize.m;
      case 'l':
        return PortionSize.l;
      case 'xl':
        return PortionSize.xl;
      default:
        return fallback;
    }
  }
}
