import 'package:flutter/foundation.dart';

/// Minimal controller used by Recommendations and the quiz.
/// - Optional store passed in the constructor
/// - Exposes current
/// - Has init() and submit(...)
class TasteQuizController extends ChangeNotifier {
  final dynamic _store; // can be null or any repo/store with .load() / .save()

  dynamic current;

  TasteQuizController([this._store]);

  Future<void> init() async {
    try {
      if (_store != null && (_store.load is Function)) {
        final loaded = await _store.load();
        if (loaded != null) current = loaded;
      }
    } catch (_) {
      // swallow; UI can proceed without a stored profile
    }
    notifyListeners();
  }

  /// Update the current profile (dynamic to avoid coupling to a specific model)
  void setCurrent(dynamic profile) {
    current = profile;
    notifyListeners();
  }

  /// Accepts either a Map or object with .toJson()
  Future<void> submit(dynamic profile) async {
    current = profile;
    try {
      if (_store != null && (_store.save is Function)) {
        final map = profile is Map<String, dynamic>
            ? profile
            : (profile?.toJson is Function
                ? profile.toJson() as Map<String, dynamic>
                : <String, dynamic>{});
        await _store.save(map);
      }
    } catch (_) {
      // ignore persistence errors in desktop/dev
    }
    notifyListeners();
  }

  /// Optional reset
  Future<void> reset() async {
    current = null;
    notifyListeners();
  }
}
