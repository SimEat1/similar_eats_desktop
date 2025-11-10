import "dart:typed_data";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';

class ReceiptsRepository {
  final _db = FirebaseFirestore.instance;
  final _st = FirebaseStorage.instance;

  String? get _uid => PlatformHelper.getCurrentUid(
      firebaseUid: FirebaseAuth.instance.currentUser?.uid);

  Future<String?> addReceipt({
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    required Uint8List data,
    required int amountCents,
    String currency = "USD",
    String? restaurantName,
    String? notes,
    List<String> tags = const [],
    DateTime? purchaseAt,
  }) async {
    final uid = _uid;
    if (uid == null) return null;

    final doc = _db.collection("users").doc(uid).collection("receipts").doc();
    final path = "users/$uid/receipts/${doc.id}/$fileName";

    // upload file first
    final meta = SettableMetadata(contentType: mimeType);
    await _st.ref(path).putData(data, meta);

    await doc.set({
      "amountCents": amountCents,
      "currency": currency,
      "restaurantName": restaurantName,
      "notes": notes,
      "tags": tags,
      "sizeBytes": sizeBytes,
      "fileName": fileName,
      "mimeType": mimeType,
      "storagePath": path,
      "purchaseAt": purchaseAt ?? DateTime.now(),
      "createdAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }
}
