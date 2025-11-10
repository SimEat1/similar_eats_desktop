import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bootstraps all tests by faking Firebase Core's Pigeon channels.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = StandardMessageCodec();

  // Pigeon channels used by firebase_core on Flutter (Dart side talks to host).
  const chInitializeCore =
      BasicMessageChannel<dynamic>(
        'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
        codec,
      );

  const chInitializeApp =
      BasicMessageChannel<dynamic>(
        'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeApp',
        codec,
      );

  // Mock responses that look like what the native side would return.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(chInitializeCore, (message) async {
    // Return one default app.
    return <Object?>[
      <String, Object?>{
        'name': '[DEFAULT]',
        'options': <String, Object?>{
          'apiKey': 'test',
          'appId': 'test',
          'messagingSenderId': 'test',
          'projectId': 'test',
        },
        'isAutomaticDataCollectionEnabled': false,
        'isAutomaticResourceManagementEnabled': false,
        'pluginConstants': <String, Object?>{},
      }
    ];
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(chInitializeApp, (message) async {
    // message is usually a Map with app options; we just echo back a valid app.
    final Map<Object?, Object?> args =
        (message as Map<Object?, Object?>?) ?? <Object?, Object?>{};
    final String appName =
        (args['appName'] as String?) ?? (args['name'] as String?) ?? '[DEFAULT]';

    return <String, Object?>{
      'name': appName,
      'options': <String, Object?>{
        'apiKey': 'test',
        'appId': 'test',
        'messagingSenderId': 'test',
        'projectId': 'test',
      },
      'isAutomaticDataCollectionEnabled': false,
      'isAutomaticResourceManagementEnabled': false,
      'pluginConstants': <String, Object?>{},
    };
  });

  await testMain();
}
