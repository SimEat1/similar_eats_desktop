import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/features/receipts/rate_unlinked_items_screen.dart';

/// Shows a small card on Home when there are receipt items without visit_id.
class RateLaterBanner extends StatelessWidget {
  const RateLaterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    // We query a collectionGroup('items') filtered by owner_uid.
    final q = FirebaseFirestore.instance
        .collectionGroup('items')
        .where('owner_uid', isEqualTo: uid)
        .where('visit_id', isNull: true)
        .limit(30); // keep it light

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return const SizedBox.shrink();
        if (!snap.hasData) return const SizedBox.shrink();

        final count = snap.data!.docs.length;
        if (count == 0) return const SizedBox.shrink();

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ListTile(
            leading: const Icon(Icons.rate_review),
            title: Text('You have $count item${count == 1 ? "" : "s"} to rate'),
            subtitle: const Text('Turn receipt lines into visits with ratings'),
            trailing: FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, RateUnlinkedItemsScreen.route);
              },
              child: const Text('Review'),
            ),
          ),
        );
      },
    );
  }
}


