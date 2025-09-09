import 'package:flutter/foundation.dart';

class AppState {
  AppState._();
  static final AppState instance = AppState._();

  /// Categories the user is currently craving (e.g., {'Chicken','Pizza'})
  final ValueNotifier<Set<String>> selectedCategories =
      ValueNotifier<Set<String>>({});
}
