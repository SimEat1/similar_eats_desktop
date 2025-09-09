import '../models/restaurant.dart';

class QuickEatsLogic {
  List<Restaurant> filterQuick(List<Restaurant> all) =>
      all.where((r) => r.quickServiceFlag).toList();

  List<Restaurant> filterLate(List<Restaurant> all) =>
      all.where((r) => r.openLateFlag).toList();
}
