import 'package:flutter/foundation.dart';
import 'package:similar_eats_desktop/features/favorites/data/favorites_store.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesStore _store;
  FavoritesController(this._store);

  Set<String> ids = {};

  Future<void> init() async {
    ids = await _store.loadIds();
    notifyListeners();
  }

  bool isFavorite(String id) => ids.contains(id);

  Future<void> toggle(String id) async {
    ids = await _store.toggle(id);
    notifyListeners();
  }
}
