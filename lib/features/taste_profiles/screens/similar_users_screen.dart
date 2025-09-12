import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repo/taste_profiles_repo.dart';

class SimilarUsersScreen extends StatefulWidget {
  const SimilarUsersScreen({super.key});

  @override
  State<SimilarUsersScreen> createState() => _SimilarUsersScreenState();
}

class _SimilarUsersScreenState extends State<SimilarUsersScreen> {
  final _repo = TasteProfilesRepo();
  late Future<List<MapEntry<String, double>>> _future;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _future = _load(uid);
  }

  Future<List<MapEntry<String, double>>> _load(String? uid) async {
    if (uid == null) return [];
    final list = await _repo.topSimilarUsers(uid, limit: 20);
    return list.map((s) => MapEntry(s.uid, s.score)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Similar Users')),
      body: FutureBuilder<List<MapEntry<String, double>>>(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No similar users yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final e = items[i];
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(e.key),
                trailing: Text((e.value * 100).toStringAsFixed(0) + '%'),
              );
            },
          );
        },
      ),
    );
  }
}


