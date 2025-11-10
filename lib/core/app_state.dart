import 'package:flutter/foundation.dart';

/// Global, lightweight app state (no extra packages).
class AppState {
  AppState._();
  static final AppState instance = AppState._();

  /// Categories the user is currently craving (e.g., {'Chicken','Pizza'})
  final ValueNotifier<Set<String>> selectedCategories =
      ValueNotifier<Set<String>>({});
}
