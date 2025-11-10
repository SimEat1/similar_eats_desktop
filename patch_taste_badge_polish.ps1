# patch_taste_badge_polish.ps1
# - Adds lib/shared/widgets/taste_badge.dart
# - Inserts TasteBadge under the main welcome title

$ErrorActionPreference = "Stop"

function Backup-And-Write($path, $content) {
  if (Test-Path $path) { Copy-Item $path "$path.bak" -Force; Write-Host "Backup: $path -> $path.bak" }
  New-Item -ItemType File -Path $path -Force | Out-Null
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# --- A) taste_badge.dart ---
$badgePath = "lib\shared\widgets\taste_badge.dart"
New-Item -ItemType Directory -Force -Path (Split-Path $badgePath) | Out-Null
$badge = @'
import "package:flutter/material.dart";

class TasteBadge extends StatelessWidget {
  final String tasteType; // e.g., "Spice Chaser"
  const TasteBadge({super.key, required this.tasteType});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = LinearGradient(
      colors: [cs.primary.withOpacity(.12), cs.secondary.withOpacity(.12)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final icon = _iconFor(tasteType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            tasteType,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  String _iconFor(String t) {
    final s = t.toLowerCase();
    if (s.contains("spice")) return "🌶️";
    if (s.contains("sweet")) return "🍰";
    if (s.contains("sour"))  return "🍋";
    if (s.contains("umami")) return "🍜";
    if (s.contains("salty")) return "🥨";
    return "🍽️";
    }
}
'@
Backup-And-Write $badgePath $badge

# --- B) Insert into WelcomeScreen ---
$welcomePath = "lib\features\home\welcome_screen.dart"
if (!(Test-Path $welcomePath)) { throw "Missing $welcomePath" }
$w = Get-Content -Raw $welcomePath

if ($w -notmatch "shared/widgets/taste_badge.dart") {
  $w = $w -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:similar_eats_desktop/shared/widgets/taste_badge.dart';`r`n"
  Write-Host "Added taste_badge import to welcome_screen.dart"
}

# After the main title "What's for dinner?", inject the badge row
if ($w -match "What's for dinner\?") {
  $w = $w -replace "(Text\(\"What's for dinner\?\"[^\n]*\)\s*,\s*\n\s*const SizedBox\(height:\s*8\),)",
    "$1`r`n          Row(children:[TasteBadge(tasteType: 'Spice Chaser'), SizedBox(width:8), TasteBadge(tasteType:'Umami Fan')],),`r`n          const SizedBox(height: 8),"
  Write-Host "Inserted TasteBadge row beneath the title."
}

Backup-And-Write $welcomePath $w

Write-Host "`nDone. Run: flutter run -d windows"
