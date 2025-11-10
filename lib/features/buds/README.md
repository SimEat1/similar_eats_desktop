# Taste Buds (Friends)

Manages friend links and similarity.

**Firestore:**
- /users/{uid}/buds/{friendUid} — owner-only link
- /public_taste/{uid} — owner writes, signed-in users read (vector for matching)

**TODO:** Invite flow + badges