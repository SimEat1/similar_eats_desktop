import 'package:flutter/foundation.dart';
import 'package:similar_eats_desktop/features/try_list/data/try_list_store.dart';

class TryListController extends ChangeNotifier {
  final TryListStore _store;
  TryListController(this._store);

  Set<String> ids = {};

  Future<void> init() async {
    ids = await _store.loadIds();
    notifyListeners();
  }

  bool contains(String id) => ids.contains(id);

  Future<void> toggle(String id) async {
    ids = await _store.toggle(id);
    notifyListeners();
  }
}
