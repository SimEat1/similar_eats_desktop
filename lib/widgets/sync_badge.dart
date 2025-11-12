import 'package:flutter/material.dart';

/// A tiny status chip you can show near list headers or in app bars
/// to indicate syncing state and whether items are from cache.
/// For Firestore, pass `isFromCache` from snapshot.metadata.isFromCache
/// and `hasPendingWrites` from snapshot.metadata.hasPendingWrites.
/// For RTDB, pass booleans you manage around writes/stream start.
class SyncBadge extends StatelessWidget {
  const SyncBadge({
    super.key,
    required this.isFromCache,
    required this.hasPendingWrites,
  });

  final bool isFromCache;
  final bool hasPendingWrites;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (hasPendingWrites) {
      label = 'Syncing…';
      color = Colors.amber;
    } else if (isFromCache) {
      label = 'Cached';
      color = Colors.blueGrey;
    } else {
      label = 'Live';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPendingWrites
                ? Icons.sync
                : (isFromCache ? Icons.cloud_off : Icons.cloud_done),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

