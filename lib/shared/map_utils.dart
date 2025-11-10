import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

Future<void> openInMaps({
  String? query,
  double? lat,
  double? lng,
  String? label,
}) async {
  assert(query != null || (lat != null && lng != null));

  final q = Uri.encodeComponent(query ?? (label ?? 'Location'));
  final hasCoords = lat != null && lng != null;
  Uri uri;

  if (Platform.isIOS || Platform.isMacOS) {
    if (hasCoords) {
      final ll = '$lat,$lng';
      uri = Uri.parse('http://maps.apple.com/?ll=$ll&q=$q');
    } else {
      uri = Uri.parse('http://maps.apple.com/?q=$q');
    }
  } else if (Platform.isAndroid) {
    if (hasCoords) {
      final ll = '$lat,$lng';
      uri = Uri.parse('geo:$ll?q=$ll($q)');
    } else {
      uri = Uri.parse('geo:0,0?q=$q');
    }
  } else {
    if (hasCoords) {
      final ll = '$lat,$lng';
      final text = Uri.encodeComponent(label ?? query ?? '');
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$ll&q=$text');
    } else {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    }
  }

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    final fallback =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
    await launchUrl(fallback, mode: LaunchMode.externalApplication);
  }
}

Future<void> openDirections({
  String? fromQuery,
  double? fromLat,
  double? fromLng,
  String? toQuery,
  double? toLat,
  double? toLng,
  String travelMode = 'driving', // walking | bicycling | transit
}) async {
  final params = <String>[
    if (fromLat != null && fromLng != null)
      'origin=${fromLat.toStringAsFixed(6)},${fromLng.toStringAsFixed(6)}'
    else if (fromQuery != null)
      'origin=${Uri.encodeComponent(fromQuery)}',
    if (toLat != null && toLng != null)
      'destination=${toLat.toStringAsFixed(6)},${toLng.toStringAsFixed(6)}'
    else if (toQuery != null)
      'destination=${Uri.encodeComponent(toQuery)}',
    'travelmode=$travelMode',
  ].where((e) => e.isNotEmpty).join('&');

  final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&$params');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
