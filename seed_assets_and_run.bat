@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • seed assets + run

echo [1/4] Creating assets folder (if missing)...
if not exist "assets" mkdir assets

echo [2/4] Generating 4 placeholder JPGs (food1..food4)...
powershell -NoLogo -NoProfile -Command ^
  "$images = @('food1.jpg','food2.jpg','food3.jpg','food4.jpg');" ^
  "Add-Type -AssemblyName System.Drawing;" ^
  "$colors = @(" ^
  "  [System.Drawing.Color]::FromArgb(255,238,108,77)," ^
  "  [System.Drawing.Color]::FromArgb(255,255,190,11)," ^
  "  [System.Drawing.Color]::FromArgb(255,87,199,133)," ^
  "  [System.Drawing.Color]::FromArgb(255,52,120,246)" ^
  ");" ^
  "for($i=0;$i -lt $images.Count;$i++){" ^
  "  $bmp = New-Object System.Drawing.Bitmap 1200,800;" ^
  "  $g=[System.Drawing.Graphics]::FromImage($bmp);" ^
  "  $g.Clear($colors[$i]);" ^
  "  $font = New-Object System.Drawing.Font 'Segoe UI', 48;" ^
  "  $brush = [System.Drawing.Brushes]::White;" ^
  "  $g.DrawString('Similar Eats', $font, $brush, 50, 350);" ^
  "  $g.Dispose();" ^
  "  $bmp.Save((Join-Path 'assets' $images[$i]), [System.Drawing.Imaging.ImageFormat]::Jpeg);" ^
  "  $bmp.Dispose();" ^
  "}"

echo [3/4] Ensuring pubspec.yaml includes 'assets/'...
powershell -NoLogo -NoProfile -Command ^
  "$p='pubspec.yaml';" ^
  "$c=Get-Content -Raw $p;" ^
  "if($c -notmatch 'assets:\s*\r?\n\s*-\s*assets/'){" ^
  "  $c = $c -replace 'uses-material-design:\s*true','uses-material-design: true`n  assets:`n    - assets/';" ^
  "  Set-Content -NoNewline $p $c;" ^
  "  Write-Host '  -> Updated pubspec.yaml assets section.';" ^
  "} else { Write-Host '  -> pubspec.yaml already has assets/'; }"

echo [4/4] Building & launching...
flutter clean
flutter pub get
flutter run -d windows
