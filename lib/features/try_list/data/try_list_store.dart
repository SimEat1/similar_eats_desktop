import 'package:shared_preferences/shared_preferences.dart';

class TryListStore {
  static const _k = 'trylist_ids_v1';

  Future<Set<String>> loadIds() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? const [];
    return list.toSet();
  }

  Future<void> _saveIds(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_k, ids.toList());
  }

  Future<Set<String>> toggle(String id) async {
    final ids = await loadIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await _saveIds(ids);
    return ids;
  }
}
