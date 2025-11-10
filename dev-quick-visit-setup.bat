@echo off
setlocal ENABLEDELAYEDEXPANSION

set DEV=lib\dev_quick_visit.dart
set QUICK=lib\features\visits\screens\quick_visit_screen.dart

REM 1) Overwrite dev entry
> "%DEV%" (
  echo import "package:flutter/material.dart";
  echo import "package:firebase_core/firebase_core.dart";
  echo import "package:firebase_auth/firebase_auth.dart";
  echo import "firebase_options.dart";
  echo import "features/visits/screens/quick_visit_screen.dart";
  echo.
  echo Future<void> main() async {
  echo   WidgetsFlutterBinding.ensureInitialized();
  echo   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  echo   await FirebaseAuth.instance.signInAnonymously();
  echo   runApp(const _DevApp());
  echo }
  echo.
  echo class _DevApp extends StatelessWidget {
  echo   const _DevApp({super.key});
  echo   @override
  echo   Widget build(BuildContext context) {
  echo     return MaterialApp(
  echo       title: "Quick Visit (DEV)",
  echo       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
  echo       home: const QuickVisitScreen(),
  echo     );
  echo   }
  echo }
)

REM 2) Ensure firebase_auth import + user_id field (very lightweight replace)
powershell -NoProfile -Command ^
  "$s=Get-Content '%QUICK%' -Raw; " ^
  "if($s -notmatch 'firebase_auth/firebase_auth\.dart'){ $s=$s -replace '(^import[^\n]*;\s*)',(""$1"" + ""import 'package:firebase_auth/firebase_auth.dart';`r`n"") } ; " ^
  "if($s -notmatch ""'user_id'\s*:""){ $s=[regex]::Replace($s,'final\s+payload\s*=\s*<String,\s*dynamic>\s*\{\s*','final payload = <String, dynamic>{`r`n                ''user_id'': FirebaseAuth.instance.currentUser?.uid,`r`n                ',1) } ; " ^
  "Set-Content '%QUICK%' $s -Encoding UTF8"

echo.
echo Formatting & fetching deps...
flutter format "%DEV%" "%QUICK%" >NUL
flutter pub get >NUL

echo.
echo Run the dev entry:
echo   flutter run -d windows -t lib/dev_quick_visit.dart
echo.
echo (Optional) deploy rules & indexes with Firebase CLI:
echo   firebase deploy --only firestore:rules,firestore:indexes

endlocal
