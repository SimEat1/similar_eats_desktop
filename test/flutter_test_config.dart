// test/flutter_test_config.dart
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:similar_eats_desktop/firebase_options.dart';

// This wraps every test. Keep it tiny: just init Core and DB URL.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only once
  try {
    Firebase.app();
  } catch (_) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // If you use the RTDB emulator locally, uncomment:
  // import 'package:firebase_database/firebase_database.dart';
  // FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);

  await testMain();
}


