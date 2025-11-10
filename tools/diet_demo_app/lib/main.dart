import "package:flutter/material.dart";
import "diet_allergy_step.dart";

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    home: const DemoHome(),
    routes: {DietAllergyStep.routeName: (_) => const DietAllergyStep()},
  );
}

class DemoHome extends StatefulWidget {
  const DemoHome({super.key});
  @override
  State<DemoHome> createState() => _DemoHomeState();
}

class _DemoHomeState extends State<DemoHome> {
  Set<String> a = {}, d = {};
  bool h = true;
  @override
  Widget build(BuildContext c) => Scaffold(
    appBar: AppBar(title: const Text("Diet & Allergies Demo")),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          icon: const Icon(Icons.health_and_safety),
          label: const Text("Open Diet & Allergies"),
          onPressed: () async {
            final r = await Navigator.of(c).push<DietAllergyResult>(
              MaterialPageRoute(builder: (_) => const DietAllergyStep()),
            );
            if (r != null) {
              setState(() {
                a = r.allergies;
                d = r.diets;
                h = r.hideMismatches;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        if (a.isNotEmpty || d.isNotEmpty) ...[
          const Text(
            "Your selections:",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...a.map((x) => Chip(label: Text("Allergy: $x"))),
              ...d.map((x) => Chip(label: Text("Diet: $x"))),
              Chip(label: Text(h ? "Hiding mismatches" : "Showing mismatches")),
            ],
          ),
        ] else
          const Text("No selections yet."),
      ],
    ),
  );
}
