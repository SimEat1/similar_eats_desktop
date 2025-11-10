Write-Host "== Similar Eats: scanning for UID usage ==" -ForegroundColor Cyan

$hits = @()
$patterns = @(
  'FirebaseAuth',
  'currentUser\?\.\s*uid',
  '(?<quote>[''"]?)uid\k<quote>\s*:',
  'quick_visit',
  'saveVisit',
  'payload',
  'visit',
  'save('
)

Get-ChildItem -Path .\lib -Recurse -Include *.dart | ForEach-Object {
  $path = $_.FullName
  $content = Get-Content -Raw -Path $path
  foreach ($p in $patterns) {
    $m = [regex]::Matches($content, $p, 'IgnoreCase')
    if ($m.Count -gt 0) {
      $hits += [pscustomobject]@{ File = $path; Pattern = $p; Count = $m.Count }
    }
  }
}

if ($hits.Count -eq 0) {
  Write-Host "  = No obvious UID patterns found." -ForegroundColor DarkGray
} else {
  $hits | Sort-Object File, Pattern | Format-Table -AutoSize
  Write-Host "`nTip: open the files listed above; look for where map payloads set 'uid'." -ForegroundColor Yellow
}
