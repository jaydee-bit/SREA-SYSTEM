// File: srea_bottom_nav.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class SreaBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const SreaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded),
    _NavItemData(
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign_rounded,
    ),
    _NavItemData(
      icon: Icons.traffic_outlined,
      activeIcon: Icons.traffic_rounded,
    ),
    _NavItemData(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: SreaColors.primary,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      elevation: 6,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0, 1]
                    .map(
                      (i) => _NavButton(
                        data: _items[i],
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [2, 3]
                    .map(
                      (i) => _NavButton(
                        data: _items[i],
                        isActive: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  const _NavItemData({required this.icon, required this.activeIcon});
}

class _NavButton extends StatelessWidget {
  final _NavItemData data;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? data.activeIcon : data.icon,
              color: isActive
                  ? SreaColors.bottomNavActive
                  : SreaColors.bottomNavInactive,
              size: 26,
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaEmergencyFAB — logs call + opens dialer
// ─────────────────────────────────────────────────────────────
class SreaEmergencyFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const SreaEmergencyFAB({super.key, this.onPressed});

  static const String emergencyNumber = '+639933768440';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        onPressed: onPressed ?? () => _showEmergencyDialog(context),
        backgroundColor: SreaColors.fab,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.phone_in_talk_rounded,
          color: SreaColors.fabIcon,
          size: 28,
        ),
      ),
    );
  }

  Future<void> _showEmergencyDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.modal),
        title: Text(
          'Emergency Call',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textPrimary),
        ),
        content: Text(
          'This will place an emergency call to San Rafael MDRRMO. Your location will be shared.\n\nContinue?',
          style: SreaText.bodySmall(
            context,
          ).copyWith(color: SreaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Call Now',
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.error, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Open dialer
    final Uri telUri = Uri(scheme: 'tel', path: emergencyNumber);
    try {
      await launchUrl(telUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open dialer. Please call $emergencyNumber manually.',
          ),
          backgroundColor: SreaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Log the call (fire‑and‑forget, no waiting)
    _logEmergencyCall(context);
  }

  Future<void> _logEmergencyCall(BuildContext context) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String barangay = '';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          barangay =
              placemarks.first.subLocality ?? placemarks.first.locality ?? '';
        }
      } catch (_) {}

      final api = ApiService();
      await api.createEmergencyCall({
        'location_lat': position.latitude,
        'location_lng': position.longitude,
        'barangay': barangay,
        'notes': 'Emergency call from SREA app',
      });

      // Optional: success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency call logged.'),
          backgroundColor: SreaColors.buttonUpdate,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Emergency call logging failed: $e');
      // Do not show error to user – the call already went through
    }
  }
}
