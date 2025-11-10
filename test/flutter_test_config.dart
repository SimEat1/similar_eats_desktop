import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/testing.dart';

/// Runs before every test suite.
/// Mocks Firebase Core Pigeon channels and initializes a default app.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();           // <-- important
  await Firebase.initializeApp();     // default app
  await testMain();
}
