import 'package:firebase_auth/firebase_auth.dart';
import "dart:io" show Platform;
import "package:flutter/foundation.dart";

class PlatformHelper {
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Return a safe UID for desktop dev; on mobile/web you can pass FirebaseAuth uid.
  static String? getCurrentUid({String? firebaseUid}) {
    if (isDesktop) return (FirebaseAuth.instance.currentUser?.uid ?? 'desktop-mock');
    return firebaseUid;
  }
}


