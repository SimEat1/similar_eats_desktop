import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:similar_eats_desktop/features/taste_profile/taste_quiz_save.dart';
import 'package:similar_eats_desktop/features/taste_profile/screens/diet_allergy_screen.dart';

class TasteQuizScreen extends StatefulWidget {
  static const routeName = "/taste_quiz";
  const TasteQuizScreen({super.key});

  @override
  State<TasteQuizScreen> createState() => _TasteQuizScreenState();
}

class _TasteQuizScreenState extends State<TasteQuizScreen> {
  /// Simple multiple-choice model. All questions optional.
  final List<_Q> _questions = [
    const _Q(
      id: 'noodle',
      title: 'Noodle mood',
      subtitle: 'Your go-to carb hug',
      options: [
        'Springy ramen',
        'Silky rice noodles',
        'Chewy udon',
        'Hearty pasta', // NEW
        'No noodles for me',
        'None of the above / Skip', // keep Skip in every block
      ],
    ),
    const _Q(
      id: 'comfort',
      title: 'Comfort dinner',
      subtitle: 'Pick the most satisfying plate',
      options: [
        'Burger + fries',
        'Ramen or pho, rich broth',
        'Buffalo wings + ranch',
        'Stir-fry with savory sauce',
        'None of the above / Skip',
      ],
    ),
    const _Q(
      id: 'zing',
      title: 'Love tangy sauces & pickles',
      subtitle: null,
      options: [
        'Gimme all the zing',
        'Sometimes',
        'Not my thing',
        'None of the above / Skip',
      ],
    ),
  ];

  final Map<String, String?> _answers = {};

  Future<void> _save() async {
    // transform answers into a tiny fixed-length vector for now (demo)
    // you can adjust weights later; unanswered = 0
    final List<double> vec = List<double>.filled(5, 0);
    // very rough demo scoring
    void add(double i0, double i1, double i2, double i3, double i4) {
      vec[0] += i0;
      vec[1] += i1;
      vec[2] += i2;
      vec[3] += i3;
      vec[4] += i4;
    }

    switch (_answers['noodle']) {
      case 'Springy ramen':
        add(0, 1, 0, 1, 0.2);
        break;
      case 'Silky rice noodles':
        add(0, 0.8, 0.2, 0.8, 0.2);
        break;
      case 'Chewy udon':
        add(0.1, 0.8, 0, 0.6, 0.1);
        break;
      case 'Hearty pasta':
        add(0.6, 0.2, 0.1, 0.1, 0.2);
        break;
      case 'No noodles for me':
        add(0, 0, 0, 0, 0);
        break;
    }

    switch (_answers['comfort']) {
      case 'Burger + fries':
        add(0.7, 0, 0, 0.2, 0.2);
        break;
      case 'Ramen or pho, rich broth':
        add(0, 0.8, 0.1, 0.7, 0.2);
        break;
      case 'Buffalo wings + ranch':
        add(0.2, 0, 0, 0.8, 0.2);
        break;
      case 'Stir-fry with savory sauce':
        add(0.2, 0.2, 0.2, 0.2, 0.7);
        break;
    }

    switch (_answers['zing']) {
      case 'Gimme all the zing':
        add(0, 0.2, 0.7, 0, 0.1);
        break;
      case 'Sometimes':
        add(0, 0.1, 0.3, 0, 0.1);
        break;
      case 'Not my thing':
        add(0.2, 0, 0, 0.1, 0);
        break;
    }

    await TasteQuizSaver().saveBoth(TasteVector(vec));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Saved! We’ll refine your profile over time.')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Taste Quiz'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _questions.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // quick link to Diet & allergies
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.health_and_safety_outlined),
                      label: const Text('Diet & allergies'),
                      onPressed: () =>
                          Navigator.pushNamed(context, DietAllergyScreen.route),
                    ),
                  );
                }
                final q = _questions[index - 1];
                return _QuestionCard(
                  q: q,
                  value: _answers[q.id],
                  onChanged: (v) => setState(() => _answers[q.id] = v),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Save my taste profile'),
              onPressed: _save, // always enabled (skips allowed)
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Psst… this is v1 of your taste profile. We’ll refine it over time with your ratings, receipts, and quick-visit logs. You can retake the quiz anytime. Skip what doesn’t fit — that keeps your profile accurate.",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _Q {
  final String id;
  final String title;
  final String? subtitle;
  final List<String> options;
  const _Q(
      {required this.id,
      required this.title,
      this.subtitle,
      required this.options});
}

class _QuestionCard extends StatelessWidget {
  final _Q q;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _QuestionCard(
      {required this.q, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.title, style: theme.textTheme.titleMedium),
            if (q.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(q.subtitle!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            for (final opt in q.options)
              RadioListTile<String>(
                dense: true,
                title: Text(opt),
                value: opt,
                groupValue: value,
                onChanged: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}
