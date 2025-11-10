import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:similar_eats_desktop/shared/geo/map_open.dart';

class ReceiptsHomeScreen extends StatefulWidget {
  static const route = "/receipts_home";
  const ReceiptsHomeScreen({super.key});

  @override
  State<ReceiptsHomeScreen> createState() => _ReceiptsHomeScreenState();
}

class _ReceiptsHomeScreenState extends State<ReceiptsHomeScreen> {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;
  final _fmtDate = DateFormat('yMMMd • h:mm a');
  final _currency = NumberFormat.simpleCurrency();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .collection('receipts')
            .orderBy('created_at', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('No receipts yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = docs[i].data();
              final id = docs[i].id;
              final merchant = (r['merchant'] ?? 'Unknown') as String;
              final total = (r['total'] as num?)?.toDouble();
              final createdIso = r['created_at'] as String?;
              DateTime? created;
              if (createdIso != null) {
                try {
                  created = DateTime.parse(createdIso);
                } catch (_) {}
              }

              return ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.black.withValues(alpha: .04)),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: Colors.black.withValues(alpha: .04)),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchant.isEmpty ? 'Receipt' : merchant,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            created != null ? _fmtDate.format(created) : '—',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (total != null)
                      Text(
                        _currency.format(total),
                        style: theme.textTheme.titleMedium,
                      ),
                    IconButton(
                      tooltip: 'Open in Maps',
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () => openMapSearch(
                        query:
                            merchant.isEmpty ? 'restaurants near me' : merchant,
                      ),
                    ),
                  ],
                ),
                children: [
                  _ReceiptItemsList(
                      uid: _uid, receiptId: id, merchant: merchant),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReceiptItemsList extends StatelessWidget {
  final String uid;
  final String receiptId;
  final String merchant;
  const _ReceiptItemsList({
    required this.uid,
    required this.receiptId,
    required this.merchant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.simpleCurrency();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('receipts')
          .doc(receiptId)
          .collection('items')
          .orderBy(FieldPath.documentId)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: LinearProgressIndicator(minHeight: 2),
          );
        }
        final items = snap.data?.docs ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text('No items on this receipt.'),
          );
        }

        return Column(
          children: items.map((d) {
            final m = d.data();
            final name = (m['name'] ?? '') as String;
            final price = (m['price'] as num?)?.toDouble();
            final visitId = m['visit_id'] as String?;
            final placeId = m['place_id'] as String?;
            final menuItemId = m['menu_item_id'] as String?;

            return ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.restaurant_menu),
              title: Text(
                name.isEmpty ? (m['raw'] ?? 'item') : name,
                style: theme.textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  if (price != null) Text(currency.format(price)),
                  if (visitId != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.link, size: 14),
                    const SizedBox(width: 4),
                    const Text('visit'),
                  ],
                  if (placeId != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.place, size: 14),
                    const SizedBox(width: 4),
                    const Text('place'),
                  ],
                  if (menuItemId != null) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.tag, size: 14),
                    const SizedBox(width: 4),
                    const Text('menu'),
                  ],
                ],
              ),
              trailing: IconButton(
                tooltip: 'Find in Maps',
                icon: const Icon(Icons.map_outlined),
                onPressed: () {
                  final q = [
                    if (name.isNotEmpty) name,
                    if (merchant.isNotEmpty) merchant,
                  ].join(' ');
                  openMapSearch(query: q.isEmpty ? 'restaurants near me' : q);
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
