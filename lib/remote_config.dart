import 'package:firebase_remote_config/firebase_remote_config.dart';

class RC {
  static const keyQuickEats = 'quick_eats_enabled';
  static const keyLateNightStartHour = 'late_night_hour';

  static Future<FirebaseRemoteConfig> init() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setDefaults({
      keyQuickEats: true,
      keyLateNightStartHour: 23,
    });
    await rc.fetchAndActivate();
    return rc;
  }
}
