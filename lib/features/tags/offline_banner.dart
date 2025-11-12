import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// A thin, animated banner that appears at the top when the device is offline.
/// Desktop-safe. No Firebase dependency.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final StreamSubscription<ConnectivityResult> _sub;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      final isOffline = result == ConnectivityResult.none;
      if (mounted && isOffline != _offline) {
        setState(() => _offline = isOffline);
      }
    });
    // do an initial check
    Connectivity().checkConnectivity().then((r) {
      if (mounted) setState(() => _offline = r == ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 200),
      offset: _offline ? Offset.zero : const Offset(0, -1),
      child: Material(
        color: Colors.orange.shade700,
        elevation: 2,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.wifi_off, size: 16, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'You\'re offline — viewing cached data',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
