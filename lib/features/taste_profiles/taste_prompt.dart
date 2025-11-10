import 'dart:math' as math;
import 'package:firebase_database/firebase_database.dart';

final _rnd = math.Random();

String randomPrompt() {
  const prompts = [
    'What are you in the mood for?',
    'What do you want to eat?',
    'Feeling… BBQ, tacos, or something new?',
    'Hungry? Let’s find something fast.',
  ];
  return prompts[_rnd.nextInt(prompts.length)];
}

Future<List<String>> topChipsForUser(String uid) async {
  final db = FirebaseDatabase.instance;
  final likesSnap = await db.ref('userTaste//likedCuisines').get();
  final avoidsSnap = await db.ref('userTaste//avoidTags').get();

  final likes = <String>[];
  if (likesSnap.exists && likesSnap.value != null) {
    final v = likesSnap.value;
    if (v is List) {
      likes.addAll(v.whereType<String>());
    } else if (v is Map) {
      likes.addAll((v).values.whereType<String>());
    }
  }

  final avoids = <String>[];
  if (avoidsSnap.exists && avoidsSnap.value != null) {
    final v = avoidsSnap.value;
    if (v is List) {
      avoids.addAll(v.whereType<String>());
    } else if (v is Map) {
      avoids.addAll((v).values.whereType<String>());
    }
  }

  if (likes.isEmpty) {
    likes.addAll(['bbq', 'tacos', 'pizza', 'ramen']);
  }
  likes.removeWhere((x) => avoids.contains(x));
  return likes.take(6).toList();
}
