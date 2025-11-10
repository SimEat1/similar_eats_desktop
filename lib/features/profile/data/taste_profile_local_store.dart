import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TasteProfileLocalStore {
  static const _k = 'taste_profile_v1';

  Future<void> save(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_k);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k);
  }
}
