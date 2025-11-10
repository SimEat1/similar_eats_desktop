# patch_taste_buds.ps1
# - Adds TasteBudsScreen route + import to main.dart
# - Adds DEV: Seed vectors action + helper to taste_buds_screen.dart
# - Creates backups *.bak

$ErrorActionPreference = "Stop"

function Backup-And-Write($path, $content) {
  if (Test-Path $path) {
    Copy-Item $path "$path.bak" -Force
    Write-Host "Backup: $path -> $path.bak"
  }
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# ---------- Patch main.dart ----------
$mainPath = "lib\main.dart"
if (-not (Test-Path $mainPath)) {
  throw "Cannot find $mainPath"
}
$main = Get-Content -Raw $mainPath

# 1) Ensure import for TasteBudsScreen
if ($main -notmatch "features/buds/screens/taste_buds_screen.dart") {
  # insert after the last import line
  $main = $main -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)", "`$1import 'features/buds/screens/taste_buds_screen.dart';`r`n"
  Write-Host "Added import to main.dart"
}

# 2) Ensure route mapping exists
if ($main -notmatch "TasteBudsScreen\.route") {
  # Find routes: { ... } map and insert line before closing brace of the map
  $main = $main -replace "(routes\s*:\s*\{\s*)(?s)", "`$1`r`n        TasteBudsScreen.route: (_) => const TasteBudsScreen(),`r`n"
  Write-Host "Added route to main.dart"
}

Backup-And-Write $mainPath $main

# ---------- Patch taste_buds_screen.dart ----------
$budsScreenPath = "lib\features\buds\screens\taste_buds_screen.dart"
if (-not (Test-Path $budsScreenPath)) {
  throw "Cannot find $budsScreenPath (did you run setup_taste_buds.ps1 first?)"
}
$buds = Get-Content -Raw $budsScreenPath

# 3) Insert _devSeedVectors() helper if missing
if ($buds -notmatch "Future<void>\s+_devSeedVectors\(\)") {
  # Inject helper right before the build() method
  $helper = @"
  Future<void> _devSeedVectors() async {
    try {
      final me = FirebaseAuth.instance.currentUser?.uid;
      if (me == null) throw Exception('No uid');
      final db = FirebaseFirestore.instance;

      // your vector (replace with real quiz later)
      await db.collection('public_taste').doc(me).set({
        'vector': [3, 5, 2, 4, 1],
        'updatedAt': FieldValue.serverTimestamp(),
        'schema': 'v1',
      }, SetOptions(merge: true));

      // demo friend
      const friend = 'demo_friend_uid';
      await db.collection('public_taste').doc(friend).set({
        'vector': [3, 4, 2, 5, 1],
        'updatedAt': FieldValue.serverTimestamp(),
        'schema': 'v1',
      }, SetOptions(merge: true));

      // add friend link
      await db.collection('users').doc(me)
        .collection('buds').doc(friend)
        .set({'since': FieldValue.serverTimestamp()}, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seeded your vector + demo friend')),
      );
      setState(() {}); // refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Seed failed: $e')),
      );
    }
  }

"@

  $buds = $buds -replace "(@override\s+Widget\s+build\()", $helper + "`$1"
  Write-Host "Inserted _devSeedVectors() helper into taste_buds_screen.dart"
}

# 4) Add AppBar action button (DEV: Seed vectors)
# Replace a simple appBar without actions to one with actions, or append our action if actions exist.
if ($buds -match "appBar:\s*AppBar\(\s*title:\s*const\s*Text\('Taste Buds'\)\s*\)") {
  $buds = $buds -replace "appBar:\s*AppBar\(\s*title:\s*const\s*Text\('Taste Buds'\)\s*\)",
@"
appBar: AppBar(
  title: const Text('Taste Buds'),
  actions: [
    IconButton(
      tooltip: 'DEV: Seed vectors',
      icon: const Icon(Icons.bolt),
      onPressed: _devSeedVectors,
    ),
  ],
)
"@
  Write-Host "Replaced simple AppBar with actions in taste_buds_screen.dart"
}
elseif ($buds -match "appBar:\s*AppBar\(" -and $buds -notmatch "onPressed:\s*_devSeedVectors") {
  # try to inject our action into existing actions list
  $buds = $buds -replace "actions:\s*\[", "actions: [`r`n    IconButton(tooltip: 'DEV: Seed vectors', icon: const Icon(Icons.bolt), onPressed: _devSeedVectors,),"
  Write-Host "Injected DEV action into existing AppBar actions in taste_buds_screen.dart"
}
else {
  Write-Host "AppBar already contains DEV seed action."
}

Backup-And-Write $budsScreenPath $buds

Write-Host "`nDone! Next:"
Write-Host " - Run: flutter run -d windows"
Write-Host " - Navigate to Taste Buds screen (route: /taste_buds)"
Write-Host " - Tap the ⚡ (DEV: Seed vectors) to create your vector + a demo friend"
