$ErrorActionPreference = "Stop"

function Backup-And-Write($path, $content) {
  if (Test-Path $path) { Copy-Item $path "$path.bak" -Force; Write-Host "Backup: $path -> $path.bak" }
  $dir = Split-Path $path -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# ------------- 1) NEW: taste_type.dart -------------
$tasteTypePath = "lib\features\taste_profile\taste_type.dart"
$tasteTypeDart = @"
import 'dart:math';

/// Simple, explainable MVP taste-type classifier.
/// It takes a 5-D vector `[sweet, salty, spicy, crispy, umami]` (0-5 ints)
/// and names a primary + secondary badge.
class TasteType {
  final String primary;
  final String secondary;

  const TasteType(this.primary, this.secondary);

  Map<String, dynamic> toJson() => {
        'primary': primary,
        'secondary': secondary,
      };
}

const _labels = ['Sweet Tooth', 'Salt Seeker', 'Spice Chaser', 'Crispy Craver', 'Umami Hunter'];

TasteType classify(List<num> vector) {
  if (vector.isEmpty) return const TasteType('Balanced', 'Explorer');

  // clamp to 0..5, then pick top-2 indices
  final v = vector.map((e) => e.clamp(0, 5)).toList();
  final idxs = List<int>.generate(v.length, (i) => i);
  idxs.sort((a, b) => v[b].compareTo(v[a]));

  final p = _labels[min(idxs[0], _labels.length - 1)];
  final s = _labels[min(idxs.length > 1 ? idxs[1] : idxs[0], _labels.length - 1)];
  return TasteType(p, s);
}
"@
Backup-And-Write $tasteTypePath $tasteTypeDart

# ------------- 2) UPDATE: taste_quiz_save.dart -------------
$quizSavePath = "lib\features\taste_profile\taste_quiz_save.dart"
if (!(Test-Path $quizSavePath)) {
  throw "Expected $quizSavePath to exist (we created it earlier)."
}
$quizSave = Get-Content -Raw $quizSavePath

# Ensure import
if ($quizSave -notmatch "taste_type.dart") {
  $quizSave = $quizSave -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'taste_type.dart';`r`n"
}

# Replace/augment a method called saveTasteProfile(...) or saveTaste(...) etc.
# We'll add a helper that always writes taste_type to /userTaste and /public_taste.
if ($quizSave -notmatch "Future<void>\s+saveTasteWithType") {
  $inject = @"
Future<void> saveTasteWithType({
  required String uid,
  required List<num> vector, // [sweet,salty,spicy,crispy,umami] 0..5
  Map<String, dynamic>? extra,
}) async {
  final db = FirebaseFirestore.instance;
  final type = classify(vector); // from taste_type.dart

  final userDoc = db.collection('userTaste').doc(uid);
  final publicDoc = db.collection('public_taste').doc(uid);

  final payload = {
    'vector': vector,
    'taste_type': type.toJson(),
    'schema': 'v1',
    'updatedAt': FieldValue.serverTimestamp(),
    if (extra != null) ...extra,
  };

  await userDoc.set(payload, SetOptions(merge: true));
  await publicDoc.set(payload, SetOptions(merge: true));
}
"@
  # add before last closing brace of file
  $quizSave = $quizSave -replace "}\s*$", $inject + "`r`n}"
}

Backup-And-Write $quizSavePath $quizSave

# ------------- 3) UPDATE: Welcome screen to show YOUR badge -------------
$welcomePath = "lib\features\home\welcome_screen.dart"
if (!(Test-Path $welcomePath)) { throw "Missing $welcomePath" }
$welcome = Get-Content -Raw $welcomePath

# Ensure firestore/auth imports
if ($welcome -notmatch "package:cloud_firestore/cloud_firestore.dart") {
  $welcome = $welcome -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:cloud_firestore/cloud_firestore.dart';`r`n"
}
if ($welcome -notmatch "package:firebase_auth/firebase_auth.dart") {
  $welcome = $welcome -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:firebase_auth/firebase_auth.dart';`r`n"
}

# Insert a small widget that shows the badge chip row right under "What's for dinner?"
if ($welcome -notmatch "_TasteBadgeHeader") {
  $widget = @"
class _TasteBadgeHeader extends StatelessWidget {
  const _TasteBadgeHeader();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    final ref = FirebaseFirestore.instance.collection('public_taste').doc(uid);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data();
        final type = (data?['taste_type'] ?? const {}) as Map<String, dynamic>;
        final primary = (type['primary'] ?? 'Balanced') as String;
        final secondary = (type['secondary'] ?? 'Explorer') as String;

        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(primary)),
              Chip(label: Text(secondary)),
            ],
          ),
        );
      },
    );
  }
}
"@
  $welcome = $welcome -replace "}\s*$", $widget + "`r`n}"
}

# Render the header after “What’s for dinner?” title
if ($welcome -notmatch "const _TasteBadgeHeader\\(\\)") {
  $welcome = $welcome -replace "(Text\\(\"What's for dinner\\?\".*?\\),\\s*)",
    "`$1const _TasteBadgeHeader(),`r`n          "
}

Backup-And-Write $welcomePath $welcome

# ------------- 4) UPDATE: Taste Buds screen to show friend badges -------------
$budsPath = "lib\features\buds\screens\taste_buds_screen.dart"
if (!(Test-Path $budsPath)) { throw "Missing $budsPath (we added it earlier)." }
$buds = Get-Content -Raw $budsPath

# Ensure Firestore import
if ($buds -notmatch "package:cloud_firestore/cloud_firestore.dart") {
  $buds = $buds -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:cloud_firestore/cloud_firestore.dart';`r`n"
}

# Add a small row widget to show badges for each friend uid
if ($buds -notmatch "class _BudRow") {
  $budRow = @"
class _BudRow extends StatelessWidget {
  final String friendUid;
  const _BudRow({required this.friendUid});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance.collection('public_taste').doc(friendUid);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ref.snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data();
        final type = (data?['taste_type'] ?? const {}) as Map<String, dynamic>;
        final primary = (type['primary'] ?? 'Balanced') as String;
        final secondary = (type['secondary'] ?? 'Explorer') as String;

        return ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(friendUid),
          subtitle: Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(primary)),
              Chip(label: Text(secondary)),
            ],
          ),
        );
      },
    );
  }
}
"@
  $buds = $buds -replace "}\s*$", $budRow + "`r`n}"
}

# Replace any generic "Text(friendUid)" list with our _BudRow
$buds = $buds -replace "Text\\(friendUid\\)", "_BudRow(friendUid: friendUid)"

Backup-And-Write $budsPath $buds

Write-Host "`nDone. Rebuild the app:"
Write-Host "  flutter run -d windows"

