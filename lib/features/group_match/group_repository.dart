import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupMember {
  final String uid;
  final double lat;
  final double lng;
  final DateTime updatedAt;
  GroupMember(
      {required this.uid,
      required this.lat,
      required this.lng,
      required this.updatedAt});

  factory GroupMember.fromMap(String uid, Map<String, dynamic> m) =>
      GroupMember(
        uid: uid,
        lat: (m['lat'] as num).toDouble(),
        lng: (m['lng'] as num).toDouble(),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(m['updatedAt'] as int,
                isUtc: true)
            .toLocal(),
      );

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
}

class GroupRepository {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid {
    final u = _auth.currentUser;
    if (u == null) throw StateError('Not signed in');
    return u.uid;
  }

  Future<void> joinGroup(String groupId) async {
    final g = _db.collection('groups').doc(groupId);
    await g.set(
        {'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    // ensure member doc exists
    await g.collection('members').doc(uid).set(
        {'joinedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  Future<void> updatePresence(String groupId,
      {required double lat, required double lng}) async {
    final mref =
        _db.collection('groups').doc(groupId).collection('members').doc(uid);
    await mref.set({
      'lat': lat,
      'lng': lng,
      'updatedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
  }

  Stream<List<GroupMember>> membersStream(String groupId) {
    return _db
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map(
          (qs) => qs.docs
              .where((d) =>
                  d.data().containsKey('lat') && d.data().containsKey('lng'))
              .map((d) => GroupMember.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
