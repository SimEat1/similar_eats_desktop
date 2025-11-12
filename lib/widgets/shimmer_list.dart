import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Very small dependency-free shimmer list.
/// Usage: const ShimmerList(count: 6)
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemBuilder: (_, __) => const _ShimmerTile(),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: count,
    );
  }
}

class _ShimmerTile extends StatefulWidget {
  const _ShimmerTile();

  @override
  State<_ShimmerTile> createState() => _ShimmerTileState();
}

class _ShimmerTileState extends State<_ShimmerTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = (math.sin((_c.value * 2 * math.pi)) + 1) / 2; // 0..1
        final base = Theme.of(context).colorScheme.surface;
        final hi = Theme.of(context).colorScheme.surfaceContainerHighest;
        final color = Color.lerp(base, hi, 0.35 + t * 0.25)!;

        return Container(
          height: 68,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 10,
                        width: MediaQuery.of(context).size.width * 0.35,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

