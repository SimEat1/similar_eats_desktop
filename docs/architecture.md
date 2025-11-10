# Architecture

- **Flutter** (mobile + desktop)
- **State**: Provider (ChangeNotifier)
- **Storage**
  - Desktop mock: SharedPreferences / local mock data
  - Mobile prod: Firebase (Auth, Firestore, Remote Config, Crashlytics)
- **Taste Quiz → Profile → Recs**
  - \TasteProfile\ (sweet/salty/sour/spicy/umami)
  - Badge calc (e.g., 🔥 Spice Chaser)
  - Recommender (cosine over taste vectors)

Key modules:
- \lib/features/taste_quiz\ — profile model, store, controller, result screen
- \lib/features/recommendations\ — mock data + recommender + UI list

