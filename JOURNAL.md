# Similar Eats — Project Journal

This file tracks **major milestones, design decisions, and reasoning** so future-you (or anyone inheriting the repo) knows *why things were done*.

---

## 2025-09-12 — Baseline Checkpoint

### What We Did
- ✅ Created **Quick Eats** feature module  
- ✅ Built **Try List** feature (screen, repo, model)  
- ✅ Integrated **anonymous Firebase Auth** so all users can sign in seamlessly  
- ✅ Seeded **restaurants** into RTDB via PowerShell script (`add_restaurants.ps1`)  
- ✅ Confirmed reads/writes with adjusted **Realtime Database rules**  
- ✅ Added **taste profile logic** placeholder for user personalization  
- ✅ Added **quick smoke tests** to confirm builds don’t break  
- ✅ Pushed repo to GitHub with tag: `v0.1.0-alpha`

### Why
- We needed a **working, testable baseline** before locking down Firebase rules.
- Getting a few restaurants into RTDB was critical so Quick Eats had real data.
- Auth + RTDB + Repo flow is now fully functional, meaning the core loop works:  
  *user opens → app fetches restaurants → Try List persists per user.*

### Lessons / Notes
- PowerShell scripts save time vs manual edits.
- Firebase auth requires **signUp → idToken** flow for seeding.
- CRLF ↔ LF warnings are harmless but should be standardized later.

### Next Focus
- Add **Taste Quiz UI** (initial seeding of taste profiles).  
- Add **Google Maps integration** for real-world restaurant lookup.  
- Add **price/value component** (design TBD — likely 1–4 “value for money” scale).  
- Polish Firebase rules (move toward production security).  
- Expand restaurant dataset beyond test seed.

---

## Rules of the Journal
- Update **once a week** or after any big checkpoint (new feature, DB migration, release tag).
- Keep entries short but cover:
  1. ✅ What we did
  2. 🤔 Why we did it
  3. 📝 Lessons
  4. 🎯 Next focus
