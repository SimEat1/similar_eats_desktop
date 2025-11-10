# patch_maps_phase2.ps1
# - Adds lib/shared/geo/map_open.dart (if missing)
# - Wires "Open in Maps" action into DinnerScreen & ExploreMapScreen
# - Creates backups *.bak for edited files

$ErrorActionPreference = "Stop"

function Backup-And-Write($path, $content) {
  if (Test-Path $path) { Copy-Item $path "$path.bak" -Force; Write-Host "Backup: $path -> $path.bak" }
  New-Item -ItemType File -Path $path -Force | Out-Null
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# --- A) map_open.dart (helper) ---
$mapOpenPath = "lib\shared\geo\map_open.dart"
if (-not (Test-Path $mapOpenPath)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $mapOpenPath) | Out-Null
  $mapOpen = @'
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

Future<void> openMapSearch(String query) async {
  final q = Uri.encodeComponent(query.isEmpty ? 'restaurants near me' : query);

  final Uri iosApple = Uri.parse('http://maps.apple.com/?q=$q');
  final Uri iosScheme = Uri.parse('maps://?q=$q');

  final Uri androidGoogle = Uri.parse('geo:0,0?q=$q');
  final Uri webGoogle = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');

  try {
    if (Platform.isIOS) {
      if (await canLaunchUrl(iosScheme)) {
        await launchUrl(iosScheme, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(iosApple, mode: LaunchMode.externalApplication);
      return;
    }
    if (Platform.isAndroid) {
      if (await canLaunchUrl(androidGoogle)) {
        await launchUrl(androidGoogle, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(webGoogle, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {}
  await launchUrl(webGoogle, mode: LaunchMode.externalApplication);
}

Future<void> openMapDirections({ double? lat, double? lng, String label = '' }) async {
  final hasCoords = lat != null && lng != null;
  final ll = hasCoords ? '$lat,$lng' : '';
  final encLabel = Uri.encodeComponent(label);

  final Uri iosApple = hasCoords
    ? Uri.parse('http://maps.apple.com/?daddr=$ll&dirflg=d')
    : Uri.parse('http://maps.apple.com/?daddr=$encLabel&dirflg=d');

  final Uri iosScheme = hasCoords
    ? Uri.parse('maps://?daddr=$ll&dirflg=d')
    : Uri.parse('maps://?daddr=$encLabel&dirflg=d');

  final Uri androidGoogle = hasCoords
    ? Uri.parse('google.navigation:q=$ll')
    : Uri.parse('google.navigation:q=$encLabel');

  final Uri webGoogle = hasCoords
    ? Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$ll')
    : Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encLabel');

  try {
    if (Platform.isIOS) {
      if (await canLaunchUrl(iosScheme)) {
        await launchUrl(iosScheme, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(iosApple, mode: LaunchMode.externalApplication);
      return;
    }
    if (Platform.isAndroid) {
      if (await canLaunchUrl(androidGoogle)) {
        await launchUrl(androidGoogle, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(webGoogle, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {}
  await launchUrl(webGoogle, mode: LaunchMode.externalApplication);
}
'@
  Backup-And-Write $mapOpenPath $mapOpen
} else {
  Write-Host "map_open.dart already exists — leaving as-is."
}

# --- B) DinnerScreen: add AppBar action ---
$dinnerPath = "lib\features\dinner\dinner_screen.dart"
if (Test-Path $dinnerPath) {
  $dinner = Get-Content -Raw $dinnerPath

  if ($dinner -notmatch "shared/geo/map_open.dart") {
    $dinner = $dinner -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
      "`$1import 'package:similar_eats_desktop/shared/geo/map_open.dart';`r`n"
    Write-Host "Added import to DinnerScreen."
  }

  # Try to inject an AppBar action (map button). Handle two common patterns.
  if ($dinner -match "AppBar\(" -and $dinner -notmatch "openMapSearch") {
    # If there is already actions: [ ... ]
    if ($dinner -match "actions\s*:\s*\[") {
      $dinner = $dinner -replace "actions\s*:\s*\[",
        "actions: [`r`n          IconButton(tooltip: 'Open in Maps', icon: const Icon(Icons.map_outlined), onPressed: () => openMapSearch('restaurants near me'),),"
      Write-Host "Injected map IconButton into existing Dinner AppBar actions."
    } else {
      # Add actions: [] to the AppBar
      $dinner = $dinner -replace "AppBar\(",
        "AppBar(actions: [IconButton(tooltip: 'Open in Maps', icon: const Icon(Icons.map_outlined), onPressed: () => openMapSearch('restaurants near me'),)],"
      Write-Host "Added actions to Dinner AppBar."
    }
  }

  Backup-And-Write $dinnerPath $dinner
} else {
  Write-Host "DinnerScreen not found, skipping ($dinnerPath)."
}

# --- C) ExploreMapScreen: add AppBar action ---
$explorePath = "lib\features\explore\explore_map_screen.dart"
if (Test-Path $explorePath) {
  $explore = Get-Content -Raw $explorePath

  if ($explore -notmatch "shared/geo/map_open.dart") {
    $explore = $explore -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
      "`$1import 'package:similar_eats_desktop/shared/geo/map_open.dart';`r`n"
    Write-Host "Added import to ExploreMapScreen."
  }

  if ($explore -match "AppBar\(" -and $explore -notmatch "openMapSearch") {
    if ($explore -match "actions\s*:\s*\[") {
      $explore = $explore -replace "actions\s*:\s*\[",
        "actions: [`r`n          IconButton(tooltip: 'Nearby', icon: const Icon(Icons.location_searching), onPressed: () => openMapSearch('restaurants near me'),"
      Write-Host "Injected Nearby IconButton into existing Explore AppBar actions."
    } else {
      $explore = $explore -replace "AppBar\(",
        "AppBar(actions: [IconButton(tooltip: 'Nearby', icon: const Icon(Icons.location_searching), onPressed: () => openMapSearch('restaurants near me'),)],"
      Write-Host "Added actions to Explore AppBar."
    }
  }

  Backup-And-Write $explorePath $explore
} else {
  Write-Host "ExploreMapScreen not found, skipping ($explorePath)."
}

Write-Host "`nDone. Now run: flutter pub get && flutter run -d windows"


