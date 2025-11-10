import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "dart:ui";
import "package:firebase_core/firebase_core.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:similar_eats_desktop/firebase_options.dart";
import "package:similar_eats_desktop/features/visits/screens/quick_visit_screen.dart";

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log framework & zone errors (so the app doesn’t silently die)
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Zone error: $error');
    debugPrint(stack.toString());
    return true; // prevent crash
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    debugPrint('Anon sign-in failed: $e');
  }

  // Run a dev healthcheck write under /debug/{uid}/healthcheck
  // so it respects owner-scoped rules (same pattern as smoke test).
  await _devHealthcheck();

  runApp(const _DevApp());
}

class _DevApp extends StatelessWidget {
  const _DevApp();

  @override
  Widget build(BuildContext context) {
    final routeObserver = RouteObserver<PageRoute<dynamic>>();
    return MaterialApp(
      title: "Quick Visit (DEV)",
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      navigatorObservers: [routeObserver],
      home: PopScope(
        canPop: false, // block closing the only route
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            debugPrint("DEV: back blocked");
          }
        },
        child: const QuickVisitScreen(),
      ),
    );
  }
}

Future<void> _devHealthcheck() async {
  try {
    debugPrint("[dev] writing healthcheck...");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint("[dev] healthcheck skipped: no uid");
      return;
    }

    final r = await FirebaseFirestore.instance
        .collection('debug')
        .doc(uid)
        .collection('healthcheck')
        .add({
      'ts': DateTime.now().toIso8601String(),
      'who': PlatformHelper.getCurrentUid(firebaseUid: uid),
      'platform': 'windows',
    });

    debugPrint("[dev] healthcheck doc id: ${r.id}");
  } catch (e, st) {
    debugPrint("[dev] healthcheck failed: $e");
    debugPrintStack(label: "[dev] stack", stackTrace: st);
  }
}

