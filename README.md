# Similar Eats

Cross-platform Flutter app for discovering restaurants based on taste profiles, tags, and community data.  
Supports Android, iOS, Web, Desktop. Powered by Firebase + Drift (offline).

## Features
- Quick Eats (fast service & late night picks)
- Taste Profiles (vector matching & similarity)
- Reviews & Tags (user-generated)
- Favorites & Try List
- Offline Support (Drift + SQLCipher)
- Premium Features (Ad removal, Taste Radar, Offline Guides)
- Remote Config (feature flags & A/B tests)
- Monetization (AdMob + In-App Purchases)

## Structure
lib/
  features/
    quick_eats/
    taste_profiles/
    review_tagging/
    favorites/
    offline_drift_db/
    monetization/
    ...
  shared/
  main.dart

## Development
- Flutter SDK: >=3.x
- Firebase: Auth, Firestore, Remote Config, Crashlytics
- Offline DB: Drift + SQLCipher
- State management: Provider

## Getting Started
1. Clone repo
2. Run lutter pub get
3. Copy your Firebase config files (google-services.json, GoogleService-Info.plist)
4. Run locally with lutter run -d chrome
"@

  "C:\projects\similar_eats_desktop\lib\features\quick_eats\README.md" = @"
# Quick Eats

**Purpose:** Show users a filtered list of restaurants for fast service ("Quick") or open hours ("Late Night").  
Data is loaded from Firebase Realtime Database and controlled via Remote Config.

## Modules
- models/restaurant.dart → Data model for restaurant entries
- repo/quick_eats_repo.dart → Fetch & rank logic
- widgets/restaurant_card.dart → UI component
- screens/quick_eats_screen.dart → Quick Eats tab

## Data
Realtime Database path: /restaurants

## Remote Config Flags
- quick_eats_enabled (bool, default true)
- quick_eats_min_quick_tags (int, default 0)
- quick_eats_late_cutoff_hour (int, default 23)
