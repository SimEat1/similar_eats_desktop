/// lib/features/group_match/fry_hints.dart
/// Tiny helper for per-user menu suggestions (category = "fries" here),
/// but you can reuse for other categories by changing tags.
library;

class MicroPrefs {
  final Set<String> like;
  final Set<String> dislike;
  const MicroPrefs({required this.like, required this.dislike});
}

class UserProfileLite {
  final String id;
  final String name;
  final Map<String, MicroPrefs> categories; // key: category (e.g. "fries")
  const UserProfileLite(
      {required this.id, required this.name, required this.categories});
}

class MenuItemLite {
  final String id;
  final String name;
  final String category; // e.g. "fries"
  final Set<String> tags; // e.g. {"fries","crispy","crinkle"}
  const MenuItemLite(
      {required this.id,
      required this.name,
      required this.category,
      required this.tags});
}

class UserItemScore {
  final String userId;
  final String userName;
  final MenuItemLite item;
  final double score; // 0..1
  final bool avoid;
  const UserItemScore(
      {required this.userId,
      required this.userName,
      required this.item,
      required this.score,
      required this.avoid});
}

UserItemScore scoreItemForUser(
    {required UserProfileLite user, required MenuItemLite item}) {
  final prefs = user.categories[item.category];
  if (prefs == null) {
    return UserItemScore(
        userId: user.id,
        userName: user.name,
        item: item,
        score: 0,
        avoid: false);
  }
  final itemTags = item.tags.map((e) => e.toLowerCase()).toSet();

  // Hard conflict on any disliked tag
  final hasConflict = prefs.dislike.isNotEmpty &&
      prefs.dislike
          .map((e) => e.toLowerCase())
          .toSet()
          .intersection(itemTags)
          .isNotEmpty;
  if (hasConflict) {
    return UserItemScore(
        userId: user.id,
        userName: user.name,
        item: item,
        score: 0,
        avoid: true);
  }

  // Like overlap fraction
  if (prefs.like.isEmpty) {
    return UserItemScore(
        userId: user.id,
        userName: user.name,
        item: item,
        score: 0.0,
        avoid: false);
  }
  final likeSet = prefs.like.map((e) => e.toLowerCase()).toSet();
  final likeFrac = likeSet.intersection(itemTags).length / likeSet.length;
  return UserItemScore(
      userId: user.id,
      userName: user.name,
      item: item,
      score: likeFrac,
      avoid: false);
}

Map<UserProfileLite, List<UserItemScore>> topPicksPerUser({
  required String category,
  required List<UserProfileLite> users,
  required List<MenuItemLite> menu,
  int perUser = 2,
  double minScore = 0.15,
}) {
  final items = menu.where((m) => m.category == category).toList();
  final out = <UserProfileLite, List<UserItemScore>>{};
  for (final u in users) {
    final scored = <UserItemScore>[
      for (final it in items) scoreItemForUser(user: u, item: it),
    ]
      ..removeWhere((s) => s.avoid || s.score < minScore)
      ..sort((a, b) => b.score.compareTo(a.score));
    out[u] = scored.take(perUser).toList();
  }
  return out;
}

List<MenuItemLite> itemsEveryoneLikes({
  required String category,
  required List<UserProfileLite> users,
  required List<MenuItemLite> menu,
  double threshold = 0.25,
}) {
  final items = menu.where((m) => m.category == category).toList();
  final likedByAll = <MenuItemLite>[];
  for (final it in items) {
    var okForAll = true;
    for (final u in users) {
      final s = scoreItemForUser(user: u, item: it);
      if (s.avoid || s.score < threshold) {
        okForAll = false;
        break;
      }
    }
    if (okForAll) likedByAll.add(it);
  }
  return likedByAll;
}

String shortHint(UserItemScore s) {
  if (s.avoid) return "Avoid ${s.item.name}";
  final tags =
      s.item.tags.where((t) => t.toLowerCase() != "fries").take(3).join(", ");
  return tags.isEmpty ? s.item.name : "${s.item.name} ($tags)";
}
