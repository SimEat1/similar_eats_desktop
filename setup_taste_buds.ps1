# setup_taste_buds.ps1
# Creates:
#  - lib/features/buds/services/taste_buds_service.dart
#  - lib/features/buds/screens/taste_buds_screen.dart
#  - lib/features/taste_profile/taste_quiz_save.dart
# Backs up any existing files as *.bak and writes UTF-8.

$ErrorActionPreference = "Stop"

function Ensure-Dir($p) {
  if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p | Out-Null }
}

function Write-File($path, $content) {
  if (Test-Path $path) {
    Copy-Item $path "$path.bak" -Force
    Write-Host "Backed up existing $path -> $path.bak"
  } else {
    Ensure-Dir (Split-Path $path)
  }
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote $path"
}

# --- File 1: taste_buds_service.dart ---
$budsServicePath = "lib/features/buds/services/taste_buds_service.dart"
$budsService = @'
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasteBudsService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // Friend doc under owner: /users/{uid}/buds/{friendUid}
  DocumentReference<Map<String, dynamic>> _budDoc(String ownerUid, String friendUid) =>
      _db.collection('users').doc(ownerUid).collection('buds').doc(friendUid);

  // Public taste vector: /public_taste/{uid}
  DocumentReference<Map<String, dynamic>> _publicTasteDoc(String uid) =>
      _db.collection('public_taste').doc(uid);

  /// Add a friend (taste bud) by UID. Optional alias.
  Future<void> addBud({required String friendUid, String? alias}) async {
    final me = _uid;
    if (me == null) throw Exception('Not signed in');
    if (friendUid == me) throw Exception("Can't add yourself");

    await _budDoc(me, friendUid).set({
      'since': FieldValue.serverTimestamp(),
      'alias': alias,
    }, SetOptions(merge: true));
  }

  /// Remove a friend
  Future<void> removeBud({required String friendUid}) async {
    final me = _uid;
    if (me == null) throw Exception('Not signed in');
    await _budDoc(me, friendUid).delete();
  }

  /// Stream of my buds
  Stream<List<BudLink>> budsStream() {
    final me = _uid;
    if (me == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users').doc(me).collection('buds')
        .orderBy('since', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => BudLink.fromDoc(d.id, d.data())).toList());
  }

  /// Reads a public taste vector for any uid
  Future<List<double>?> readPublicVector(String uid) async {
    final snap = await _publicTasteDoc(uid).get();
    if (!snap.exists) return null;
    final v = (snap.data()?['vector'] as List?)?.map((e) => (e as num).toDouble()).toList();
    return v;
  }

  /// Cosine similarity in [0,1]
  double cosine(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty || a.length != b.length) return 0.0;
    double dot = 0, na = 0, nb = 0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0.0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }
}

class BudLink {
  final String friendUid;
  final String? alias;
  final DateTime? since;

  BudLink({required this.friendUid, this.alias, this.since});

  factory BudLink.fromDoc(String id, Map<String, dynamic> data) {
    return BudLink(
      friendUid: id,
      alias: data['alias'] as String?,
      since: (data['since'] is Timestamp) ? (data['since'] as Timestamp).toDate() : null,
    );
  }
}
'@

# --- File 2: taste_buds_screen.dart ---
$budsScreenPath = "lib/features/buds/screens/taste_buds_screen.dart"
$budsScreen = @'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/taste_buds_service.dart';

class TasteBudsScreen extends StatefulWidget {
  static const route = '/taste_buds';
  const TasteBudsScreen({super.key});

  @override
  State<TasteBudsScreen> createState() => _TasteBudsScreenState();
}

class _TasteBudsScreenState extends State<TasteBudsScreen> {
  final _svc = TasteBudsService();
  final _uidCtrl = TextEditingController();
  List<double>? _myVector;

  @override
  void initState() {
    super.initState();
    _loadMyVector();
  }

  Future<void> _loadMyVector() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance.collection('public_taste').doc(uid).get();
    if (!mounted) return;
    setState(() {
      _myVector = (snap.data()?['vector'] as List?)
          ?.map((e) => (e as num).toDouble())
          .toList();
    });
  }

  Future<void> _addBud() async {
    final id = _uidCtrl.text.trim();
    if (id.isEmpty) return;
    try {
      await _svc.addBud(friendUid: id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend added')),
        );
      }
      _uidCtrl.clear();
      setState(() {}); // refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add failed: $e')),
      );
    }
  }

  double _similarityWith(List<double>? friendVector) {
    if (_myVector == null || friendVector == null) return 0.0;
    return _svc.cosine(_myVector!, friendVector);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taste Buds')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _uidCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Add by UID',
                      hintText: 'paste a friend UID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _addBud, child: const Text('Add')),
              ],
            ),
          ),
          if (_myVector == null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your public taste vector is missing. Save your taste quiz to /public_taste first.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<BudLink>>(
              stream: _svc.budsStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final buds = snap.data ?? const <BudLink>[];
                if (buds.isEmpty) {
                  return const Center(child: Text('No taste buds yet.'));
                }
                return ListView.separated(
                  itemCount: buds.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final b = buds[i];
                    return FutureBuilder<List<double>?>(
                      future: _svc.readPublicVector(b.friendUid),
                      builder: (_, fsnap) {
                        final v = fsnap.data;
                        final sim = _similarityWith(v); // 0..1
                        final pct = (sim * 100).round();
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(b.alias ?? b.friendUid),
                          subtitle: Text('UID: ${b.friendUid}'),
                          trailing: Text(
                            v == null ? '—' : 'Taste match: $pct%',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onLongPress: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Remove friend?'),
                                content: Text('Remove ${b.alias ?? b.friendUid}'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await _svc.removeBud(friendUid: b.friendUid);
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
'@

# --- File 3: taste_quiz_save.dart ---
$quizSavePath = "lib/features/taste_profile/taste_quiz_save.dart"
$quizSave = @'
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";

/// Minimal taste vector model: keep it fixed-length & numeric.
/// Replace/extend this with your real quiz fields → normalized vector.
class TasteVector {
  final List<double> values; // e.g., [sweet, salty, sour, spicy, umami]
  const TasteVector(this.values);

  Map<String, dynamic> toPrivateDoc() => {
        "vector": values,
        "updatedAt": FieldValue.serverTimestamp(),
        "schema": "v1", // bump when you change dimensionality
      };

  Map<String, dynamic> toPublicDoc() => {
        "vector": values,
        "updatedAt": FieldValue.serverTimestamp(),
        "schema": "v1",
      };
}

class TasteQuizSaver {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser?.uid;
    if (u == null || u.isEmpty) {
      throw Exception("Not signed in");
    }
    return u;
  }

  /// Saves to:
  ///  - /userTaste/{uid}      (owner-only)
  ///  - /public_taste/{uid}   (readable by signed-in users)
  Future<void> saveBoth(TasteVector v) async {
    final uid = _uid;
    final batch = _db.batch();

    final privateRef = _db.collection("userTaste").doc(uid);
    final publicRef  = _db.collection("public_taste").doc(uid);

    batch.set(privateRef, v.toPrivateDoc(), SetOptions(merge: true));
    batch.set(publicRef,  v.toPublicDoc(),  SetOptions(merge: true));

    await batch.commit();
  }
}
'@

Write-File $budsServicePath $budsService
Write-File $budsScreenPath  $budsScreen
Write-File $quizSavePath     $quizSave

Write-Host "`nAll files written. Next steps:"
Write-Host "1) Add the screen route:"
Write-Host "   - import:   import 'features/buds/screens/taste_buds_screen.dart';"
Write-Host "   - route:    TasteBudsScreen.route: (_) => const TasteBudsScreen(),"
Write-Host "   - navigate: Navigator.pushNamed(context, TasteBudsScreen.route);"
Write-Host "2) Use TasteQuizSaver in your quiz completion to write /userTaste & /public_taste."
Write-Host "3) Ensure rules allow:"
Write-Host "   - /users/{uid}/buds/{friendUid} owner-only"
Write-Host "   - /public_taste/{uid} read(signed-in), write(owner)"
