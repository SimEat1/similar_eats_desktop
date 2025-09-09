param(
  [string]$Proj = "C:\projects\similar_eats_desktop"
)

$ErrorActionPreference = "Stop"

$base = Join-Path $Proj "lib\features\quick_eats"
$models = Join-Path $base "models"
$repo   = Join-Path $base "repo"
$widgets= Join-Path $base "widgets"

$null = New-Item -ItemType Directory -Force -Path $models,$repo,$widgets

# 1) Restaurant model
$restaurantPath = Join-Path $models "restaurant.dart"
if (-not (Test-Path $restaurantPath)) {
@'
class Restaurant {
  final String id;
  final String name;
  final List<String> serviceTags;
  final bool quickServiceFlag;
  final bool openLateFlag;

  Restaurant({
    required this.id,
    required this.name,
    this.serviceTags = const [],
    this.quickServiceFlag = false,
    this.openLateFlag = false,
  });

  factory Restaurant.fromMap(String id, Map<dynamic, dynamic> map) {
    final m = Map<String, dynamic>.from(
      map.map((k, v) => MapEntry(k.toString(), v)),
    );
    return Restaurant(
      id: id,
      name: (m['name'] ?? '') as String,
      serviceTags: (m['serviceTags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      quickServiceFlag: (m['quickServiceFlag'] ?? false) as bool,
      openLateFlag: (m['openLateFlag'] ?? false) as bool,
    );
  }
}
'@ | Set-Content -Path $restaurantPath -Encoding UTF8
}

# 2) Repository (RTDB)
$repoPath = Join-Path $repo "quick_eats_repo.dart"
@'
import "package:firebase_database/firebase_database.dart";
import "../models/restaurant.dart";

class QuickEatsRepo {
  final DatabaseReference _ref;
  QuickEatsRepo({DatabaseReference? ref})
      : _ref = ref ?? FirebaseDatabase.instance.ref("restaurants");

  Future<List<Restaurant>> fetchAll() async {
    final snap = await _ref.get();
    if (!snap.exists) return [];
    final value = snap.value;
    if (value is Map) {
      return value.entries
          .map<Restaurant>((e) => Restaurant.fromMap(
                e.key.toString(),
                Map<dynamic, dynamic>.from(e.value),
              ))
          .toList();
    }
    return [];
  }
}
'@ | Set-Content -Path $repoPath -Encoding UTF8

# 3) RestaurantCard widget
$cardPath = Join-Path $widgets "restaurant_card.dart"
@'
import "package:flutter/material.dart";
import "../models/restaurant.dart";

class RestaurantCard extends StatelessWidget {
  final Restaurant r;
  final bool showQuickBadge;
  final bool showLateBadge;

  const RestaurantCard({
    super.key,
    required this.r,
    this.showQuickBadge = false,
    this.showLateBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (showQuickBadge && r.quickServiceFlag)
        const Chip(label: Text("Quick")),
      if (showLateBadge && r.openLateFlag)
        const Chip(label: Text("Late Night")),
      if (r.serviceTags.isNotEmpty)
        Wrap(
          spacing: 6,
          runSpacing: -8,
          children: r.serviceTags.take(4).map((t) => Chip(label: Text(t))).toList(),
        ),
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(
          showQuickBadge ? Icons.flash_on : Icons.nightlight_round,
        ),
        title: Text(r.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(spacing: 6, runSpacing: -8, children: chips),
        ),
      ),
    );
  }
}
'@ | Set-Content -Path $cardPath -Encoding UTF8

Write-Host "Created/updated:"
Write-Host " - $restaurantPath"
Write-Host " - $repoPath"
Write-Host " - $cardPath"
