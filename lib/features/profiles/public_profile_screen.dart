import 'package:flutter/material.dart';

class PublicProfileScreen extends StatelessWidget {
  static const route = '/public_profile';
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = 'me'; // replace with FirebaseAuth.instance.currentUser?.uid
    return Scaffold(
      appBar: AppBar(title: const Text('Public Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('similareats.com/$uid (preview)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Text('Taste badges, top dishes, recent wins (stub)'),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Edit visible sections'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('Copy share link'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
