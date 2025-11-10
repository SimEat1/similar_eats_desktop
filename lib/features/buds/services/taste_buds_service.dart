import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasteBudsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Friend doc under owner: /users/{uid}/buds/{friendUid}
  DocumentReference<Map<String, dynamic>> _budDoc(
          String ownerUid, String friendUid) =>
      _db.collection('users').doc(ownerUid).collection('buds').doc(friendUid);

  // Public taste vector: /public_taste/{uid}
  DocumentReference<Map<String, dynamic>> _publicTasteDoc(String uid) =>
      _db.collection('public_taste').doc(uid);

  /// Add a friend (taste bud) by UID. Optional alias.
  Future<void> addBud({required String friendUid, String? alias}) async {
    final me = _uid;
    if (me == null) throw Exception('Not signed in');
    if (friendUid == me) throw Exception("Can't add yourself");

    await _budDoc(me, friendUid).set({
      'since': FieldValue.serverTimestamp(),
      'alias': alias,
    }, SetOptions(merge: true));
  }

  /// Remove a friend
  Future<void> removeBud({required String friendUid}) async {
    final me = _uid;
    if (me == null) throw Exception('Not signed in');
    await _budDoc(me, friendUid).delete();
  }

  /// Stream of my buds
  Stream<List<BudLink>> budsStream() {
    final me = _uid;
    if (me == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(me)
        .collection('buds')
        .orderBy('since', descending: true)
        .snapshots()
        .map((qs) =>
            qs.docs.map((d) => BudLink.fromDoc(d.id, d.data())).toList());
  }

  /// Reads a public taste vector for any uid
  Future<List<double>?> readPublicVector(String uid) async {
    final snap = await _publicTasteDoc(uid).get();
    if (!snap.exists) return null;
    final v = (snap.data()?['vector'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList();
    return v;
  }

  /// Cosine similarity in [0,1]
  double cosine(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;
    double dot = 0, na = 0, nb = 0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0.0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }
}

class BudLink {
  final String friendUid;
  final String? alias;
  final DateTime? since;

  BudLink({required this.friendUid, this.alias, this.since});

  factory BudLink.fromDoc(String id, Map<String, dynamic> data) {
    return BudLink(
      friendUid: id,
      alias: data['alias'] as String?,
      since: (data['since'] is Timestamp)
          ? (data['since'] as Timestamp).toDate()
          : null,
    );
  }
}
