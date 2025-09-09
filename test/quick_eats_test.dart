import 'package:flutter_test/flutter_test.dart';
import '../lib/domain/quick_eats.dart';
import '../lib/models/restaurant.dart';

void main() {
  Restaurant r(String id, {bool quick=false, bool late=false}) => Restaurant(
    id: id,
    name: id,
    serviceTags: const [],
    quickServiceFlag: quick,
    openLateFlag: late,
  );

  test('QuickEatsLogic filters quick and late correctly', () {
    final items = [
      r('a', quick: true,  late: false),
      r('b', quick: false, late: true),
      r('c', quick: true,  late: true),
    ];

    final quick = QuickEatsLogic().filterQuick(items);
    final late  = QuickEatsLogic().filterLate(items);

    expect(quick.map((x) => x.id).toList(), ['a','c']);
    expect(late.map((x) => x.id).toList(),  ['b','c']);
  });
}
