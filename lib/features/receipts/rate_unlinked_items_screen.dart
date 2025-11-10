import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RateUnlinkedItemsScreen extends StatefulWidget {
  static const route = '/rate_unlinked_items';
  const RateUnlinkedItemsScreen({super.key});

  @override
  State<RateUnlinkedItemsScreen> createState() => _RateUnlinkedItemsScreenState();
}

class _RateUnlinkedItemsScreenState extends State<RateUnlinkedItemsScreen> {
  final Map<String, _Pick> _picks = {}; // key = item doc path

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('No user')),
      );
    }

    final q = FirebaseFirestore.instance
        .collectionGroup('items')
        .where('owner_uid', isEqualTo: uid)
        .where('visit_id', isNull: true)
        .limit(200);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Items to rate'),
        actions: [
          IconButton(
            tooltip: 'Create visits',
            icon: const Icon(Icons.save),
            onPressed: () => _createVisitsForSelections(uid),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: q.snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nothing to rate right now.'));
          }

          // Initialize local picks if missing
          for (final d in docs) {
            _picks.putIfAbsent(
              d.reference.path,
              () => _Pick(
                include: true,
                tasteRating: 3,
                portionRating: 3,
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final d = docs[i];
              final data = d.data();
              final name = (data['name'] as String?) ?? '(item)';
              final price = (data['price'] as num?)?.toDouble();
              final parentReceipt = d.reference.parent.parent; // .../receipts/{rid}

              final pick = _picks[d.reference.path]!;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: pick.include,
                            onChanged: (v) =>
                                setState(() => pick.include = v ?? true),
                          ),
                          Expanded(
                            child: Text(
                              '$name${price != null ? "  •  \$${price.toStringAsFixed(2)}" : ""}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      if (parentReceipt != null)
                        Text(
                          'Receipt: ${parentReceipt.id}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      const SizedBox(height: 6),
                      Text('Taste: ${pick.tasteRating}'),
                      Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '${pick.tasteRating}',
                        value: pick.tasteRating.toDouble(),
                        onChanged: (v) =>
                            setState(() => pick.tasteRating = v.round()),
                      ),
                      Text('Portion: ${pick.portionRating}'),
                      Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '${pick.portionRating}',
                        value: pick.portionRating.toDouble(),
                        onChanged: (v) =>
                            setState(() => pick.portionRating = v.round()),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _createVisitsForSelections(String uid) async {
    final db = FirebaseFirestore.instance;

    // Gather selected item docs from the current snapshot of picks
    final selected = _picks.entries.where((e) => e.value.include).toList();
    if (selected.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one item')),
      );
      return;
    }

    setState(() {}); // lock UI lightly
    int created = 0;

    try {
      for (final e in selected) {
        final itemPath = e.key;
        final pick = e.value;

        final itemRef = db.doc(itemPath);
        final parentReceipt = itemRef.parent.parent; // .../receipts/{rid}
        if (parentReceipt == null) continue;

        final itemSnap = await itemRef.get();
        final item = itemSnap.data();

        if (item == null) continue;

        final visitRef = db
            .collection('users')
            .doc(uid)
            .collection('visits')
            .doc();

        await visitRef.set({
          'created_at': DateTime.now().toIso8601String(),
          'merchant': null, // can be fetched from receipt if desired
          'item_name': item['name'],
          'price': item['price'],
          'taste_rating': pick.tasteRating,
          'portion_rating': pick.portionRating,
          'place_id': item['place_id'],
          'menu_item_id': item['menu_item_id'],
          'from_receipt': parentReceipt.id,
        });

        await itemRef.update({'visit_id': visitRef.id});
        created++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Created $created visit(s)')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }
}

class _Pick {
  bool include;
  int tasteRating;
  int portionRating;
  _Pick({
    required this.include,
    required this.tasteRating,
    required this.portionRating,
  });
}



