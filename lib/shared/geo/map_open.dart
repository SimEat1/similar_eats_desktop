// lib/shared/geo/map_open.dart
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

/// Open a map pin at [lat],[lng] with an optional [label].
Future<void> openMapPlace({
  required double lat,
  required double lng,
  String? label,
}) async {
  final g = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$lat,$lng${label != null ? ' ($label)' : ''}')}',
  );
  final a = Uri.parse(
    'https://maps.apple.com/?ll=$lat,$lng${label != null ? '&q=${Uri.encodeComponent(label)}' : ''}',
  );
  await _launchPreferGoogle(g, a);
}

/// Open directions from [fromLat]/[fromLng] (optional) to [toLat]/[toLng].
/// If origin is null, Maps will use “Your location”.
Future<void> openMapDirections({
  double? fromLat,
  double? fromLng,
  required double toLat,
  required double toLng,
  String? label,
  String travelMode = 'driving',
}) async {
  final originPart =
      (fromLat != null && fromLng != null) ? '$fromLat,$fromLng' : '';
  final g = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
    '${originPart.isNotEmpty ? '&origin=${Uri.encodeComponent(originPart)}' : ''}'
    '&destination=${Uri.encodeComponent('$toLat,$toLng${label != null ? ' ($label)' : ''}')}&travelmode=$travelMode',
  );
  final a = Uri.parse(
    'https://maps.apple.com/?daddr=$toLat,$toLng'
    '${label != null ? '&q=${Uri.encodeComponent(label)}' : ''}'
    '${originPart.isNotEmpty ? '&saddr=${Uri.encodeComponent(originPart)}' : ''}',
  );
  await _launchPreferGoogle(g, a);
}

/// Search maps for [query]. If [nearLat]/[nearLng] provided, bias results near there.
Future<void> openMapSearch({
  required String query,
  double? nearLat,
  double? nearLng,
}) async {
  // Google supports `search/?api=1&query=burger` nicely.
  // If we have a near point, append “near lat,lng” which Google understands.
  final q = (nearLat != null && nearLng != null)
      ? '$query near $nearLat,$nearLng'
      : query;

  final g = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
  );
  // Apple variant (no API query param, but works with q=)
  final a = Uri.parse(
    'https://maps.apple.com/?q=${Uri.encodeComponent(q)}',
  );
  await _launchPreferGoogle(g, a);
}

Future<void> _launchPreferGoogle(Uri google, Uri apple) async {
  // On iOS/macOS prefer Apple Maps; everywhere else prefer Google Maps.
  final first = (Platform.isIOS || Platform.isMacOS) ? apple : google;
  final fallback = identical(first, apple) ? google : apple;

  if (await canLaunchUrl(first)) {
    await launchUrl(first, mode: LaunchMode.externalApplication);
    return;
  }
  if (await canLaunchUrl(fallback)) {
    await launchUrl(fallback, mode: LaunchMode.externalApplication);
    return;
  }
  // Final fallback: try default handler (web)
  await launchUrl(first);
}


