param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Heart toggle on Recommendations list ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

$rec = "lib/features/recommendations/presentation/recommendations_screen.dart"
if (-not (Test-Path $rec)) { Write-Host "  ! $rec not found" -ForegroundColor Red; exit 1 }

$t = Get-Content -Raw $rec

# Ensure imports
$imports = @(
  "import 'package:provider/provider.dart';",
  "import '../../favorites/presentation/favorites_controller.dart';"
)
foreach ($i in $imports) {
  if ($t -notmatch [regex]::Escape($i)) {
    if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
      $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $i + "`r`n")
    } else { $t = $i + "`r`n" + $t }
  }
}

# Replace trailing Column(...) with Row that includes a heart
$t = $t -replace "trailing:\s*Column\([^\)]*\)", @"
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("\$pct%", style: Theme.of(context).textTheme.titleLarge),
        const Text("match"),
      ],
    ),
    const SizedBox(width: 8),
    Consumer<FavoritesController>(
      builder: (_, fav, __) {
        final isFav = fav.isFavorite(r.id);
        return IconButton(
          tooltip: isFav ? 'Remove favorite' : 'Save to favorites',
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          onPressed: () => fav.toggle(r.id),
        );
      },
    ),
  ],
)
"@

Set-Content -Encoding UTF8 $rec $t
Write-Host "  ✓ updated $rec with heart toggle" -ForegroundColor Green
