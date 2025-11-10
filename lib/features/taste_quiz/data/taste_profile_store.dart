import 'package:shared_preferences/shared_preferences.dart';
import 'package:similar_eats_desktop/features/taste_quiz/domain/taste_profile.dart';

class TasteProfileStore {
  static const _k = 'taste_profile_v1';

  Future<TasteProfile?> load() async {
    final sp = await SharedPreferences.getInstance();
    final d = sp.getStringList(_k);
    if (d == null || d.length != 5) return null;
    return TasteProfile(
      sweet: double.parse(d[0]),
      salty: double.parse(d[1]),
      sour: double.parse(d[2]),
      spicy: double.parse(d[3]),
      umami: double.parse(d[4]),
    );
  }

  Future<void> save(TasteProfile p) async {
    final sp = await SharedPreferences.getInstance();
    final v = p.normalized();
    await sp.setStringList(_k, [
      v.sweet.toString(),
      v.salty.toString(),
      v.sour.toString(),
      v.spicy.toString(),
      v.umami.toString(),
    ]);
  }
}
