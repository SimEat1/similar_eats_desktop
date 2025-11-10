param($ProjectPath = "C:\projects\similar_eats_desktop")

$quiz        = Join-Path $ProjectPath "lib\features\taste_quiz\screens\taste_quiz_screen.dart"
$widgetDir   = Join-Path $ProjectPath "lib\features\taste_quiz\widgets"
$widgetFile  = Join-Path $widgetDir "diet_allergy_section.dart"

if (!(Test-Path $quiz)) { Write-Error "Not found: $quiz"; exit 1 }
New-Item -ItemType Directory -Force -Path $widgetDir | Out-Null

# 0) (Re)create DietAllergySection so the class definitely exists.
@"
import "package:flutter/material.dart";
import "../screens/diet_allergy_step.dart";

class DietAllergySection extends StatefulWidget {
  const DietAllergySection({super.key, this.onChanged});
  final void Function(DietAllergyResult result)? onChanged;
  @override State<DietAllergySection> createState()=>_DietAllergySectionState();
}
class _DietAllergySectionState extends State<DietAllergySection>{
  Set<String> _allergies = {};
  Set<String> _diets = {};
  bool _hide = true;

  Future<void> _open() async {
    final r = await Navigator.of(context).push<DietAllergyResult>(
      MaterialPageRoute(builder:(_)=>const DietAllergyStep()),
    );
    if (r!=null){ setState(()=>{_allergies=r.allergies,_diets=r.diets,_hide=r.hideMismatches}); widget.onChanged?.call(r); }
  }

  @override Widget build(BuildContext c)=>Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children:[
      FilledButton.icon(icon: const Icon(Icons.health_and_safety),
        label: const Text("Set Diet & Allergies"), onPressed:_open),
      const SizedBox(height:12),
      if(_allergies.isNotEmpty||_diets.isNotEmpty)
        Wrap(spacing:8,runSpacing:8,children:[
          ..._allergies.map((a)=>Chip(label:Text("Allergy: $a"))),
          ..._diets.map((d)=>Chip(label:Text("Diet: $d"))),
          Chip(label:Text(_hide?"Hiding mismatches":"Showing mismatches")),
        ]),
    ]);
}
"@ | Set-Content -Encoding UTF8 $widgetFile
Write-Host "✅ Ensured widget: $widgetFile"

# 1) Patch the quiz screen
$bak = "$quiz.bak_$(Get-Date -Format yyyyMMdd_HHmmss)"
Copy-Item $quiz $bak -Force
Write-Host "🗂  Backup -> $bak"

$c = Get-Content $quiz -Raw

# import the widget (use correct relative path)
if ($c -notmatch "diet_allergy_section\.dart") {
  $c = $c -replace '(^\s*import\s+.+?;\s*)', "`$1`r`nimport '../widgets/diet_allergy_section.dart';`r`n"
} else {
  $c = $c -replace "import\s+['""](.+)?diet_allergy_section\.dart['""]\s*;", "import '../widgets/diet_allergy_section.dart';"
}

# Remove const from the parent(s) that block a stateful child
$c = $c -replace 'children\s*:\s*const\s*(<[^>]+>\s*)?\[', 'children: ['
$c = $c -replace '(children\s*:\s*)(<[^>]+>\s*)?const(\s*\[)', '$1$2$3'
$c = $c -replace '\bconst\s+(Column|Row|ListView|Wrap|Padding|Expanded|Flexible|Container|SliverList|SliverToBoxAdapter)\s*\(', '$1('

# Also relax any immediate const list literals near our section (safe for UI files)
$c = $c -replace '(?<=\s)\bconst\s+\[', '['

# Ensure the call is present & non-const
$c = $c -replace '\bconst\s+DietAllergySection\s*\(', 'DietAllergySection('
if ($c -notmatch 'DietAllergySection\s*\(') {
  $c = [regex]::Replace($c, 'children\s*:\s*\[', "children: [`r`n          DietAllergySection(),", 1, 'IgnoreCase')
}

# Nuke any stale callbacks/types we may have tried before
$c = [regex]::Replace($c, 'onChanged\s*:\s*\([^)]*\)\s*=>\s*[^,]*,', '', 'Singleline, IgnoreCase')
$c = [regex]::Replace($c, 'onChanged\s*:\s*\([^)]*\)\s*{[^}]*},', '', 'Singleline, IgnoreCase')
$c = [regex]::Replace($c, '.*DietAllergyResult.*\r?\n', '', 'IgnoreCase')

Set-Content -Encoding UTF8 $quiz $c
Write-Host "🛠  Patched $quiz"

# 2) Build & run
Set-Location $ProjectPath
flutter clean
flutter pub get
flutter run -d windows
