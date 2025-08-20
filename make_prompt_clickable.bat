@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set P=lib\main.dart
if not exist "%P%" (
  echo [X] %P% not found. Run this from your Flutter project root.
  exit /b 1
)

echo [.] Backing up lib\main.dart to lib\main.dart.bak
copy /y "%P%" "lib\main.dart.bak" >nul

:: Replace the prompt Center(...) block that contains _prompt with a TextButton.icon
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p='%P%';" ^
  "$c=[IO.File]::ReadAllText($p,[Text.Encoding]::UTF8);" ^
  "$pattern='Center\((?:.|\r|\n)*?_prompt(?:.|\r|\n)*?Center\)';" ^
  "$replacement=@'
Center(
  child: TextButton.icon(
    onPressed: () async {
      final List<String>? picked = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CravingScreen()),
      );
      if (picked != null && picked.isNotEmpty) {
        setState(() {
          for (final p in picked) {
            if (!_wants.contains(p)) _wants.add(p);
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
  ),
),
'@;" ^
  "$c2=[Text.RegularExpressions.Regex]::Replace($c,$pattern,$replacement,[Text.RegularExpressions.RegexOptions]::Singleline);" ^
  "if($c2 -eq $c){Write-Host '[!] Could not find the prompt block to replace. No changes made.'; exit 2}" ^
  "[IO.File]::WriteAllText($p,$c2,[Text.UTF8Encoding]::new($false));" ^
  "Write-Host '[OK] Prompt made clearly clickable.'"

if errorlevel 2 (
  echo.
  echo [!] I couldn't auto-find the prompt Center(...). Two options:
  echo     A) Make sure the prompt block still contains "_prompt" inside a Center(...), then re-run.
  echo     B) Manually replace your prompt Row with a TextButton.icon as we discussed.
  exit /b 2
)

echo.
echo === Build and run ===
flutter run -d windows
endlocal
