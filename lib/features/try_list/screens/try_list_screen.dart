import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../firebase_options.dart';
import '../../../core/auth/anon_auth.dart';
import '../try_list_repo.dart'; // provides TryListRepo + TryItem

class TryListScreen extends StatefulWidget {
  const TryListScreen({super.key});

  @override
  State<TryListScreen> createState() => _TryListScreenState();
}

class _TryListScreenState extends State<TryListScreen> {
  final _repo = TryListRepo();

  String? _uid;
  Stream<List<TryItem>>? _stream;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    print(">>> [TryList] Starting init...");

    // Ensure Firebase app exists
    try {
      Firebase.app();
      print(">>> [TryList] Firebase already initialized.");
    } catch (_) {
      print(">>> [TryList] Initializing Firebase...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Ensure anonymous sign-in
    try {
      await AnonAuth.instance.ensureSignedIn();
    } catch (e) {
      print(">>> [TryList] ensureSignedIn threw: $e");
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print(">>> [TryList] ERROR: No Firebase user after ensureSignedIn!");
      return;
    }

    _uid = user.uid;
    print(">>> [TryList] Signed in as UID: $_uid");

    // Start watching list
    _stream = _repo.watchItems(_uid!);
    print(">>> [TryList] Stream attached.");

    if (mounted) setState(() {});
  }

  Future<void> _addItemDialog() async {
    if (_uid == null) return;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Try List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Place or dish name',
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    try {
      await _repo.addItem(uid: _uid!, name: name);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add: $e')),
      );
    }
  }

  Future<void> _deleteItem(TryItem it) async {
    if (_uid == null) return;
    try {
      await _repo.deleteItem(uid: _uid!, id: it.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Try List'),
        actions: [
          if (_uid != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  _uid!.substring(0, 6), // just a short indicator
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _stream == null
            ? const Center(child: CircularProgressIndicator())
            : StreamBuilder<List<TryItem>>(
                stream: _stream,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('Error: ${snap.error}'),
                    );
                  }
                  final items = snap.data ?? const <TryItem>[];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Nothing yet — add something to try!'),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final it = items[i];
                      return ListTile(
                        leading: const Icon(Icons.push_pin_outlined),
                        title: Text(it.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteItem(it),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

