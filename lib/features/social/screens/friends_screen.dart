import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:qr_flutter/qr_flutter.dart";
import 'package:similar_eats_desktop/features/social/data/friends_repository.dart';
import 'package:similar_eats_desktop/features/social/models/public_profile.dart';

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  final repo = FriendsRepository();
  PublicProfile? me;
  final _codeCtl = TextEditingController();
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final card = await repo.ensureMyPublicCard();
    setState(() {
      me = card;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = PlatformHelper.getCurrentUid(firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
        bottom: const TabBar(tabs: [
          Tab(icon: Icon(Icons.people), text: "Friends"),
          Tab(icon: Icon(Icons.person_add), text: "Requests"),
          Tab(icon: Icon(Icons.visibility), text: "Following"),
          Tab(icon: Icon(Icons.qr_code), text: "Add"),
        ]),
      ),
      body: TabBarView(children: [
        // Friends
        StreamBuilder<List<PublicProfile>>(
          stream: repo.streamFriends(),
          builder: (context, snap) {
            final list = snap.data ?? const <PublicProfile>[];
            if (list.isEmpty) {
              return const Center(child: Text("No friends yet"));
            }
            return ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) {
                final p = list[i];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(p.displayName),
                  subtitle: Text("Code: ${p.friendCode}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.map),
                    tooltip: "Friend map",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => FriendMapScreen(friend: p),
                      ));
                    },
                  ),
                );
              },
            );
          },
        ),

        // Requests
        StreamBuilder<List<({String reqId, String fromUid, String status})>>(
          stream: repo.streamRequests(),
          builder: (context, snap) {
            final items = snap.data ?? const [];
            if (items.isEmpty) return const Center(child: Text("No requests"));
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                return ListTile(
                  title: Text("From: ${it.fromUid}"),
                  subtitle: Text("Status: ${it.status}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (it.status == "pending")
                        FilledButton(
                          onPressed: () => repo.acceptFriendRequest(
                              uid!, it.reqId, it.fromUid),
                          child: const Text("Accept"),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),

        // Following (simple list of ids)
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: uid == null
              ? const Stream.empty()
              : FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection("following")
                  .snapshots(),
          builder: (context, snap) {
            final ids = (snap.data?.docs ?? const []).map((d) => d.id).toList();
            if (ids.isEmpty) {
              return const Center(child: Text("Not following anyone"));
            }
            return ListView.builder(
              itemCount: ids.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(ids[i]),
              ),
            );
          },
        ),

        // Add (QR + Code)
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (me == null) const CircularProgressIndicator(),
              if (me != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text("Share this QR or code"),
                        const SizedBox(height: 8),
                        QrImageView(
                            data:
                                "se://add-friend?code=${me!.friendCode}&u=${me!.uid}",
                            size: 160),
                        const SizedBox(height: 8),
                        SelectableText(me!.friendCode,
                            style: const TextStyle(
                                fontSize: 24, letterSpacing: 2)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter friend code",
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                      child: FilledButton(
                    onPressed: () async {
                      final hit = await repo.lookupByCode(_codeCtl.text);
                      if (hit == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("No user found for code")));
                        }
                        return;
                      }
                      await repo.sendFriendRequest(hit.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Friend request sent to ${hit.displayName}")));
                      }
                    },
                    child: const Text("Send Friend Request"),
                  )),
                  const SizedBox(width: 8),
                  Expanded(
                      child: OutlinedButton(
                    onPressed: () async {
                      final hit = await repo.lookupByCode(_codeCtl.text);
                      if (hit == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("No user found for code")));
                        }
                        return;
                      }
                      await repo.follow(hit.uid);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Following ${hit.displayName}")));
                      }
                    },
                    child: const Text("Follow"),
                  )),
                ],
              )
            ],
          ),
        ),
      ]),
    );
  }
}

class FriendMapScreen extends StatelessWidget {
  final PublicProfile friend;
  const FriendMapScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    // MVP: explain + placeholder for combined suggestions.
    return Scaffold(
      appBar: AppBar(title: Text("Friend map Â· ${friend.displayName}")),
      body: const Center(
        child:
            Text("MVP: show overlap of your Phenom-noms & recent likes here."),
      ),
    );
  }
}


