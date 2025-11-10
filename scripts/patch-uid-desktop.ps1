param([switch]$WhatIf)

Write-Host "== Similar Eats: Patch uid for desktop ==" -ForegroundColor Cyan

# 1) Ensure helper exists
$helperDir = ".\lib\core\platform"
$helperFile = Join-Path $helperDir "platform_helper.dart"
New-Item -ItemType Directory -Force -Path $helperDir | Out-Null
if (-not (Test-Path $helperFile)) {
@"
import "dart:io" show Platform;
import "package:flutter/foundation.dart";

class PlatformHelper {
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// For desktop dev returns "desktop-mock". On mobile/web pass FirebaseAuth uid.
  static String? getCurrentUid({String? firebaseUid}) {
    if (isDesktop) return "desktop-mock";
    return firebaseUid;
  }
}
"@ | Set-Content -Encoding UTF8 $helperFile
  Write-Host "  + Created $helperFile" -ForegroundColor Green
} else {
  Write-Host "  = Found $helperFile" -ForegroundColor DarkGray
}

# 2) Find dart files with uid: null or 'uid': null
$dartFiles = Get-ChildItem -Path .\lib -Recurse -Include *.dart
$pattern1 = "(?<quote>['""]?)uid\k<quote>\s*:\s*null"  # matches uid: null OR 'uid': null

$changed = @()
foreach ($f in $dartFiles) {
  $content = Get-Content -Raw -Path $f.FullName
  if ($content -match $pattern1) {
    Write-Host "  ~ Patching $($f.FullName)" -ForegroundColor Yellow

    # 2a) Ensure import present
    $import = "import 'core/platform/platform_helper.dart';"
    if ($content -notmatch [regex]::Escape($import)) {
      # Insert after last existing import or at top
      if ($content -match "^(import\s+['""][^;]+['""];\s*)+") {
        $content = $content -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
      } else {
        $content = $import + "`r`n" + $content
      }
    }

    # 2b) Replace uid: null inline (safe, no extra local var needed)
    $replacement = "uid: PlatformHelper.getCurrentUid(firebaseUid: null)"
    $replacementQuoted = "'uid': PlatformHelper.getCurrentUid(firebaseUid: null)"
    $content = $content `
      -replace "uid\s*:\s*null", $replacement `
      -replace "'uid'\s*:\s*null", $replacementQuoted

    if ($WhatIf) {
      Write-Host "    (WhatIf) would modify file" -ForegroundColor DarkGray
    } else {
      Set-Content -Encoding UTF8 -Path $f.FullName -Value $content
      $changed += $f.FullName
      Write-Host "    ✓ updated" -ForegroundColor Green
    }
  }
}

if ($changed.Count -eq 0) {
  Write-Host "  = No 'uid: null' occurrences found. Nothing to patch." -ForegroundColor DarkGray
} else {
  Write-Host "  ✓ Patched $($changed.Count) file(s)." -ForegroundColor Green
  $changed | ForEach-Object { Write-Host "    - $_" -ForegroundColor DarkGray }
}

Write-Host "`nDone. Rebuild to verify logs show uid: desktop-mock" -ForegroundColor Cyan
