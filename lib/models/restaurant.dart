class Restaurant {
  final String id;
  final String name;
  final List<String> serviceTags;
  final bool quickServiceFlag;
  final bool openLateFlag;

  Restaurant({
    required this.id,
    required this.name,
    this.serviceTags = const [],
    this.quickServiceFlag = false,
    this.openLateFlag = false,
  });
}
