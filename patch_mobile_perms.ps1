# Run from project root in PowerShell:  .\patch_mobile_perms.ps1

$android = "android\app\src\main\AndroidManifest.xml"
$ios = "ios\Runner\Info.plist"

if (Test-Path $android) {
  Write-Host "Patching AndroidManifest.xml..."
  $xml = Get-Content $android -Raw
  if ($xml -notmatch "ACCESS_FINE_LOCATION") {
    $xml = $xml -replace "<manifest", "<manifest`n    <uses-permission android:name=`"android.permission.ACCESS_FINE_LOCATION`"/>`n    <uses-permission android:name=`"android.permission.ACCESS_COARSE_LOCATION`"/>`n    <uses-permission android:name=`"android.permission.ACCESS_BACKGROUND_LOCATION`"/>`n    <uses-permission android:name=`"android.permission.POST_NOTIFICATIONS`"/>`n    <uses-permission android:name=`"android.permission.FOREGROUND_SERVICE`"/>"
    Set-Content -Encoding UTF8 $android $xml
  }
}

if (Test-Path $ios) {
  Write-Host "Patching Info.plist..."
  $plist = Get-Content $ios -Raw
  if ($plist -notmatch "NSLocationWhenInUseUsageDescription") {
    $inserts = @"
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>We use your location to recognize restaurant visits and improve suggestions.</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Allow background location so we can detect visits even when the app is closed.</string>
  <key>NSLocationAlwaysUsageDescription</key>
  <string>We detect restaurant visits in the background to personalize results.</string>
  <key>NSUserNotificationUsageDescription</key>
  <string>We’ll send a nudge to confirm visits.</string>
"@
    $plist = $plist -replace "</dict>", "$inserts`n</dict>"
    Set-Content -Encoding UTF8 $ios $plist
  }
}

Write-Host "Done."
