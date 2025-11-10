import "dart:typed_data";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:qr_flutter/qr_flutter.dart";
import "package:file_picker/file_picker.dart";
import "package:image/image.dart" as img;
import "package:zxing2/qrcode.dart";

import "package:similar_eats_desktop/features/friends/screens/friend_map_screen.dart";
import 'package:similar_eats_desktop/features/friends/data/friends_repository.dart';
import 'package:similar_eats_desktop/features/friends/models/public_profile.dart';
import 'package:similar_eats_desktop/features/friends/models/friend_request.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  final repo = FriendsRepository();
  final codeCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    repo.ensureMyProfile(); // idempotent
  }

  Future<String?> _decodeQrFromBytes(Uint8List bytes) async {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    // Build ARGB int pixels from RGBA bytes
    final rgba = image.getBytes(order: img.ChannelOrder.rgba);
    final pixels = Int32List(image.width * image.height);
    var j = 0;
    for (var i = 0; i < rgba.length; i += 4) {
      final r = rgba[i];
      final g = rgba[i + 1];
      final b = rgba[i + 2];
      pixels[j++] = (0xFF << 24) | (r << 16) | (g << 8) | b;
    }

    // zxing2 expects (width, height, pixels)
    final source = RGBLuminanceSource(image.width, image.height, pixels);
    final bitmap = BinaryBitmap(HybridBinarizer(source));
    try {
      final result = QRCodeReader().decode(bitmap);
      return result.text;
    } catch (_) {
      return null;
    }
  }

  Future<void> _importQrImage() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image);
    if (picked == null) return;
    final bytes = picked.files.single.bytes;
    if (bytes == null) return;
    final text = await _decodeQrFromBytes(bytes);
    if (!mounted) return;
    if (text == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Could not read QR")));
      return;
    }
    codeCtl.text = text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("QR decoded → code filled")));
  }

  Future<void> _sendByCode() async {
    final code = codeCtl.text.trim().toUpperCase();
    if (code.isEmpty) return;
    final target = await repo.findByCode(code);
    if (!mounted) return;
    if (target == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user with that code")));
      return;
    }
    await repo.sendFriendRequest(target.uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request sent to ${target.displayName}")),
    );
    codeCtl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Friends"),
          actions: [
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: "Friends map",
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FriendMapScreen()),
              ),
            ),
          ],
          bottom: const TabBar(tabs: [
            Tab(text: "Friends"),
            Tab(text: "Requests"),
            Tab(text: "Following"),
            Tab(text: "Add"),
          ]),
        ),
        body: TabBarView(
          children: [
            // Friends
            StreamBuilder<List<PublicProfile>>(
              stream: repo.streamFriends(),
              builder: (context, snap) {
                final items = snap.data ?? const <PublicProfile>[];
                if (items.isEmpty) {
                  return const Center(child: Text("No friends yet"));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final f = items[i];
                    return ListTile(
                      title: Text(f.displayName),
                      subtitle: Text("Code: ${f.friendCode}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.map),
                        tooltip: "Friend map",
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => FriendMapScreen(initialUid: f.uid),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            // Requests
            StreamBuilder<List<FriendRequest>>(
              stream: repo.streamRequests(),
              builder: (context, snap) {
                final items = snap.data ?? const <FriendRequest>[];
                if (items.isEmpty) {
                  return const Center(child: Text("No requests"));
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final r = items[i];
                    return ListTile(
                      title: Text(r.fromName),
                      subtitle: Text("Requested • ${r.createdAt.toLocal()}"),
                      trailing: FilledButton(
                        onPressed: () async {
                          await repo.acceptFriend(r.fromUid);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "You and ${r.fromName} are now friends"),
                              ),
                            );
                          }
                        },
                        child: const Text("Accept"),
                      ),
                    );
                  },
                );
              },
            ),
            // Following
            StreamBuilder<List<PublicProfile>>(
              stream: repo.streamFollowing(),
              builder: (context, snap) {
                final items = snap.data ?? const <PublicProfile>[];
                if (items.isEmpty) {
                  return const Center(child: Text("Not following anyone"));
                }
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = items[i];
                    return ListTile(
                      title: Text(p.displayName),
                      subtitle: Text("Code: ${p.friendCode}"),
                      trailing: TextButton(
                        onPressed: () => repo.unfollow(p.uid),
                        child: const Text("Unfollow"),
                      ),
                    );
                  },
                );
              },
            ),
            // Add
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  const Text("Share your code",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  StreamBuilder<PublicProfile?>(
                    stream: repo.myProfileStream(),
                    builder: (_, snap) {
                      final me = snap.data;
                      if (me == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final code = me.friendCode;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectableText(code,
                                  style: const TextStyle(
                                      fontSize: 18, letterSpacing: 2)),
                              const SizedBox(height: 12),
                              QrImageView(
                                  data: code,
                                  version: QrVersions.auto,
                                  size: 160),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text("Add by code",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeCtl,
                          decoration: const InputDecoration(
                            labelText: "Friend code",
                            hintText: "e.g. 9XK7P3QZ",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                          onPressed: _sendByCode,
                          child: const Text("Send request")),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _importQrImage,
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Import QR image"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
