import 'package:flutter/material.dart';

/// A tiny DTO so we don’t couple this helper to your UI/state classes.
class QuizResult {
  final List<String> flavors;
  final List<String> cuisines;
  final String? budget;

  /// If you eventually allow multiple diets, keep a list here. For now we keep one.
  final String? diet;
  final List<String> allergies;

  const QuizResult({
    required this.flavors,
    required this.cuisines,
    required this.budget,
    required this.diet,
    required this.allergies,
  });

  Map<String, dynamic> toJson() => {
        'flavors': flavors,
        'cuisines': cuisines,
        'budget': budget,
        'diet': diet,
        'allergies': allergies,
      };
}

/// Saves your selections (plug in your own persistence) then navigates.
/// If [nextRoute] is provided, it clears the stack and goes there.
/// Otherwise it just pops the quiz.
Future<void> finishTasteQuiz(
  BuildContext context,
  QuizResult result, {
  String? nextRoute,
}) async {
  // TODO: Replace this with your own save logic (e.g., Firestore).
  debugPrint('TasteQuiz result: ${result.toJson()}');

  if (nextRoute != null && nextRoute.isNotEmpty) {
    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (r) => false);
  } else if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop(result);
  } else {
    // Stay put; maybe show a toast if nothing navigated.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved')),
    );
  }
}
