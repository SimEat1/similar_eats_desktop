# scripts/verify-anon-login.ps1
param(
  [string[]]$Files = @("lib\main.dart","lib\main_demo.dart")
)

Write-Host "== Verify anonymous login after Firebase.initializeApp ==" -ForegroundColor Cyan

$patched = $false
foreach ($f in $Files) {
  if (-not (Test-Path $f)) { continue }

  $t = Get-Content -Raw $f
  $orig = $t

  # quick presence checks
  $hasInit = $t -match "Firebase\.initializeApp\s*\("
  $hasAnon = $t -match "FirebaseAuth\.instance\.signInAnonymously\s*\("

  Write-Host "• $f" -NoNewline
  if (-not $hasInit) {
    Write-Host "  – Firebase.initializeApp NOT found (skipping file)" -ForegroundColor Yellow
    continue
  }
  if ($hasAnon) {
    Write-Host "  – anon login already present ✅" -ForegroundColor Green
    continue
  }

  # insert the anon sign-in immediately after the first await Firebase.initializeApp(...);
  $t = [regex]::Replace(
    $t,
    "(await\s+Firebase\.initializeApp\s*\([^\)]*\)\s*;)",
    "`$1`r`n    await FirebaseAuth.instance.signInAnonymously();",
    1
  )

  if ($t -ne $orig) {
    # ensure imports exist
    $import = "import 'package:firebase_auth/firebase_auth.dart';"
    if ($t -notmatch [regex]::Escape($import)) {
      if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
        $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
      } else { $t = $import + "`r`n" + $t }
    }

    Copy-Item $f "$f.bak" -Force
    Set-Content -Encoding UTF8 $f $t
    Write-Host "  – inserted anon login ✅ (backup: $f.bak)" -ForegroundColor Green
    $patched = $true
  } else {
    Write-Host "  – could not auto-insert (pattern not found)" -ForegroundColor Yellow
  }
}

if (-not $patched) {
  Write-Host "`nNo changes needed." -ForegroundColor DarkGray
} else {
  Write-Host "`nDone. Now run:" -ForegroundColor Cyan
  Write-Host "  flutter clean" -ForegroundColor Yellow
  Write-Host "  flutter pub get" -ForegroundColor Yellow
  Write-Host "  flutter run -d windows" -ForegroundColor Yellow
}

