import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Use the repo that exists in your tree:
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
  // ✅ Use the available constructor
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Try List'),
        actions: const [
          Padding(
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
                  return const _EmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, i) {
                    final it = items[i];
                    return Card(
                      child: ListTile(
                        title: Text(
                          it.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        // 👇 No subtitle: avoids touching a non-existent createdAt
                        trailing: IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            await _repo.deleteItem(uid: uid!, id: it.id);
                          },
                        ),
                      ),
                    );
                  },
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
  const _EmptyState();

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




