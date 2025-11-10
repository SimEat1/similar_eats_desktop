import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Bootstraps all tests by faking Firebase Core's Pigeon channels.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  const codec = StandardMessageCodec();

  // Pigeon channels used by firebase_core on Flutter.
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

  // Mock: return [ result ]
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(chInitializeCore, (message) async {
    final List<Object?> apps = <Object?>[
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
    return <Object?>[apps]; // <-- wrap result
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<dynamic>(chInitializeApp, (message) async {
    final Map<Object?, Object?> args =
        (message as Map<Object?, Object?>?) ?? <Object?, Object?>{};
    final String appName =
        (args['appName'] as String?) ?? (args['name'] as String?) ?? '[DEFAULT]';

    final Map<String, Object?> app = <String, Object?>{
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

    return <Object?>[app]; // <-- wrap result
  });

  await testMain();
}
