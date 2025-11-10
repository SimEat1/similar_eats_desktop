<#  Quick Visit desktop triage helper
    Usage examples (run from repo root):
      pwsh ./tools/triage_quick_visit.ps1 -SearchOnly
      pwsh ./tools/triage_quick_visit.ps1 -AddHeartbeat
      pwsh ./tools/triage_quick_visit.ps1 -ToggleFirebase Off
      pwsh ./tools/triage_quick_visit.ps1 -RunDev
#>

param(
  [switch]$SearchOnly,
  [switch]$AddHeartbeat,
  [switch]$RemoveHeartbeat,
  [ValidateSet("On","Off")] [string]$ToggleFirebase,
  [switch]$PatchErrorWidget,
  [switch]$RunMini,
  [switch]$RunDev
)

$ErrorActionPreference = "Stop"
$quick = "lib/features/visits/screens/quick_visit_screen.dart"
$dev   = "lib/dev_quick_visit.dart"

function Require($p){ if(!(Test-Path $p)){ throw "Missing $p" } }

function SearchTerminators {
  Write-Host "`n— Searching for termination/navigation killers —"
  $patterns = @(
    'SystemNavigator\.pop','exit\(','pushReplacement','pushAndRemoveUntil',
    'popUntil','Navigator\.(?:maybePop|pop)\(','context\.pop\('
  )
  foreach($pat in $patterns){
    Select-String -Path .\lib\**\*.dart -Pattern $pat -SimpleMatch `
      | % { "$($_.Path):$($_.LineNumber): $($_.Line.Trim())" }
  }
  Write-Host "— Done —`n"
}

function InsertHeartbeat {
  Require $quick
  $src = Get-Content $quick -Raw
  if($src -match "Timer\.periodic\("){
    Write-Host "Heartbeat already present."
    return
  }
  $src = [regex]::Replace($src,
    "(?s)await\s+_saveVisit\([^)]*\);\s*",
    @"
await _saveVisit(payload);
Timer.periodic(const Duration(seconds: 1), (t) {
  debugPrint('still alive tick ' + t.tick.toString());
});
"@, 1)
  $src | Set-Content $quick -Encoding UTF8
  dart format $quick | Out-Host
  Write-Host "Heartbeat inserted."
}

function RemoveHeartbeatFn {
  Require $quick
  (Get-Content $quick -Raw) `
    -replace "(?s)Timer\.periodic\([^)]*\);\s*", "" `
  | Set-Content $quick -Encoding UTF8
  dart format $quick | Out-Host
  Write-Host "Heartbeat removed."
}

function PatchErrorWidgetFn {
  Require $dev
  $txt = Get-Content $dev -Raw
  if($txt -notmatch "ErrorWidget\.builder"){
    $txt = $txt -replace "WidgetsFlutterBinding\.ensureInitialized\(\);\s*",
@"
WidgetsFlutterBinding.ensureInitialized();

// Show red text instead of a blank screen on build errors.
ErrorWidget.builder = (details) {
  debugPrint('ErrorWidget: ' + details.exceptionAsString());
  return Material(
    color: Colors.black,
    child: Center(
      child: Text(
        'UI error:\n' + details.exceptionAsString(),
        style: const TextStyle(color: Colors.redAccent),
        textAlign: TextAlign.center,
      ),
    ),
  );
};
"@
    $txt | Set-Content $dev -Encoding UTF8
    dart format $dev | Out-Host
    Write-Host "ErrorWidget patch applied."
  } else {
    Write-Host "ErrorWidget patch already present."
  }
}

function ToggleFirebaseFn([string]$mode){
  Require $dev
  $txt = Get-Content $dev -Raw
  if($mode -eq "Off"){
    if($txt -notmatch "// TRIAGE: FIREBASE OFF"){
      $txt = $txt -replace "(?s)await Firebase\.initializeApp\([^;]*\);\s*", "// TRIAGE: FIREBASE OFF`n" `
                   -replace "(?s)await FirebaseAuth\.instance\.signInAnonymously\(\);", "// TRIAGE: FIREBASE OFF"
      $txt | Set-Content $dev -Encoding UTF8
      dart format $dev | Out-Host
      Write-Host "Firebase disabled for desktop triage."
    } else { Write-Host "Firebase already disabled." }
  } else {
    # Re-insert minimal init if it was commented out
    if($txt -match "// TRIAGE: FIREBASE OFF"){
      $txt = (Get-Content $dev -Raw) `
        -replace "// TRIAGE: FIREBASE OFF\s*", ""
      $txt | Set-Content $dev -Encoding UTF8
      dart format $dev | Out-Host
      Write-Host "Firebase re-enabled."
    } else { Write-Host "Firebase already enabled." }
  }
}

function RunMiniFn {
@'
import "package:flutter/material.dart";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: _Mini()));
}
class _Mini extends StatefulWidget { const _Mini({super.key}); @override State<_Mini> createState()=>_S(); }
class _S extends State<_Mini>{
  @override Widget build(BuildContext c)=>Scaffold(
    appBar: AppBar(title: const Text("Mini")),
    body: Center(child: ElevatedButton(
      onPressed: (){ debugPrint("Pressed"); setState((){}); },
      child: const Text("Press"),
    )),
  );
}
'@ | Set-Content lib/dev_min.dart -Encoding UTF8
  dart format lib/dev_min.dart | Out-Host
  flutter run -d windows -t lib/dev_min.dart
}

function RunDevFn { flutter run -d windows -t $dev }

# ----- Execute requested actions -----
if($SearchOnly){ SearchTerminators }
if($AddHeartbeat){ InsertHeartbeat }
if($RemoveHeartbeat){ RemoveHeartbeatFn }
if($PatchErrorWidget){ PatchErrorWidgetFn }
if($ToggleFirebase){ ToggleFirebaseFn $ToggleFirebase }
if($RunMini){ RunMiniFn }
if($RunDev){ RunDevFn }

if(-not ($SearchOnly -or $AddHeartbeat -or $RemoveHeartbeat -or $PatchErrorWidget -or $ToggleFirebase -or $RunMini -or $RunDev)){
  Write-Host @"
No action chosen. Common invocations:

  pwsh ./tools/triage_quick_visit.ps1 -SearchOnly
  pwsh ./tools/triage_quick_visit.ps1 -AddHeartbeat
  pwsh ./tools/triage_quick_visit.ps1 -PatchErrorWidget
  pwsh ./tools/triage_quick_visit.ps1 -ToggleFirebase Off
  pwsh ./tools/triage_quick_visit.ps1 -RunDev
"@
}
