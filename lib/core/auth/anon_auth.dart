import 'package:firebase_auth/firebase_auth.dart';

class AnonAuth {
  AnonAuth._();
  static final AnonAuth instance = AnonAuth._();

  final _auth = FirebaseAuth.instance;

  /// Ensure we have an authenticated user (anonymous is fine).
  Future<User?> ensureSignedIn() async {
    final cur = _auth.currentUser;
    if (cur != null) return cur;
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }
}
