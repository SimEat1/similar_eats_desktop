param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Patching const error in recommender files ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

# Make Restaurant constructor non-const
(Get-Content lib/features/recommendations/domain/restaurant.dart -Raw) `
  -replace 'const\s+class','class' `
  -replace 'const\s+Restaurant','Restaurant' `
  | Set-Content -Encoding UTF8 lib/features/recommendations/domain/restaurant.dart

# Remove consts from mock list file entirely
(Get-Content lib/features/recommendations/data/mock_restaurants.dart -Raw) `
  -replace '=>\s*const\s*\[','=> [' `
  -replace 'const\s+Restaurant','Restaurant' `
  | Set-Content -Encoding UTF8 lib/features/recommendations/data/mock_restaurants.dart

Write-Host "Patched. Run: flutter test test/recommender_test.dart" -ForegroundColor Green
