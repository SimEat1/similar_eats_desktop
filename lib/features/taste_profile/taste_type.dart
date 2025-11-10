import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Very light “taste type” logic (MVP):
/// - Reads /public_taste/{uid}
/// - If the doc already has a `types: [String, ...]`, uses those.
/// - Else, if it has a `vector: [num, ...]`, derives two simple labels.
/// - Else shows a “missing” banner.
class TasteTypeBadges extends StatelessWidget {
  const TasteTypeBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    final ref = FirebaseFirestore.instance.collection('public_taste').doc(uid);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: ref.get(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 8);
        }
        if (!snap.hasData || !snap.data!.exists) {
          return _missingBanner(context);
        }

        final data = snap.data!.data() ?? {};
        // 1) If explicit types exist, use them.
        final explicit = (data['types'] as List?)?.cast<String>();
        if (explicit != null && explicit.isNotEmpty) {
          return _chips(explicit);
        }

        // 2) Otherwise, try to derive from vector
        final vector = (data['vector'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList();
        if (vector == null || vector.isEmpty) {
          return _missingBanner(context);
        }

        // Super simple derivation: first dim => spice, second => umami (you can swap later)
        final spice = vector.isNotEmpty ? vector[0] : 0.0;
        final umami = vector.length > 1 ? vector[1] : 0.0;

        final types = <String>[];
        if (spice >= 3.5) {
          types.add('Spice Chaser');
        } else {
          types.add('Mild Maven');
        }
        if (umami >= 3.5) {
          types.add('Umami Hunter');
        } else {
          types.add('Fresh & Light');
        }
        return _chips(types);
      },
    );
  }

  Widget _chips(List<String> types) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: types
            .map((t) => Chip(
                  label: Text(t),
                  avatar: const Icon(Icons.local_fire_department, size: 18),
                ))
            .toList(),
      ),
    );
  }

  Widget _missingBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No public taste vector yet. Finish the quiz or seed one in Taste Buds.',
            ),
          ),
        ],
      ),
    );
  }
}
