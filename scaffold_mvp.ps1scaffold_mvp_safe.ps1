# scaffold_mvp_safe.ps1 — no here-strings, safe in Notepad
$ErrorActionPreference = "Stop"

function Write-File([string]$path, [string[]]$lines) {
  New-Item -ItemType Directory -Path (Split-Path $path) -Force | Out-Null
  if (Test-Path $path) { Copy-Item $path "$path.bak" -Force; Write-Host "Backup: $path -> $path.bak" }
  $content = ($lines -join "`r`n")
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# ---------- Feature READMEs ----------
$readmeBuds = @(
  "# Taste Buds (Friends)",
  "",
  "Manages friend links and similarity.",
  "",
  "**Firestore:**",
  "- `/users/{uid}/buds/{friendUid}` — owner-only link",
  "- `/public_taste/{uid}` — owner writes, signed-in users read (vector for matching)",
  "",
  "**Primary files (expected):**",
  "- `services/taste_buds_service.dart` — stream buds, read vectors, cosine similarity",
  "- `screens/taste_buds_screen.dart` — UI list + add/remove + % match",
  "",
  "**TODO:**",
  "- Invite flow (share code/UID + accept)",
  "- Badge for new buds, empty-state CTA"
)

$readmeReceipts = @(
  "# Receipts (MVP)",
  "",
  "Paste text (now) → parse → save; OCR (image) later via Cloud Function.",
  "",
  "**Firestore:**",
  "- `/users/{uid}/receipts/{rid}` with `items/{iid}` (owner-only)",
  "",
  "**Next:**",
  "- After save, prompt “Rate this meal?” and create `/visits` docs",
  "- Cloud Vision OCR pipeline (Storage → Function → Firestore)"
)

$readmeTasteProfile = @(
  "# Taste Profile",
  "",
  "Collect & normalize taste vectors.",
  "",
  "**Firestore:**",
  "- `/userTaste/{uid}` — private owner-only",
  "- `/public_taste/{uid}` — public read (signed-in), owner write (for matching)",
  "",
  "**Next:**",
  "- Auto-sync quiz → `public_taste` on completion"
)

$readmeVisits = @(
  "# Visits",
  "",
  "Quick meal logs & ratings.",
  "",
  "**Firestore:**",
  "- `/visits/{docId}` or `/users/{uid}/visits/{docId}` (choose one and stick to it)",
  "",
  "**Next:**",
  "- Hook from Receipts: when user confirms item(s), create visit docs and prompt ratings"
)

$readmeShared = @(
  "# Shared",
  "",
  "Common widgets, models, and helpers:",
  "- Portion models",
  "- Pickers",
  "- Theme tokens + utilities"
)

Write-File "lib\features\buds\services\README.md"  $readmeBuds
Write-File "lib\features\buds\screens\README.md"   $readmeBuds
Write-File "lib\features\receipts\README.md"       $readmeReceipts
Write-File "lib\features\taste_profile\README.md"  $readmeTasteProfile
Write-File "lib\features\visits\README.md"         $readmeVisits
Write-File "lib\shared\README.md"                  $readmeShared

# ---------- Central docs ----------
$mvpChecklist = @(
  "# MVP Checklist — Similar Eats",
  "",
  "## Core done",
  "- [x] Firebase init + auth (anon ok)",
  "- [x] Debug write smoke + healthcheck",
  "- [x] Quick Visit save (portion + ratings)",
  "- [x] Taste Buds screen + demo seed",
  "- [x] Receipts MVP (paste text → parse → save)",
  "",
  "## Next up",
  "- [ ] Quiz → auto-sync to `/public_taste/{uid}`",
  "- [ ] Receipts → prompt to rate + create visits",
  "- [ ] Friend invite flow (share / accept)",
  "- [ ] Rules: confirm receipts + buds + public_taste (below)",
  "- [ ] Optional: Group Match entry link to Taste Buds",
  "- [ ] Optional: basic notification hooks"
)

$dataSchemas = @(
  "# Data Schemas (MVP)",
  "",
  "## /public_taste/{uid}",
  "{",
  "  vector: number[],   // fixed length",
  "  updatedAt: timestamp,",
  "  schema: \"v1\"",
  "}",
  "",
  "## /users/{uid}/buds/{friendUid}",
  "{",
  "  since: timestamp",
  "}",
  "",
  "## /users/{uid}/receipts/{rid}",
  "{",
  "  created_at: isoString,",
  "  merchant: string|null,",
  "  date: isoString|null,",
  "  subtotal: number|null,",
  "  tax: number|null,",
  "  total: number|null,",
  "  img_path: string|null",
  "}",
  "",
  "## /users/{uid}/receipts/{rid}/items/{iid}",
  "{",
  "  raw: string,",
  "  name: string,",
  "  qty: number,",
  "  price: number,",
  "  place_id: string|null,",
  "  menu_item_id: string|null,",
  "  visit_id: string|null   // when created via rating prompt",
  "}"
)

$firestoreRules = @(
  "# Firestore Rules — MVP Snippets",
  "",
  "Add these into your rules under `match /databases/{database}/documents { ... }`",
  "",
  "```rules",
  "function signedIn() { return request.auth != null; }",
  "function isOwner(uid) { return signedIn() && request.auth.uid == uid; }",
  "",
  "// Taste buds (friend links)",
  "match /users/{uid}/buds/{friendUid} {",
  "  allow read, write: if isOwner(uid);",
  "}",
  "",
  "// Public taste vectors",
  "match /public_taste/{uid} {",
  "  allow read: if signedIn();",
  "  allow write: if isOwner(uid);",
  "}",
  "",
  "// Receipts (owner-only)",
  "match /users/{uid}/receipts/{rid} {",
  "  allow read, write: if isOwner(uid);",
  "  match /items/{iid} {",
  "    allow read, write: if isOwner(uid);",
  "  }",
  "}",
  "```"
)

$roadmap = @(
  "# Roadmap (Short)",
  "",
  "**Now**",
  "- Finish Receipts flow: parse → save → prompt ratings → create visits",
  "",
  "**Soon**",
  "- Auto-sync quiz → public taste",
  "- Friend invites",
  "- Group Match integration link",
  "- OCR via Cloud Function (upload → Vision → parse → Firestore)",
  "",
  "**Later**",
  "- Taste Radar graph",
  "- Notifications + badges",
  "- Better search/map filters"
)

Write-File "docs\MVP_CHECKLIST.md"     $mvpChecklist
Write-File "docs\DATA_SCHEMAS.md"      $dataSchemas
Write-File "docs\FIRESTORE_RULES.md"   $firestoreRules
Write-File "docs\ROADMAP.md"           $roadmap

Write-Host "`nScaffold complete."
Write-Host "Next:"
Write-Host " 1) Paste rules from docs/FIRESTORE_RULES.md into your Firestore rules and publish."
Write-Host " 2) Keep docs/MVP_CHECKLIST.md updated as we knock items out."
Write-Host " 3) Proceed to: Receipts → post-save rating prompt → create visits."
