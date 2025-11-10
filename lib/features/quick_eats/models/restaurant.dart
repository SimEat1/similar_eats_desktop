class Restaurant {
  final String id;
  final String name;
  final List<String> serviceTags;
  final bool quickServiceFlag;
  final bool openLateFlag;

  const Restaurant({
    required this.id,
    required this.name,
    this.serviceTags = const [],
    this.quickServiceFlag = false,
    this.openLateFlag = false,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: (json['id'] ?? json['key'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      serviceTags:
          (json['serviceTags'] as List?)?.map((e) => e.toString()).toList() ??
              const <String>[],
      quickServiceFlag: json['quickServiceFlag'] == true,
      openLateFlag: json['openLateFlag'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'serviceTags': serviceTags,
        'quickServiceFlag': quickServiceFlag,
        'openLateFlag': openLateFlag,
      };
}
