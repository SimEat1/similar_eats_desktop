import "package:flutter/material.dart";
import 'package:similar_eats_desktop/shared/ui/tokens.dart';
import 'package:similar_eats_desktop/shared/ui/responsive.dart';

class ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppSizes.iconLg(context);
    final elev = _hover ? AppTokens.elevationHover : AppTokens.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Card(
        elevation: elev,
        shape: const RoundedRectangleBorder(borderRadius: AppTokens.cardRadius),
        child: InkWell(
          borderRadius: AppTokens.cardRadius,
          onTap: widget.onTap,
          child: Padding(
            padding: AppTokens.cardPadding,
            child: Row(
              children: [
                Icon(widget.icon, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}