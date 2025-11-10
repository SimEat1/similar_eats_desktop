import 'package:flutter/material.dart';

class CommunitiesScreen extends StatelessWidget {
  static const route = '/communities';
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = const [
      ('Spicy Seekers – Vancouver', '1,204 members'),
      ('Fry Fanatics – Houston', '782 members'),
      ('Ramen Rangers – NYC', '5,103 members'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Communities')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (_, i) {
          final (title, subtitle) = groups[i];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.forum_outlined),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

