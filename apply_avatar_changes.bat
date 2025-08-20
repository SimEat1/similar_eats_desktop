@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Apply avatar changes (Similar Eats Desktop)

echo === Similar Eats Desktop • APPLY AVATAR CHANGES ===

if not exist "lib\main.dart" (
  echo [X] lib\main.dart not found. Are you in C:\projects\similar_eats_desktop ?
  pause
  exit /b 1
)

rem Backup once
if not exist "lib\main.dart.bak" (
  copy /y "lib\main.dart" "lib\main.dart.bak" >nul
  echo [OK] Backed up lib\main.dart -> lib\main.dart.bak
)

echo [>] Patching main.dart with avatar helpers...
powershell -NoLogo -NoProfile -Command ^
  "$p = 'lib/main.dart';" ^
  "$c = Get-Content -Raw $p;" ^
  "if ($c -notmatch 'Color _avatarColorFrom') {" ^
  "  $helper = @'" ^
  "`n// ---- Avatar helpers (auto-inserted) ----" ^
  "`nColor _avatarColorFrom(String text) {" ^
  "`n  final h = text.runes.fold(0,(a,b)=>a+b);" ^
  "`n  final colors = <MaterialColor>[Colors.orange, Colors.teal, Colors.indigo, Colors.pink, Colors.green, Colors.brown];" ^
  "`n  return colors[h %% colors.length].shade200;" ^
  "`n}" ^
  "`n" ^
  "`nWidget buildAvatar(String label, {String? emoji}) {" ^
  "`n  return CircleAvatar(" ^
  "`n    backgroundColor: _avatarColorFrom(label)," ^
  "`n    child: Text(emoji ?? label.characters.first," ^
  "`n      style: const TextStyle(fontWeight: FontWeight.w700))," ^
  "`n  );" ^
  "`n}" ^
  "`n// ---- /Avatar helpers ----`n'@;" ^
  "  $c = $c -replace \"import 'package:flutter/material.dart';\", \"import 'package:flutter/material.dart';`n$helper\";" ^
  "}" ^
  "  $c = $c -replace '\bconst CircleAvatar\(child:\s*Icon\(Icons\.restaurant\)\)\b', 'buildAvatar(r.name, emoji: \"🍽️\")';" ^
  "  $c = $c -replace 'CircleAvatar\([^)]*Text\(u\.name\.characters\.first\)[^)]*\)', 'buildAvatar(u.name)';" ^
  "Set-Content -NoNewline -Encoding UTF8 $p $c;" ^
  "Write-Host '[OK] Avatar helpers applied.'"

if errorlevel 1 (
  echo [X] Patch failed.
  pause
  exit /b 1
)

echo [OK] Done.
exit /b 0


