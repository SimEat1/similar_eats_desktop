// ...imports and binding setup above...

// initializeCore → return [ { 'apps': [ <app map>, ... ] } ]
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockDecodedMessageHandler<dynamic>(chInitializeCore, (message) async {
  final Map<String, Object?> coreInitResponse = <String, Object?>{
    'apps': <Object?>[
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
      },
    ],
  };
  return <Object?>[coreInitResponse]; // <-- CoreInitializeResponse
});

// initializeApp → still return [ <app map> ] (already correct)
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

  return <Object?>[app]; // <-- CoreFirebaseApp
});

