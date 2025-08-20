@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem --- Ensure the PowerShell patch file exists ---
if not exist "patch_prompt.ps1" (
  echo [.] Creating patch_prompt.ps1...
  powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
    "$s = @'
$ErrorActionPreference = 'Stop'
$p = 'lib/main.dart'
if (-not (Test-Path $p)) { Write-Host '[X] ' + $p + ' not found'; exit 1 }
$text = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)

if ($text -match 'TextButton\.icon') {
  Write-Host '[OK] Prompt already clickable. No change.'
  exit 0
}

$pattern = 'Text\(\s*_prompt\b.*?\)'
$replacement = @'
TextButton.icon(
  onPressed: () async {
    final List<String>? picked = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CravingScreen()),
    );
    if (picked != null && picked.isNotEmpty) {
      setState(() {
        for (final p in picked) {
          if (!_wants.contains(p)) { _wants.add(p); }
          }
      });
    }
  },
  icon: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFF25C54)),
  label: Text(
    _prompt,
    style: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: Color(0xFFF25C54),
    ),
  ),
  style: TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    foregroundColor: const Color(0xFFF25C54),
    overlayColor: const Color(0x1AF25C54),
  ),
)
'@

$new = [System.Text.RegularExpressions.Regex]::Replace(
  $text, $pattern, $replacement,
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)

if ($new -eq $text) {
  Write-Host '[!] Could not find Text(_prompt ...) to replace. No changes applied.'
  exit 2
}

Copy-Item $p "$p.bak" -ErrorAction SilentlyContinue | Out-Null
[System.IO.File]::WriteAllText($p, $new, [System.Text.UTF8Encoding]::new($false))
Write-Host '[OK] Prompt patched to a clickable button.'
'@; Set-Content -Path '.\patch_prompt.ps1' -Value $s -Encoding UTF8"
  if errorlevel 1 (
    echo [X] Failed creating patch_prompt.ps1
    exit /b 1
  )
)

rem --- Run the patch ---
echo [.] Patching prompt...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\patch_prompt.ps1"
if errorlevel 2 (
  echo [!] Patch could not find Text(_prompt ...). If you edited that area, tell me and I will tweak the matcher.
)
if errorlevel 1 (
  echo [X] Patch failed.
  exit /b 1
)

rem --- Build & run ---
echo.
echo [.] flutter run -d windows
flutter run -d windows
endlocal
