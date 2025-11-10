import 'package:geolocator/geolocator.dart';

/// Ask for permission and return the current [Position] if available.
/// Returns null if permission denied, services off, or any error occurs.
Future<Position?> getCurrentPositionOrNull() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // On desktop this is commonly false; we’ll just return null and
      // let Maps use “Your location”.
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    );
  } catch (_) {
    return null;
  }
}
