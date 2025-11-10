import 'package:meta/meta.dart';

@immutable
class TryItem {
  const TryItem({
    required this.id,
    required this.name,
    required this.addedAtMs,
    required this.done,
  });

  final String id;
  final String name;
  final int addedAtMs;
  final bool done;

  TryItem copyWith({
    String? id,
    String? name,
    int? addedAtMs,
    bool? done,
  }) {
    return TryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      addedAtMs: addedAtMs ?? this.addedAtMs,
      done: done ?? this.done,
    );
  }

  Map<String, Object?> toMap() => {
        'name': name,
        'addedAtMs': addedAtMs,
        'done': done,
      };

  factory TryItem.fromRTDB(String id, Map value) {
    return TryItem(
      id: id,
      name: (value['name'] ?? '') as String,
      addedAtMs: (value['addedAtMs'] ?? 0) as int,
      done: (value['done'] ?? false) as bool,
    );
  }
}
