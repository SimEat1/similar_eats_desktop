import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:similar_eats_desktop/features/try_list/try_list_repo.dart' as tr;

// Local widgets
import 'package:similar_eats_desktop/widgets/shimmer_list.dart';
import 'package:similar_eats_desktop/widgets/sync_badge.dart';

class TryListScreen extends StatefulWidget {
  static const route = '/try-list';
  const TryListScreen({super.key});

  @override
  State<TryListScreen> createState() => _TryListScreenState();
}

class _TryListScreenState extends State<TryListScreen> {
  final _repo = tr.TryListRepo();

  Future<void> _addItemDialog(String uid) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Try List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. “Bistro Leon — duck confit”',
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        await _repo.addItem(uid: uid, name: name);
      }
    }
  }

  // ---- Firestore metadata -> SyncBadge -----------------------------------
  Stream<({bool isFromCache, bool hasPendingWrites})> _syncStateStream(
    String uid,
  ) {
    final col = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('try_list');

    return col
        .limit(1)
        .snapshots(includeMetadataChanges: true)
        .map((qs) => (
              isFromCache: qs.metadata.isFromCache,
              hasPendingWrites: qs.metadata.hasPendingWrites,
            ))
        .handleError((_) => (isFromCache: false, hasPendingWrites: false));
  }
  // ------------------------------------------------------------------------

  // Friendly “Added … ago” without extra packages.
  String? _formatAdded(int? createdAtMillis) {
    if (createdAtMillis == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(createdAtMillis).toLocal();
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 45) return 'just now';
    if (diff.inMinutes < 2) return 'a minute ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 2) return 'an hour ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    // Fallback: short date (e.g., Nov 5, 2025)
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[dt.month - 1];
    return '$m ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Try List'),
        actions: [
          if (uid != null)
            StreamBuilder<({bool isFromCache, bool hasPendingWrites})>(
              stream: _syncStateStream(uid),
              builder: (context, snap) {
                final state = snap.data ??
                    (isFromCache: true, hasPendingWrites: false);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Center(
                    child: SyncBadge(
                      isFromCache: state.isFromCache,
                      hasPendingWrites: state.hasPendingWrites,
                    ),
                  ),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Center(
                child: SyncBadge(
                  isFromCache: false,
                  hasPendingWrites: false,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addItemDialog(uid),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
      body: uid == null
          ? const _AuthHint()
          : StreamBuilder<List<tr.TryItem>>(
              stream: _repo.watchItems(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(count: 6);
                }
                if (snap.hasError) {
                  return _ErrorState(
                    error: snap.error,
                    onRetry: () => setState(() {}),
                  );
                }

                final items = snap.data ?? const <tr.TryItem>[];
                if (items.isEmpty) {
                  return _EmptyState(onAdd: () => _addItemDialog(uid));
                }

                final snackDuration = const Duration(seconds: 4);

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final it = items[i];

                      return Dismissible(
                        key: ValueKey(it.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Icon(Icons.delete_outline),
                              SizedBox(width: 6),
                              Text('Delete'),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          // light haptic on swipe delete (no-op on desktop)
                          try {
                            await HapticFeedback.lightImpact();
                          } catch (_) {}
                          final removed = it;
                          await _repo.deleteItem(uid: uid, id: removed.id);

                          if (!mounted) return true;

                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                duration: snackDuration,
                                content: Text('Removed “${removed.name}”'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () async {
                                    await _repo.addItem(
                                      uid: uid,
                                      name: removed.name,
                                    );
                                  },
                                ),
                              ),
                            );

                          return true;
                        },
                        child: Card(
                          color: const Color(0xFFFFEDE6),
                          child: ListTile(
                            title: Text(
                              it.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: () {
                              final pretty = _formatAdded(it.createdAtMillis);
                              if (pretty == null) return null;
                              return Text(
                                'Added: $pretty',
                                style: const TextStyle(fontSize: 12),
                              );
                            }(),
                            trailing: IconButton(
                              tooltip: 'Remove',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                try {
                                  await HapticFeedback.lightImpact();
                                } catch (_) {}
                                final removed = it;
                                await _repo.deleteItem(uid: uid, id: removed.id);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      duration: snackDuration,
                                      content: Text('Removed “${removed.name}”'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () async {
                                          await _repo.addItem(
                                            uid: uid,
                                            name: removed.name,
                                          );
                                        },
                                      ),
                                    ),
                                  );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _AuthHint extends StatelessWidget {
  const _AuthHint();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'Sign-in is required to use the Try List.\n'
          '(Anonymous is fine — hit the Sign In button on the home screen.)',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.playlist_add_outlined, size: 56),
        const SizedBox(height: 12),
        const Text(
          'Your Try List is empty',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap “Add” to stash a place you want to try.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add your first place'),
        ),
      ]),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 40),
        const SizedBox(height: 8),
        Text(
          'Oops — could not load your Try List.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          '$error',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        )
      ]),
    );
  }
}





