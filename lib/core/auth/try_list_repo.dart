import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../firebase_options.dart'; // <- NOTE: this path (two dots) is correct

/// Simple data model for Try List
class TryItem {
  TryItem({required this.id, required this.name});
  final String id;
  final String name;

  factory TryItem.fromMap(String id, Map<dynamic, dynamic> map) {
    return TryItem(
      id: id,
      name: (map['name'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {'name': name};
}

class TryListRepo {
  TryListRepo({
    FirebaseDatabase? db,
  }) : _db = db ?? _dbForApp();

  final FirebaseDatabase _db;

  static FirebaseDatabase _dbForApp() {
    // Require a FirebaseApp (screen already ensures it, but this is safe)
    final app = Firebase.apps.isNotEmpty
        ? Firebase.apps.first
        : Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ) as FirebaseApp;

    final url = DefaultFirebaseOptions.currentPlatform.databaseURL ??
        'https://similar-eats-default-rtdb.firebaseio.com';
    return FirebaseDatabase.instanceFor(app: app, databaseURL: url);
  }

  DatabaseReference _userRef(String uid) => _db.ref('tryList/$uid');

  /// Live list of items for a user.
  Stream<List<TryItem>> watchItems(String uid) {
    final ref = _userRef(uid);
    return ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return <TryItem>[];
      if (val is Map) {
        final map = Map<dynamic, dynamic>.from(val);
        final items = <TryItem>[];
        map.forEach((k, v) {
          if (v is Map) {
            items.add(TryItem.fromMap(k.toString(), v));
          }
        });
        // Sort newest first (keys are push IDs, sorting desc approximates recency)
        items.sort((a, b) => b.id.compareTo(a.id));
        return items;
      }
      return <TryItem>[];
    });
  }

  /// Add a new item
  Future<void> addItem({required String uid, required String name}) async {
    final ref = _userRef(uid).push();
    await ref.set({'name': name});
  }

  /// Delete by ID
  Future<void> deleteItem({required String uid, required String id}) async {
    await _userRef(uid).child(id).remove();
  }
}
