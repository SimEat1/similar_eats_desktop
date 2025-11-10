@echo off
setlocal

REM --- Paths (relative to repo root)
set SCREEN=lib\features\visits\screens\quick_visit_screen.dart

REM --- 0) Backup mangled file (if present)
if exist "%SCREEN%" (
  echo Backing up "%SCREEN%"...
  copy /Y "%SCREEN%" "%SCREEN%.bak" >nul
)

REM --- 1) Recreate a clean, minimal working QuickVisit screen
powershell -NoProfile -Command ^
  "$content = @'
import "package:flutter/material.dart";
import "package:similar_eats_desktop/features/visits/data/visit_log_repository.dart";
import 'package:similar_eats_desktop/shared/portion.dart';
import 'package:similar_eats_desktop/shared/portion_size.dart';
import 'package:similar_eats_desktop/shared/widgets/portion_size_picker.dart';

class QuickVisitScreen extends StatefulWidget {
  const QuickVisitScreen({super.key});
  @override
  State<QuickVisitScreen> createState() => _QuickVisitScreenState();
}

class _QuickVisitScreenState extends State<QuickVisitScreen> {
  final _repo = const VisitLogRepository();

  Portion _portion = const Portion(size: PortionSize.m);
  int _tasteRating = 3;
  int _portionRating = 3;

  Future<void> _saveVisit(Map<String, dynamic> payload) async {
    try {
      await _repo.addQuickVisit(payload);
    } catch (e) {
      // ignore: avoid_print
      print('addQuickVisit error: $e');
    }
    if (mounted) Navigator.of(context).pop();
  }

  List<Widget> _quickVisitExtras(BuildContext context) {
    return [
      const SizedBox(height: 12),
      Text('Portion size', style: Theme.of(context).textTheme.titleMedium),
      PortionSizePicker(
        initialValue: _portion.size,
        onChanged: (size) => setState(() {
          _portion = Portion(size: size);
        }),
      ),
      const SizedBox(height: 12),
      Text('Taste rating: $_tasteRating', style: Theme.of(context).textTheme.titleMedium),
      Slider(
        min: 1, max: 5, divisions: 4, label: '$_tasteRating',
        value: _tasteRating.toDouble(),
        onChanged: (v) => setState(() => _tasteRating = v.round()),
      ),
      const SizedBox(height: 12),
      Text('Portion satisfaction: $_portionRating', style: Theme.of(context).textTheme.titleMedium),
      Slider(
        min: 1, max: 5, divisions: 4, label: '$_portionRating',
        value: _portionRating.toDouble(),
        onChanged: (v) => setState(() => _portionRating = v.round()),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: () {
          final payload = <String, dynamic>{};
          payload.addAll({
            'portion': _portion.toJson(),
            'taste_rating': _tasteRating,
            'portion_rating': _portionRating,
          });
          print("QuickVisit payload => $payload");
          _saveVisit(payload);
        },
        icon: const Icon(Icons.check),
        label: const Text('Save'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick visit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._quickVisitExtras(context),
        ],
      ),
    );
  }
}
'@; ^
  $dir = Split-Path -Parent '%SCREEN%'; ^
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }; ^
  Set-Content -Encoding UTF8 -Path '%SCREEN%' -Value $content; ^
  Write-Host 'Wrote clean QuickVisitScreen.'"

REM --- 2) Format & quick analyze
echo.
echo Running dart format...
dart format "%SCREEN%"

echo.
echo Running flutter analyze on the screen (plus repo/model if present)...
set REPO=lib\features\visits\data\visit_log_repository.dart
set MODEL=lib\features\visits\models\visit_log.dart

if exist "%REPO%" (
  if exist "%MODEL%" (
    flutter analyze "%SCREEN%" "%REPO%" "%MODEL%"
  ) else (
    flutter analyze "%SCREEN%" "%REPO%"
  )
) else (
  flutter analyze "%SCREEN%"
)

echo.
echo Done. A backup was saved as "%SCREEN%.bak"
endlocal
