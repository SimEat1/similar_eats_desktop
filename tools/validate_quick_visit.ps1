# --- validate_quick_visit.ps1 -----------------------------------------------
param()

$root   = "C:\projects\similar_eats_desktop"
$dev    = Join-Path $root "lib\dev_quick_visit.dart"
$quick  = Join-Path $root "lib\features\visits\screens\quick_visit_screen.dart"
$opts   = Join-Path $root "lib\firebase_options.dart"
$rules  = Join-Path $root "firestore.rules"
$idx    = Join-Path $root "firestore.indexes.json"
$bat    = Join-Path $root "triage_quick_visit.bat"
$ps1    = Join-Path $root "tools\triage_quick_visit.ps1"

function ok  ($m){ Write-Host "  ✔ $m" -ForegroundColor Green }
function warn($m){ Write-Host "  ! $m" -ForegroundColor Yellow }
function err ($m){ Write-Host "  × $m" -ForegroundColor Red }

Write-Host "`n=== Quick Visit – environment ===" -ForegroundColor Cyan
$flutter = (Get-Command flutter -ErrorAction SilentlyContinue)
if ($flutter) { ok "flutter: $($flutter.Source)" } else { err "flutter not on PATH"; }

$dart = (Get-Command dart -ErrorAction SilentlyContinue)
if ($dart) { ok "dart: $($dart.Source)" } else { err "dart not on PATH"; }

Write-Host "`n=== Files exist ===" -ForegroundColor Cyan
(Test-Path $dev)   ? (ok  "dev entry: $dev")     : (err "missing $dev")
(Test-Path $quick) ? (ok  "screen:    $quick")   : (err "missing $quick")
(Test-Path $opts)  ? (ok  "firebase_options.dart") : (warn "firebase_options.dart not found (run flutterfire configure)")
(Test-Path $rules) ? (ok  "firestore.rules")     : (warn "firestore.rules not found")
(Test-Path $idx)   ? (ok  "firestore.indexes.json") : (warn "firestore.indexes.json not found")
(Test-Path $bat)   ? (ok  "triage_quick_visit.bat") : (warn "triage_quick_visit.bat not found")
(Test-Path $ps1)   ? (ok  "tools\triage_quick_visit.ps1") : (warn "tools\triage_quick_visit.ps1 not found")

Write-Host "`n=== dev_quick_visit.dart checks ===" -ForegroundColor Cyan
if (Test-Path $dev) {
  $d = Get-Content $dev -Raw
  if ($d -match 'Firebase\.initializeApp') { ok "initializes Firebase" } else { warn "no Firebase.initializeApp in dev entry" }
  if ($d -match 'FirebaseAuth\.instance\.signInAnonymously') { ok "anonymous auth present" } else { warn "anonymous auth not found" }
  if ($d -match 'PopScope') { ok "PopScope present (blocks accidental back)" } else { warn "PopScope not found" }
  if ($d -match 'QuickVisitScreen') { ok "launches QuickVisitScreen" } else { err "does not launch QuickVisitScreen" }
}

Write-Host "`n=== quick_visit_screen.dart checks ===" -ForegroundColor Cyan
if (Test-Path $quick) {
  $q = Get-Content $quick -Raw

  # Portion picker wiring
  if ($q -match 'PortionSizePicker\(') { ok "PortionSizePicker is used" } else { warn "PortionSizePicker missing" }
  if ($q -match 'initialValue:\s*_portion') { ok "PortionSizePicker.initialValue uses _portion" } else { warn "initialValue not bound to _portion" }
  if ($q -match 'onChanged:\s*\(p\)\s*=>\s*setState\(\s*\{\s*_portion\s*=\s*p') { ok "onChanged assigns Portion p into _portion" } else { warn "onChanged may not assign Portion p into _portion" }

  # Save button handler
  if ($q -match 'Future<void>\s+_onSavePressed\(\)\s+async') { ok "_onSavePressed handler exists" } else { warn "_onSavePressed not found" }
  if ($q -match 'onPressed:\s*_onSavePressed') { ok "Save button wired to _onSavePressed" } else { warn "Save button may not be wired to _onSavePressed" }

  # No programmatic pops (dev safety)
  if ($q -match 'Navigator\.(?:of\(context\)\.)?(?:pop|maybePop)\(' -or $q -match 'context\.pop\(') { 
    warn "Found a Navigator.pop/maybePop/context.pop — could close the only route"
  } else { ok "No programmatic pop/maybePop/context.pop in this screen" }

  # Save path (stub or direct write)
  if ($q -match 'STUB SAVE') { ok "_saveVisit is a STUB (no Firebase write)" }
  elseif ($q -match 'FirebaseFirestore\.instance\.collection\("visits"\)') { ok "_saveVisit writes directly to visits (bypasses repo)" }
  else { warn "Could not determine _saveVisit behavior" }
}

Write-Host "`n=== firebase_options.dart check ===" -ForegroundColor Cyan
if (Test-Path $opts) {
  $o = Get-Content $opts -Raw
  if ($o -match 'class\s+DefaultFirebaseOptions') { ok "DefaultFirebaseOptions class present" } else { warn "DefaultFirebaseOptions not found" }
}

Write-Host "`n=== firestore.rules BOM check ===" -ForegroundColor Cyan
if (Test-Path $rules) {
  $bytes = [System.IO.File]::ReadAllBytes($rules)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    warn "firestore.rules has a UTF-8 BOM (can cause compile error). Re-save as UTF-8 (no BOM)."
  } else { ok "firestore.rules has no BOM" }
}

Write-Host "`n=== flutter analyze (targeted) ===" -ForegroundColor Cyan
if ($flutter) {
  Push-Location $root
  try {
    flutter analyze $dev $quick
  } finally {
    Pop-Location
  }
} else {
  warn "flutter not on PATH; skipped analyze"
}

Write-Host "`nDone." -ForegroundColor Cyan
# ---------------------------------------------------------------------------
