param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Local Taste Profile store for desktop ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

# 1) Local store
$store = "lib/features/profile/data/taste_profile_local_store.dart"
@"
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TasteProfileLocalStore {
  static const _k = 'taste_profile_v1';

  Future<void> save(Map<String, dynamic> data) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_k);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k);
  }
}
"@ | Set-Content -Encoding UTF8 $store
Write-Host "  ✓ wrote $store" -ForegroundColor Green

# 2) Patch any quiz/profile repos & screens so desktop -> local store
$files = @(
  "lib/features/profile/data/taste_profile_repository.dart",
  "lib/features/taste_profiles/repo/taste_profiles_repo.dart",
  "lib/features/taste_quiz/presentation/taste_quiz_screen.dart",
  "lib/features/quiz/taste_quiz_screen.dart"
) | Where-Object { Test-Path $_ }

if ($files.Count -eq 0) {
  Write-Host "  ! No expected quiz/profile files found, skipping." -ForegroundColor Yellow
}

foreach ($f in $files) {
  Write-Host "  ~ patching $f" -ForegroundColor Yellow
  $t = Get-Content -Raw $f

  # ensure imports
  $imports = @(
    "import 'package:similar_eats_desktop/core/platform/platform_helper.dart';",
    "import 'package:similar_eats_desktop/features/profile/data/taste_profile_local_store.dart';"
  )
  foreach ($i in $imports) {
    if ($t -notmatch [regex]::Escape($i)) {
      if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
        $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $i + "`r`n")
      } else { $t = $i + "`r`n" + $t }
    }
  }

  # ===== SAVE BRANCH =====
  # If we find a Firestore write (set/add/update), insert a desktop guard before first one
  $guardSave = @"
    // Desktop: save taste profile locally instead of Firestore
    if (PlatformHelper.isDesktop) {
      // Expecting a Map<String, dynamic> named `data` or `payload`; use whichever exists.
      final _mapCandidate = ((){ try { return data; } catch (_) { try { return payload; } catch (_) { return null; } } })();
      if (_mapCandidate is Map<String, dynamic>) {
        await TasteProfileLocalStore().save(_mapCandidate);
      }
      return;
    }
"@
  $patWrites = @(
    "await\s+FirebaseFirestore\.instance[^\n]+\.set\(",
    "await\s+FirebaseFirestore\.instance[^\n]+\.add\(",
    "await\s+FirebaseFirestore\.instance[^\n]+\.update\("
  )
  foreach ($p in $patWrites) {
    if ($t -match $p) {
      $t = $t -replace $p, $guardSave + "`r`n" + '$0'
      break
    }
  }

  # Some screens call a `saveProfile`/`submit`/`onSave` method with a Map first; guard there too.
  $t = [regex]::Replace(
    $t,
    "(save(Profile|Taste|Quiz)?[^\{]*\{)",
    "`$1`r`n$guardSave",
    1
  )

  # ===== LOAD BRANCH =====
  # Before a Firestore .get, prefer local on desktop
  $guardLoad = @"
    // Desktop: load taste profile locally
    if (PlatformHelper.isDesktop) {
      final m = await TasteProfileLocalStore().load();
      if (m != null) {
        // If your code expects a model, the caller usually converts via fromJson.
        return m;
      }
    }
"@
  $t = $t -replace "await\s+FirebaseFirestore\.instance[^\n]+\.get\(", $guardLoad + "`r`n" + '$0'

  Set-Content -Encoding UTF8 $f $t
  Write-Host "    ✓ patched" -ForegroundColor Green
}

Write-Host "`nDone. Re-run, take the quiz, and open Recommendations." -ForegroundColor Cyan
