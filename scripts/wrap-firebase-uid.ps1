Write-Host "== Similar Eats: wrap Firebase UID with PlatformHelper ==" -ForegroundColor Cyan

$files = Get-ChildItem -Path .\lib -Recurse -Include *.dart
$needle = 'FirebaseAuth\.instance\.currentUser\?\.uid'
$changed = @()

foreach ($f in $files) {
  $content = Get-Content -Raw -Path $f.FullName
  if ($content -match $needle) {
    Write-Host "  ~ $($f.FullName)" -ForegroundColor Yellow

    # ensure import
    $import = "import 'core/platform/platform_helper.dart';"
    if ($content -notmatch [regex]::Escape($import)) {
      if ($content -match "^(import\s+['""][^;]+['""];\s*)+") {
        $content = $content -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
      } else {
        $content = $import + "`r`n" + $content
      }
    }

    # wrap occurrences
    $content = [regex]::Replace(
      $content,
      $needle,
      "PlatformHelper.getCurrentUid(firebaseUid: FirebaseAuth.instance.currentUser?.uid)"
    )

    Set-Content -Encoding UTF8 -Path $f.FullName -Value $content
    $changed += $f.FullName
    Write-Host "    ✓ wrapped" -ForegroundColor Green
  }
}

if ($changed.Count -eq 0) {
  Write-Host "  = No direct Firebase UID usages found to wrap." -ForegroundColor DarkGray
} else {
  Write-Host "`n  ✓ Updated $($changed.Count) file(s)." -ForegroundColor Green
  $changed | ForEach-Object { Write-Host "    - $_" -ForegroundColor DarkGray }
}
