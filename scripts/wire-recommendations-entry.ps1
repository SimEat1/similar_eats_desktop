Write-Host "== Wire Recommendations entry ==" -ForegroundColor Cyan

$mainFiles = @("lib\main.dart","lib\main_demo.dart") | Where-Object { Test-Path $_ }
foreach ($mf in $mainFiles) {
  $t = Get-Content -Raw $mf
  $import = "import 'features/recommendations/presentation/recommendations_screen.dart';"
  if ($t -notmatch [regex]::Escape($import)) {
    if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
      $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
    } else { $t = $import + "`r`n" + $t }
  }
  $routesAdd = "RecommendationsScreen.route: (_) => const RecommendationsScreen(),"
  if ($t -match "MaterialApp\s*\(") {
    if ($t -match "routes\s*:\s*{") {
      $t = [regex]::Replace($t, "routes\s*:\s*{", "routes: { $routesAdd ", 1)
    } else {
      $t = [regex]::Replace($t, "MaterialApp\s*\(", "MaterialApp(" + "routes: { $routesAdd }, ", 1)
    }
  }
  Set-Content -Encoding UTF8 $mf $t
  Write-Host "  ✓ Patched $mf" -ForegroundColor Green
}

$tasteFile = "lib/features/taste_quiz/presentation/taste_type_result_screen.dart"
if (Test-Path $tasteFile) {
  $x = Get-Content -Raw $tasteFile
  if ($x -notmatch "RecommendationsScreen") {
    $x = $x -replace "import 'package:provider/provider.dart';",
      "import 'package:provider/provider.dart';`r`nimport '../../recommendations/presentation/recommendations_screen.dart';"
  }
  $x = $x -replace "Navigator\.of\(context\)\.maybePop\(\);",
      "Navigator.of(context).pushNamed(RecommendationsScreen.route);"
  Set-Content -Encoding UTF8 $tasteFile $x
  Write-Host "  ✓ Updated TasteTypeResultScreen button" -ForegroundColor Green
} else {
  Write-Host "  = TasteTypeResultScreen not found; skip button patch" -ForegroundColor DarkGray
}
