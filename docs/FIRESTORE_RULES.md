# Firestore Rules

function signedIn() { return request.auth != null; }
function isOwner(uid) { return signedIn() && request.auth.uid == uid; }

match /users/{uid}/buds/{friendUid} { allow read, write: if isOwner(uid); }
match /public_taste/{uid} { allow read: if signedIn(); allow write: if isOwner(uid); }
match /users/{uid}/receipts/{rid} { allow read, write: if isOwner(uid); match /items/{iid} { allow read, write: if isOwner(uid); } }