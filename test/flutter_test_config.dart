import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

/// Runs before every test suite. Mocks the Firebase Core platform channel so
/// Firebase.initializeApp() works in unit/widget tests without a real device.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel core = MethodChannel('plugins.flutter.io/firebase_core');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(core, (MethodCall call) async {
    switch (call.method) {
      case 'Firebase#initializeCore':
        // Return a single default app with minimal options.
        return <Map<String, dynamic>>[
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test',
              'appId': 'test',
              'messagingSenderId': 'test',
              'projectId': 'test',
            },
            'pluginConstants': <String, dynamic>{},
          }
        ];
      case 'Firebase#initializeApp':
        final String appName = (call.arguments as Map)['appName'] as String? ?? '[DEFAULT]';
        return {
          'name': appName,
          'options': {
            'apiKey': 'test',
            'appId': 'test',
            'messagingSenderId': 'test',
            'projectId': 'test',
          },
          'pluginConstants': <String, dynamic>{},
        };
      default:
        return null;
    }
  });

  await Firebase.initializeApp();
  await testMain();
}
