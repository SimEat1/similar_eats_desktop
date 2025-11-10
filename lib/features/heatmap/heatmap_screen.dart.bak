import 'dart:math';
import 'package:flutter/foundation.dart'; // <-- this provides ValueListenable
import 'package:flutter/material.dart';

class HeatmapScreen extends StatelessWidget {
  static const route = '/heatmap';

  /// Reads the chosen categories from the chooser screen.
  final ValueListenable<Set<String>> selection;

  const HeatmapScreen({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("What's for dinner?")),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: selection,
        builder: (context, selected, _) {
          return CustomPaint(
            painter: _HeatPainter(selected),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _HeatPainter extends CustomPainter {
  final Set<String> selected;
  _HeatPainter(this.selected);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);

    // Simple category→color map; blended when multiple are selected.
    final catColors = <String, Color>{
      'Chicken': Colors.deepOrange,
      'Pizza': Colors.redAccent,
      'Burgers': Colors.amber,
      'Dessert': Colors.pinkAccent,
      'Tacos': Colors.lime,
      'Salad': Colors.greenAccent,
      'Drinks': Colors.cyanAccent,
    };

    Color base = Colors.orange;
    for (final s in selected) {
      final c = catColors[s];
      if (c != null) base = Color.alphaBlend(c.withOpacity(.6), base);
    }

    final centers = List.generate(
      9,
      (_) =>
          Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * size.height),
    );

    for (final c in centers) {
      for (var i = 4; i >= 1; i--) {
        final paint = Paint()
          ..color = base.withOpacity(0.08 * i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
        canvas.drawCircle(c, 60.0 * i, paint);
      }
      canvas.drawCircle(c, 10, Paint()..color = base);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatPainter oldDelegate) =>
      !setEquals(oldDelegate.selected, selected);
}
