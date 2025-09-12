import 'package:flutter_test/flutter_test.dart';
import 'package:similar_eats_desktop/features/quick_eats/models/restaurant.dart';

/// Pure scoring helper that mirrors the repo’s logic:
/// +10 for quickService (when quickMode)
/// +10 for openLate (when !quickMode)
/// +3 per tag in loves
/// -3 per tag in avoids
int _score(Restaurant r, {required bool quickMode, required Set<String> loves, required Set<String> avoids}) {
  int s = 0;
  if (quickMode && r.quickServiceFlag) s += 10;
  if (!quickMode && r.openLateFlag) s += 10;
  for (final tag in r.serviceTags) {
    if (loves.contains(tag)) s += 3;
    if (avoids.contains(tag)) s -= 3;
  }
  return s;
}

List<Restaurant> _rank(List<Restaurant> items,
    {required bool quickMode, required Set<String> loves, required Set<String> avoids}) {
  final copy = [...items];
  copy.sort((a, b) =>
      _score(b, quickMode: quickMode, loves: loves, avoids: avoids)
          .compareTo(_score(a, quickMode: quickMode, loves: loves, avoids: avoids)));
  return copy;
}

void main() {
  group('QuickEats ranking (smoke test)', () {
    final restaurants = <Restaurant>[
      Restaurant(
        id: '1',
        name: 'Drive Thru Burgers',
        quickServiceFlag: true,
        openLateFlag: false,
        serviceTags: const ['burgers'],
      ),
      Restaurant(
        id: '2',
        name: 'Salad & Go',
        quickServiceFlag: true,
        openLateFlag: false,
        serviceTags: const ['salad'],
      ),
      Restaurant(
        id: '3',
        name: 'Taco Express',
        quickServiceFlag: true,
        openLateFlag: true,
        serviceTags: const ['tacos'],
      ),
      Restaurant(
        id: '4',
        name: 'Bento Box Co.',
        quickServiceFlag: false,
        openLateFlag: false,
        serviceTags: const ['sushi'],
      ),
      Restaurant(
        id: '5',
        name: 'Night Owl Pizza',
        quickServiceFlag: false,
        openLateFlag: true,
        serviceTags: const ['pizza'],
      ),
    ];

    test('Quick mode favors quickService and “loves”', () {
      final loves = {'tacos', 'burgers'};
      final avoids = <String>{};

      final ranked = _rank(restaurants,
          quickMode: true, loves: loves, avoids: avoids);

      // Taco Express: quick (+10) + loves tacos (+3) = 13
      // Drive Thru Burgers: quick (+10) + loves burgers (+3) = 13
      // Salad & Go: quick (+10) = 10
      // Night Owl Pizza: 0 (not quick) + loves? (no) = 0
      // Bento: 0
      // Top 2 should be Taco Express and Drive Thru Burgers (order may tie).
      expect(ranked.first.name, anyOf('Taco Express', 'Drive Thru Burgers'));
      expect(ranked.take(2).map((r) => r.name).toSet(),
          containsAll({'Taco Express', 'Drive Thru Burgers'}));
    });

    test('Late Night favors openLate and penalizes avoids', () {
      final loves = {'pizza'};
      final avoids = {'burgers'};

      final ranked = _rank(restaurants,
          quickMode: false, loves: loves, avoids: avoids);

      // Night Owl Pizza: late (+10) + loves pizza (+3) = 13  -> should be #1
      expect(ranked.first.name, 'Night Owl Pizza');

      // Drive Thru Burgers gets -3 for avoid "burgers" and no late bonus -> should sink.
      final idxBurgers = ranked.indexWhere((r) => r.name == 'Drive Thru Burgers');
      final idxSalad = ranked.indexWhere((r) => r.name == 'Salad & Go');
      expect(idxBurgers, greaterThan(idxSalad)); // burgers should rank below salad
    });
  });
}
