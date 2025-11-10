# patch_android_kts.ps1
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Patch-File {
  param([string]$path, [scriptblock]$mutate)
  if (!(Test-Path $path)) { throw "Missing $path" }
  $orig = Get-Content -Raw -Encoding UTF8 $path
  $new  = & $mutate $orig
  if ($new -ne $orig) {
    Copy-Item $path "$path.bak" -Force
    Set-Content -Path $path -Value $new -Encoding UTF8 -NoNewline
    Write-Host "Patched: $path"
  } else {
    Write-Host "No changes needed: $path"
  }
}

# -------------- Project-level build.gradle.kts --------------
$proj = "android\build.gradle.kts"
Patch-File $proj {
  param($t)
  # Ensure Google Services classpath
  if ($t -notmatch 'com\.google\.gms:google-services:') {
    $t = $t -replace '(?s)dependencies\s*\{',
      "dependencies {
        classpath(""com.google.gms:google-services:4.4.2"")
"
    $t = $t -replace '(?s)repositories\s*\{([^}]*)\}',
      { param($m) "repositories {$($m.Groups[1].Value)`n        google()`n        mavenCentral()`n    }" }
    Write-Host "  + Added google-services classpath and ensured repos"
  }
  return $t
}

# -------------- App-level build.gradle.kts --------------
$app = "android\app\build.gradle.kts"
Patch-File $app {
  param($t)
  # Make sure plugins block has google-services
  if ($t -notmatch 'id\("com\.google\.gms\.google-services"\)') {
    if ($t -match '(?s)plugins\s*\{[^}]*\}') {
      $t = $t -replace '(?s)(plugins\s*\{)([^}]*)\}',
        '$1$2
    id("com.google.gms.google-services")
}'
      Write-Host "  + Applied com.google.gms.google-services plugin"
    } else {
      $t = "plugins {
    id(""com.android.application"")
    id(""org.jetbrains.kotlin.android"")
    id(""com.google.gms.google-services"")
}
$t"
      Write-Host "  + Created plugins block"
    }
  }

  # Ensure android {} has sane SDK versions
  if ($t -notmatch 'compileSdk') {
    $t = $t -replace '(?s)android\s*\{',
      "android {
    namespace = ""com.similareats.app""
    compileSdk = 35
    defaultConfig {
        applicationId = ""com.similareats.app""
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = ""1.0""
    }"
    Write-Host "  + Inserted compileSdk/target/min/appId defaults"
  }

  # Ensure kotlinOptions / Java 17 (works with recent Android Studio)
  if ($t -notmatch 'java\.toolchain') {
    $t = $t -replace '(?s)android\s*\{([^}]*)\}',
      { param($m)
        $body = $m.Groups[1].Value
"android {
$body

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = ""17""
    }
    packaging {
        resources {
            excludes += ""META-INF/AL2.0""
            excludes += ""META-INF/LGPL2.1""
        }
    }
}"
      }
    Write-Host "  + Ensured Java/Kotlin 17 toolchain and packaging excludes"
  }

  # Ensure repositories (just in case)
  if ($t -notmatch 'mavenCentral') {
    $t = $t + @"

repositories {
    google()
    mavenCentral()
}
"@
    Write-Host "  + Added repositories block"
  }

  return $t
}

# -------------- AndroidManifest (permissions) --------------
$man = "android\app\src\main\AndroidManifest.xml"
if (!(Test-Path $man)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $man) | Out-Null
  @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.similareats.app">

    <uses-permission android:name="android.permission.CAMERA" />
    <!-- Android 13+ -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <!-- Pre-13 fallback -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"/>

    <application
        android:label="Similar Eats"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
"@ | Set-Content -Encoding UTF8 $man
  Write-Host "Created: $man"
} else {
  $xml = Get-Content -Raw -Encoding UTF8 $man
  $changed = $false
  foreach ($perm in @(
    '<uses-permission android:name="android.permission.CAMERA" />',
    '<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />',
    '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />'
  )) {
    if ($xml -notmatch [Regex]::Escape($perm)) {
      $xml = $xml -replace '(?s)(<application\b)', "$perm`n`$1"
      $changed = $true
      Write-Host "  + Added permission: $perm"
    }
  }
  if ($changed) {
    Copy-Item $man "$man.bak" -Force
    Set-Content -Path $man -Value $xml -Encoding UTF8 -NoNewline
    Write-Host "Patched: $man"
  } else {
    Write-Host "No changes needed: $man"
  }
}

Write-Host "`nAll checks complete."



