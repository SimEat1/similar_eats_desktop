import 'package:firebase_auth/firebase_auth.dart';

class AnonAuth {
  AnonAuth._();
  static final instance = AnonAuth._();

  Future<void> ensureSignedIn() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }
}
