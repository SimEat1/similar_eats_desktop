param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Local Visit store for desktop ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

# 1) Local store (SharedPreferences JSON list)
$storePath = "lib/features/visits/data/visit_local_store.dart"
@"
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class VisitLocalStore {
  static const _k = 'visits_local_v1';

  Future<void> save(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? <String>[];
    list.add(jsonEncode(data));
    await sp.setStringList(_k, list);
  }

  Future<List<Map<String, dynamic>>> all() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? <String>[];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }
}
"@ | Set-Content -Encoding UTF8 $storePath
Write-Host "  ✓ wrote $storePath" -ForegroundColor Green

# 2) Patch repo to use local store on desktop
$repo = "lib/features/quick_eats/repo/quick_eats_repo.dart"
if (-not (Test-Path $repo)) {
  Write-Host "  ! $repo not found. If your repo file is elsewhere, tell me the path." -ForegroundColor Red
  exit 1
}
$content = Get-Content -Raw $repo

# ensure imports
$need = @(
  "import 'package:similar_eats_desktop/core/platform/platform_helper.dart';",
  "import 'package:similar_eats_desktop/features/visits/data/visit_local_store.dart';"
)
foreach ($i in $need) {
  if ($content -notmatch [regex]::Escape($i)) {
    if ($content -match "^(import\s+['""][^;]+['""];\s*)+") {
      $content = $content -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $i + "`r`n")
    } else { $content = $i + "`r`n" + $content }
  }
}

# wrap save method: if desktop => save locally
# We replace first occurrence of a Firestore add or set with our branch.
$guard = @"
    // Local Dev Mode: desktop writes to SharedPreferences instead of Firestore
    if (PlatformHelper.isDesktop) {
      await VisitLocalStore().save(data);
      return;
    }
"@
# inject before common firebase write calls
$patterns = @(
  "await\s+FirebaseFirestore\.instance\.[^\n]+\.add\(",
  "await\s+FirebaseFirestore\.instance\.[^\n]+\.set\("
)
$inserted = $false
foreach ($p in $patterns) {
  if ($content -match $p) {
    $content = $content -replace $p, $guard + "`r`n" + '$0'
    $inserted = $true; break
  }
}
if (-not $inserted) {
  # fallback: insert inside a method named save or saveVisit
  $content = [regex]::Replace(
    $content,
    "(saveVisit\s*\([^\)]*\)\s*async\s*\{)",
    "`$1`r`n$guard",
    1
  )
}

Set-Content -Encoding UTF8 $repo $content
Write-Host "  ✓ patched $repo (desktop → local)" -ForegroundColor Green

Write-Host "`nDone. Re-run the app and try Quick Visit again." -ForegroundColor Cyan
