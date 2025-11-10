import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel coreHost =
    MethodChannel('dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(coreHost, (call) async {
    switch (call.method) {
      case 'initializeCore':
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'test',
              'appId': 'test',
              'messagingSenderId': 'test',
              'projectId': 'test',
            },
            'pluginConstants': {},
          }
        ];
      case 'initializeApp':
        final args = (call.arguments as Map?) ?? {};
        final appName = (args['appName'] as String?) ?? '[DEFAULT]';
        return {
          'name': appName,
          'options': {
            'apiKey': 'test',
            'appId': 'test',
            'messagingSenderId': 'test',
            'projectId': 'test',
          },
          'pluginConstants': {},
        };
      default:
        return null;
    }
  });

  await testMain();
}
