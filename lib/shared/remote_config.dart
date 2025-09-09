import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  RemoteConfigService._(this._rc);
  static RemoteConfigService? _instance;

  final FirebaseRemoteConfig _rc;

  static RemoteConfigService get instance {
    _instance ??= RemoteConfigService._(FirebaseRemoteConfig.instance);
    return _instance!;
  }

  Future<void> ensureReady() async {
    await _rc.setDefaults(const {
      "quick_eats_enabled": true,
      "quick_eats_min_quick_tags": 0,
      "quick_eats_late_cutoff_hour": 23,
    });
    await _rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: Duration(seconds: 10),
        minimumFetchInterval: Duration(minutes: 15),
      ),
    );
    try {
      await _rc.fetchAndActivate();
    } catch (_) {
      // keep defaults on error
    }
  }

  bool getBool(String key, {required bool fallback}) {
    try { return _rc.getBool(key); } catch (_) { return fallback; }
  }

  int getInt(String key, {required int fallback}) {
    try { return _rc.getInt(key); } catch (_) { return fallback; }
  }
}
