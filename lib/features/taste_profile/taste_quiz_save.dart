import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

/// Minimal taste vector model: keep it fixed-length & numeric.
class TasteVector {
  final List<double> values; // e.g., [sweet, salty, sour, spicy, umami]
  const TasteVector(this.values);

  Map<String, dynamic> toPrivateDoc() => {
        "vector": values,
        "updatedAt": FieldValue.serverTimestamp(),
        "schema": "v1",
      };

  Map<String, dynamic> toPublicDoc() => {
        "vector": values,
        "updatedAt": FieldValue.serverTimestamp(),
        "schema": "v1",
      };
}

class TasteQuizSaver {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser?.uid;
    if (u == null || u.isEmpty) {
      throw Exception("Not signed in");
    }
    return u;
  }

  /// Saves to:
  ///  - /userTaste/{uid}      (owner-only)
  ///  - /public_taste/{uid}   (readable by signed-in users)
  Future<void> saveBoth(TasteVector v) async {
    final uid = _uid;
    final batch = _db.batch();

    final privateRef = _db.collection("userTaste").doc(uid);
    final publicRef  = _db.collection("public_taste").doc(uid);

    batch.set(privateRef, v.toPrivateDoc(), SetOptions(merge: true));
    batch.set(publicRef,  v.toPublicDoc(),  SetOptions(merge: true));

    await batch.commit();
  }

  /// Store diet/allergy preferences in a single document.
  /// Path: /userPrefs/{uid}
  Future<void> savePrefs(Map<String, dynamic> prefs) async {
    final uid = _uid;
    final ref = _db.collection('userPrefs').doc(uid);
    await ref.set(prefs, SetOptions(merge: true));
  }
}


