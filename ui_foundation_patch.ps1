# ui_foundation_patch.ps1
$ErrorActionPreference = "Stop"

function Backup-And-Write($Path, $Content) {
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  if (Test-Path $Path) { Copy-Item $Path "$Path.bak" -Force }
  Set-Content -Path $Path -Value $Content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $Path"
}

# ------------- 1) shared/ui/responsive.dart -------------
$responsive = @'
import "package:flutter/material.dart";

bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;

class AppSizes {
  static double iconLg(BuildContext context) => isDesktop(context) ? 22.0 : 28.0;
  static const double cardRadius = 20;
  static const double cardPad = 16;
  static const double cardGap = 12;
}
'@
Backup-And-Write "lib/shared/ui/responsive.dart" $responsive

# ------------- 2) shared/ui/tokens.dart -------------
$tokens = @'
import "package:flutter/material.dart";

class AppTokens {
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(20));
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const double elevation = 2.0;
  static const double elevationHover = 6.0;
}
'@
Backup-And-Write "lib/shared/ui/tokens.dart" $tokens

# ------------- 3) shared/widgets/action_card.dart -------------
$actionCard = @'
import "package:flutter/material.dart";
import "../../shared/ui/tokens.dart";
import "../../shared/ui/responsive.dart";

class ActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<ActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final iconSize = AppSizes.iconLg(context);
    final elev = _hover ? AppTokens.elevationHover : AppTokens.elevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Card(
        elevation: elev,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.cardRadius),
        child: InkWell(
          borderRadius: AppTokens.cardRadius,
          onTap: widget.onTap,
          child: Padding(
            padding: AppTokens.cardPadding,
            child: Row(
              children: [
                Icon(widget.icon, size: iconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
'@
Backup-And-Write "lib/shared/widgets/action_card.dart" $actionCard

# ------------- 4) features/home/welcome_screen.dart (full rewrite) -------------
$welcome = @'
import "package:flutter/material.dart";
import "../dinner/dinner_screen.dart";
import "../explore/explore_map_screen.dart";
import "../group_match/group_match_screen.dart";
import "../taste_quiz/screens/taste_quiz_screen.dart";
import "package:similar_eats_desktop/features/buds/screens/taste_buds_screen.dart";
import "package:similar_eats_desktop/features/receipts/receipt_scan_screen.dart";
import "package:similar_eats_desktop/features/receipts/receipts_home_screen.dart";

import "package:similar_eats_desktop/shared/widgets/action_card.dart";
import "package:similar_eats_desktop/shared/ui/responsive.dart";

class WelcomeScreen extends StatelessWidget {
  static const routeName = "/welcome";
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget heroHeader() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Find your next crave-worthy meal 🍔🔥",
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text("Personalized by your taste — scan receipts, rate dishes, match with buds.",
              style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Taste Buds',
        child: const Icon(Icons.group_outlined),
        onPressed: () => Navigator.pushNamed(context, TasteBudsScreen.route),
      ),
      appBar: AppBar(title: const Text("Similar Eats")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          heroHeader(),
          const SizedBox(height: 16),

          // Quick actions row
          LayoutBuilder(builder: (ctx, c) {
            final wide = isDesktop(ctx);
            final children = [
              Expanded(child: ActionCard(
                icon: Icons.restaurant,
                title: "Find spots that match me",
                subtitle: "Uses your taste profile",
                onTap: () => Navigator.push(
                  ctx, MaterialPageRoute(builder: (_) => const DinnerScreen())),
              )),
              const SizedBox(width: 12),
              Expanded(child: ActionCard(
                icon: Icons.document_scanner_outlined,
                title: "Scan receipt",
                subtitle: "Paste text now; OCR image import too",
                onTap: () => Navigator.pushNamed(ctx, ReceiptScanScreen.route),
              )),
              const SizedBox(width: 12),
              Expanded(child: ActionCard(
                icon: Icons.group_outlined,
                title: "Taste Buds",
                subtitle: "See who eats like you",
                onTap: () => Navigator.pushNamed(ctx, TasteBudsScreen.route),
              )),
            ];
            if (wide) {
              return Row(children: children);
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  children[0],
                  const SizedBox(height: 12),
                  children[2], // ActionCard #2 (after a spacer index shift)
                  const SizedBox(height: 12),
                  children[4], // ActionCard #3
                ],
              );
            }
          }),

          const SizedBox(height: 24),
          Text("More", style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),

          ActionCard(
            icon: Icons.map,
            title: "Explore map",
            subtitle: "Browse by map near you",
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ExploreMapScreen())),
          ),
          ActionCard(
            icon: Icons.groups,
            title: "Group match (demo)",
            subtitle: "Pick a restaurant everyone can enjoy",
            onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const GroupMatchScreen())),
          ),
          ActionCard(
            icon: Icons.quiz,
            title: "Retake taste quiz",
            subtitle: "Update flavors, cuisines, budget & dietary info",
            onTap: () => Navigator.pushNamed(context, TasteQuizScreen.routeName),
          ),
          ActionCard(
            icon: Icons.receipt_long,
            title: "Receipts",
            subtitle: "See saved receipts & items",
            onTap: () => Navigator.pushNamed(context, ReceiptsHomeScreen.route),
          ),
        ],
      ),
    );
  }
}
'@
Backup-And-Write "lib/features/home/welcome_screen.dart" $welcome

# ------------- 5) main.dart: ensure GoogleFonts & text theme -------------
$mainPath = "lib/main.dart"
if (-not (Test-Path $mainPath)) { throw "Missing $mainPath" }
$main = Get-Content -Raw $mainPath

if ($main -notmatch "google_fonts/google_fonts.dart") {
  $main = $main -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:google_fonts/google_fonts.dart';`r`n"
  Write-Host "Added google_fonts import to main.dart"
}

# Replace theme block to include GoogleFonts textTheme (light touch)
if ($main -match "ThemeData\(" -and $main -notmatch "GoogleFonts\.poppinsTextTheme") {
  $main = $main -replace "ThemeData\s*\(",
    "ThemeData(" +
    "`r`n        textTheme: GoogleFonts.poppinsTextTheme()," +
    "`r`n        "
  Write-Host "Injected GoogleFonts textTheme into ThemeData"
}

Backup-And-Write $mainPath $main

# ------------- 6) pubspec.yaml: ensure google_fonts dep -------------
$pub = Get-Content -Raw "pubspec.yaml"
if ($pub -notmatch "^\s*google_fonts:" -and $pub -match "dependencies:\s*\n") {
  $pub = $pub -replace "(?m)^(dependencies:\s*)$",
    "`$1`r`n  google_fonts: ^6.3.2"
  Backup-And-Write "pubspec.yaml" $pub
  Write-Host "Added google_fonts to pubspec.yaml"
} else {
  Write-Host "google_fonts already present in pubspec.yaml"
}

Write-Host "`nRunning flutter pub get..."
flutter pub get | Write-Host
Write-Host "`nDone. Now run:  flutter run -d windows"

