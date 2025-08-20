@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • Make assets + run

echo.
echo === Step 1/3: Ensure assets/ exists & generate thumbnails ===
if not exist "assets" mkdir assets

REM Use PowerShell/.NET to create 4 PNG thumbnails with text
powershell -NoProfile -Command ^
  "$thumbs = @(@{Name='spicy.png';    Bgr='#F25C54'; Label='Spicy Palace'}, ^
               @{Name='fried.png';    Bgr='#2AB07E'; Label='Crispy Corner'}, ^
               @{Name='pizza.png';    Bgr='#FDBF2D'; Label='Cheesy Bites'}, ^
               @{Name='dessert.png';  Bgr='#3D63FF'; Label='Sweet Spoon'}); ^
   Add-Type -AssemblyName System.Drawing; ^
   foreach($t in $thumbs){ ^
     $bmp = New-Object System.Drawing.Bitmap 640,400; ^
     $g = [System.Drawing.Graphics]::FromImage($bmp); ^
     $g.SmoothingMode = 'HighQuality'; ^
     $g.Clear([System.Drawing.ColorTranslator]::FromHtml($t.Bgr)); ^
     $font1 = New-Object System.Drawing.Font('Segoe UI Semibold', 42); ^
     $font2 = New-Object System.Drawing.Font('Segoe UI', 20); ^
     $white = [System.Drawing.Brushes]::White; ^
     $shadow = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(40,0,0,0)); ^
     $g.FillRectangle($shadow, 20, 290, 600, 60); ^
     $g.DrawString($t.Label, $font1, $white, 28, 150); ^
     $g.DrawString('Similar Eats', $font2, $white, 28, 300); ^
     $out = Join-Path (Join-Path $pwd 'assets') $t.Name; ^
     $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png); ^
     $g.Dispose(); $bmp.Dispose(); ^
   }"

echo.
echo === Step 2/3: Flutter deps ===
flutter pub get || goto :fail

echo.
echo === Step 3/3: Launch (Windows) ===
flutter run -d windows
goto :eof

:fail
echo [X] Something failed. Check the messages above.
exit /b 1
