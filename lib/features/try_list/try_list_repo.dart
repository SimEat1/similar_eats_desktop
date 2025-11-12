import 'package:cloud_firestore/cloud_firestore.dart';

/// Simple data model we use on the UI.
class TryItem {
  final String id;
  final String name;
  /// Stored as millis since epoch for simplicity in UI.
  final int? createdAtMillis;

  TryItem({
    required this.id,
    required this.name,
    required this.createdAtMillis,
  });

  factory TryItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final ts = data['createdAt'] as Timestamp?;
    final millis = ts?.millisecondsSinceEpoch ?? data['createdAtMillis'] as int?;
    return TryItem(
      id: doc.id,
      name: (data['name'] as String?)?.trim() ?? '',
      createdAtMillis: millis,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        // prefer server timestamp, but keep a plain millis for safety too
        'createdAt': FieldValue.serverTimestamp(),
        'createdAtMillis': createdAtMillis,
      };
}

/// View object that carries both list and Firestore metadata needed by the UI.
class TryListView {
  final List<TryItem> items;
  final bool isFromCache;
  final bool hasPendingWrites;
  final DateTime lastSnapshotAt;

  const TryListView({
    required this.items,
    required this.isFromCache,
    required this.hasPendingWrites,
    required this.lastSnapshotAt,
  });
}

class TryListRepo {
  CollectionReference<Map<String, dynamic>> _userCol() =>
      FirebaseFirestore.instance.collection('users');

  CollectionReference<Map<String, dynamic>> _listCol(String uid) =>
      _userCol().doc(uid).collection('tryList');

  /// Add an item.
  Future<void> addItem({required String uid, required String name}) async {
    await _listCol(uid).add({
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'createdAtMillis': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Delete an item by document id.
  Future<void> deleteItem({required String uid, required String id}) async {
    await _listCol(uid).doc(id).delete();
  }

  /// Old “simple list” stream (kept for reference/compat).
  Stream<List<TryItem>> watchItems(String uid) {
    return _listCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TryItem.fromDoc).toList());
  }

  /// New stream with **metadata** for SyncBadge.
  Stream<TryListView> watchItemsWithMeta(String uid) {
    return _listCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map(TryItem.fromDoc).toList();
      final meta = snap.metadata;
      return TryListView(
        items: items,
        isFromCache: meta.isFromCache,
        hasPendingWrites: meta.hasPendingWrites,
        lastSnapshotAt: DateTime.now(),
      );
    });
  }
}
