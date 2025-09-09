import 'package:firebase_database/firebase_database.dart';

class TryListRepo {
  TryListRepo({FirebaseDatabase? db}) : _db = db ?? FirebaseDatabase.instance;
  final FirebaseDatabase _db;

  Future<void> toggle(String uid, String restaurantId, bool add) async {
    final ref = _db.ref('userTryList/$uid/$restaurantId');
    if (add) {
      await ref.set(true);
    } else {
      await ref.remove();
    }
  }

  Future<Map<String, bool>> load(String uid) async {
    final snap = await _db.ref('userTryList/$uid').get();
    if (!snap.exists || snap.value is! Map) return {};
    final m = Map<String, dynamic>.from(snap.value as Map);
    return m.map((k, v) => MapEntry(k, v == true));
  }
}
