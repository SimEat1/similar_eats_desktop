import 'package:cloud_firestore/cloud_firestore.dart';

class VisitLogRepository {
  Future<void> updateVisit(String id, Map<String, dynamic> patch) async {
    final data = {
      ...patch,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await FirebaseFirestore.instance.collection('visits').doc(id).update(data);
  }

  const VisitLogRepository();

  Future<void> addQuickVisit(Map<String, dynamic> payload) async {
    final data = {
      ...payload,
      'created_at': (payload['created_at'] as String?) ??
          DateTime.now().toIso8601String(),
    };
    await FirebaseFirestore.instance.collection('visits').add(data);
  }
}
