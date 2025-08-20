import 'package:flutter/material.dart';

void main() {
  runApp(const SimilarEatsDesktopApp());
}

class SimilarEatsDesktopApp extends StatelessWidget {
  const SimilarEatsDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Similar Eats (Desktop)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

/// --------------------------- MOCK DATA ---------------------------
class TasteProfile {
  final String name;
  final Map<String, int> scores; // e.g. {'spicy': 9, 'cheesy': 6}
  const TasteProfile(this.name, this.scores);
}

final davidProfile = TasteProfile('David', const {
  'spicy': 9,
  'crispy': 7,
  'cheesy': 6,
  'sweet': 4,
  'umami': 8,
});

class Restaurant {
  final String name;
  final List<String> tags;
  Restaurant(this.name, this.tags);
}

final mockRestaurants = <Restaurant>[
  Restaurant('El Fuego Taqueria', ['spicy', 'crispy', 'cilantro', 'lime']),
  Restaurant('Umami House Ramen', ['umami', 'noodles', 'pork', 'egg']),
  Restaurant('Cheese & Crust', ['cheesy', 'crispy', 'pizza']),
  Restaurant('Sweet Spoon', ['dessert', 'sweet']),
];

final mockTryList = <String>[
  'Garlic Parmesan Fries',
  'Tonkotsu Ramen',
  'Hot Chicken Sandwich',
];

final mockFavorites = <String>[
  'El Fuego Taqueria',
  'Cheese & Crust',
];

class SimilarUser {
  final String name;
  final int match; // percent
  final List<String> shared;
  SimilarUser(this.name, this.match, this.shared);
}

final mockSimilarUsers = <SimilarUser>[
  SimilarUser('Alex', 87, ['spicy', 'umami']),
  SimilarUser('Sam', 78, ['cheesy', 'crispy']),
  SimilarUser('Jordan', 73, ['umami', 'crispy']),
];

/// --------------------------- LOGIN ---------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtl = TextEditingController();
  final passCtl = TextEditingController();
  bool showError = false;
  bool loading = false;

  void _login() async {
    setState(() {
      loading = true;
      showError = false;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    final u = userCtl.text.trim().toLowerCase();
    final p = passCtl.text.trim().toLowerCase();
    if (u == 'david' && p == 'david') {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    } else {
      setState(() {
        showError = true;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            elevation: 2,
            surfaceTintColor: cs.surfaceTint,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Similar Eats (Desktop)',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text('Mock login â€” use david / david'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: userCtl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passCtl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 12),
                  if (showError)
                    Text('Invalid credentials',
                        style: TextStyle(color: cs.error)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: loading ? null : _login,
                    icon: loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: const Text('Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// --------------------------- APP SHELL + NAV ---------------------------
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeRecommendations(),
      const TryListScreen(),
      const FavoritesScreen(),
      const SimilarUsersScreen(),
      const ProfileScreen(),
    ];
    final titles = [
      'Home',
      'Try List',
      'Favorites',
      'Similar Users',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[idx])),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[idx],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (v) => setState(() => idx = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Try'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favs'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), label: 'Similar'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

/// --------------------------- SCREENS ---------------------------
class HomeRecommendations extends StatelessWidget {
  const HomeRecommendations({super.key});

  List<Restaurant> _rankedForDavid() {
    // Simple rule: prefer spicy/umami, then crispy/cheesy
    int score(Restaurant r) {
      int s = 0;
      for (final t in r.tags) {
        s += (davidProfile.scores[t] ?? 0);
      }
      return s;
    }

    final sorted = [...mockRestaurants]..sort((a, b) => score(b).compareTo(score(a)));
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final recs = _rankedForDavid();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final r = recs[i];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.restaurant)),
            title: Text(r.name),
            subtitle: Wrap(
              spacing: 8,
              children: r.tags.map((t) => Chip(label: Text(t))).toList(),
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: recs.length,
    );
  }
}

class TryListScreen extends StatelessWidget {
  const TryListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final item = mockTryList[i];
        final match = mockRestaurants.firstWhere(
          (r) => i < mockRestaurants.length ? true : false,
          orElse: () => Restaurant('Any good spot', const []),
        );
        return Card(
          child: ListTile(
            leading: const Icon(Icons.local_dining),
            title: Text(item),
            subtitle: Text('Suggested: ${mockRestaurants[i % mockRestaurants.length].name}'),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: mockTryList.length,
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final name = mockFavorites[i];
        final r = mockRestaurants.firstWhere(
          (x) => x.name == name,
          orElse: () => Restaurant(name, const []),
        );
        return Card(
          child: ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(r.name),
            subtitle: Wrap(
              spacing: 8,
              children: r.tags.map((t) => Chip(label: Text(t))).toList(),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: mockFavorites.length,
    );
  }
}

class SimilarUsersScreen extends StatelessWidget {
  const SimilarUsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, i) {
        final u = mockSimilarUsers[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(u.name.characters.first),
            ),
            title: Text('${u.name}  â€¢  ${u.match}% match'),
            subtitle: Wrap(
              spacing: 8,
              children: u.shared.map((t) => Chip(label: Text(t))).toList(),
            ),
            trailing: const Icon(Icons.person_add_alt_1_outlined),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: mockSimilarUsers.length,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final scores = davidProfile.scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('${davidProfile.name} â€” ðŸ”¥ Spice Chaser'),
            subtitle: const Text('Taste profile overview'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemBuilder: (_, i) {
                final e = scores[i];
                return Card(
                  child: ListTile(
                    title: Text(e.key.toUpperCase()),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        10,
                        (n) => Icon(
                          n < e.value ? Icons.star : Icons.star_border,
                          size: 18,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: scores.length,
            ),
          ),
        ],
      ),
    );
  }
}


