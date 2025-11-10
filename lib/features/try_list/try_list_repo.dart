import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:similar_eats_desktop/firebase_options.dart'
    as fo; // lib/firebase_options.dart

/// Simple model for a Try List entry.
class TryItem {
  final String id;
  final String name;
  final DateTime? createdAt;

  TryItem({
    required this.id,
    required this.name,
    this.createdAt,
  });

  factory TryItem.fromMap(String id, Map<dynamic, dynamic> map) {
    final ts = map['createdAt'];
    DateTime? dt;
    if (ts is int) {
      // store millisecondsSinceEpoch
      dt = DateTime.fromMillisecondsSinceEpoch(ts);
    }
    return TryItem(
      id: id,
      name: (map['name'] ?? '') as String,
      createdAt: dt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
    };
  }
}

class TryListRepo {
  TryListRepo({FirebaseDatabase? db}) : _db = db ?? _dbForOptions();

  final FirebaseDatabase _db;

  static FirebaseDatabase _dbForOptions() {
    // Ensure we target your project’s RTDB URL explicitly.
    final url = fo.DefaultFirebaseOptions.currentPlatform.databaseURL ??
        'https://similar-eats-default-rtdb.firebaseio.com';
    // Need to pass the Firebase app for web/desktop
    final app = Firebase.apps.isNotEmpty
        ? Firebase.apps.first
        : Firebase.app(); // throws if not initialized
    return FirebaseDatabase.instanceFor(app: app, databaseURL: url);
  }

  DatabaseReference _userRoot(String uid) => _db.ref('userTryList').child(uid);

  /// Live stream of items for a user.
  Stream<List<TryItem>> watchItems(String uid) {
    final ref = _userRoot(uid);
    // Order by createdAt so newest appear last (stable ordering)
    final q = ref.orderByChild('createdAt');
    return q.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <TryItem>[];
      final map = Map<dynamic, dynamic>.from(data);
      final list = <TryItem>[];
      map.forEach((key, value) {
        if (value is Map) {
          list.add(TryItem.fromMap(
              key.toString(), Map<dynamic, dynamic>.from(value)));
        }
      });
      // already ordered by createdAt; keep
      return list;
    });
  }

  /// Add a new item.
  Future<void> addItem({required String uid, required String name}) async {
    final ref = _userRoot(uid).push();
    await ref.set(
        TryItem(id: ref.key!, name: name, createdAt: DateTime.now()).toMap());
  }

  /// Delete an item by its generated id.
  Future<void> deleteItem({required String uid, required String id}) async {
    await _userRoot(uid).child(id).remove();
  }
}
