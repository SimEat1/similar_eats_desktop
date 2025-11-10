import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:similar_eats_desktop/features/favorites/data/favorites_store.dart';
import 'package:similar_eats_desktop/features/favorites/presentation/favorites_controller.dart';
import 'package:similar_eats_desktop/features/try_list/data/try_list_store.dart';
import 'package:similar_eats_desktop/features/try_list/presentation/try_list_controller.dart';

import 'package:similar_eats_desktop/features/taste_quiz/presentation/taste_quiz_controller.dart';
import 'package:similar_eats_desktop/features/taste_profiles/repo/taste_profiles_repo.dart';

Widget withAppProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => TasteQuizController()..init()),
      ChangeNotifierProvider(
          create: (_) => TasteQuizController(TasteProfilesRepo())..init()),
      ChangeNotifierProvider(
          create: (_) => FavoritesController(FavoritesStore())..init()),
      ChangeNotifierProvider(
          create: (_) => TryListController(TryListStore())..init()),
    ],
    child: child,
  );
}
