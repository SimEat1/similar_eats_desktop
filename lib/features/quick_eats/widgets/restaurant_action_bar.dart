import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:similar_eats_desktop/features/taste_profiles/taste_events.dart';

/// A compact action row shown under each restaurant card:
/// 👍 like, 👎 dislike, 🌶️ spice feedback, 💵 price comfort.
/// Each tap logs an event and applies an adaptive update.
class RestaurantActionBar extends StatelessWidget {
  final String restaurantId;

  /// If you have a primary cuisine/tag for this restaurant, pass it
  /// (e.g. 'bbq', 'tacos'). Used for like/dislike tag actions.
  final String? primaryTag;

  /// Whether the list is currently in “Quick” mode (vs “Late Night”).
  final bool quickMode;

  const RestaurantActionBar({
    super.key,
    required this.restaurantId,
    this.primaryTag,
    this.quickMode = true,
  });

  Future<void> _logAndAdapt({
    required String type,
    required String value,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1) analytics / history
    await TasteEvents.log(
      uid: uid,
      type: type,
      value: value,
      context: {
        'restaurantId': restaurantId,
        'mode': quickMode ? 'quick' : 'late',
      },
    );

    // 2) adaptive profile update
    await TasteAdaptiveUpdater().apply(
      uid: uid,
      type: type,
      value: value,
    );
  }

  Future<void> _pickPriceComfort(BuildContext context) async {
    // Simple bottom sheet for $/$$/$$$/$$$$
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'What price feels comfortable here?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              _PriceRow(
                label: r'$',
                value: '1',
                onTap: () => Navigator.pop(ctx, '1'),
              ),
              _PriceRow(
                label: r'$$',
                value: '2',
                onTap: () => Navigator.pop(ctx, '2'),
              ),
              _PriceRow(
                label: r'$$$',
                value: '3',
                onTap: () => Navigator.pop(ctx, '3'),
              ),
              _PriceRow(
                label: r'$$$$',
                value: '4',
                onTap: () => Navigator.pop(ctx, '4'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (choice != null) {
      await _logAndAdapt(type: 'price_feedback', value: choice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = (primaryTag ?? '').trim().toLowerCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionIcon(
          icon: Icons.thumb_up_alt_outlined,
          label: 'Like',
          tooltip: tag.isEmpty ? 'Like this place' : 'Like $tag',
          onTap: () async {
            if (tag.isNotEmpty) {
              await _logAndAdapt(type: 'like_tag', value: tag);
            } else {
              // Fallback: generic like
              await _logAndAdapt(type: 'like_place', value: restaurantId);
            }
            _toast(context, 'Saved 👍');
          },
        ),
        _ActionIcon(
          icon: Icons.thumb_down_alt_outlined,
          label: 'Skip',
          tooltip: tag.isEmpty ? 'Dislike this place' : 'Dislike $tag',
          onTap: () async {
            if (tag.isNotEmpty) {
              await _logAndAdapt(type: 'dislike_tag', value: tag);
            } else {
              await _logAndAdapt(type: 'dislike_place', value: restaurantId);
            }
            _toast(context, 'Noted 👎');
          },
        ),
        _ActionIcon(
          icon: Icons.local_fire_department_outlined,
          label: 'Spicy',
          tooltip: 'Too spicy',
          onTap: () async {
            await _logAndAdapt(type: 'spice_feedback', value: 'too_spicy');
            _toast(context, 'We’ll ease the heat 🌶️');
          },
        ),
        _ActionIcon(
          icon: Icons.attach_money,
          label: 'Price',
          tooltip: 'Set price comfort',
          onTap: () => _pickPriceComfort(context),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.label,
    this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );

    return tooltip == null
        ? btn
        : Tooltip(
            message: tooltip!,
            waitDuration: const Duration(milliseconds: 250),
            child: btn);
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.attach_money_outlined),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
