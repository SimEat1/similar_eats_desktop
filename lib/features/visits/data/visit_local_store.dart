import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VisitLocalStore {
  static const _k = 'visits_local_v1';

  Future<void> save(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? <String>[];
    list.add(jsonEncode(data));
    await sp.setStringList(_k, list);
  }

  Future<List<Map<String, dynamic>>> all() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? <String>[];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }
}
