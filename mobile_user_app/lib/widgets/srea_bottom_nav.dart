import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';

// ─────────────────────────────────────────────────────────────
// SreaBottomNav — Reusable bottom navigation bar with FAB slot
//
// Usage:
// Scaffold(
//   bottomNavigationBar: SreaBottomNav(
//     currentIndex: _currentIndex,
//     onTap: (i) => setState(() => _currentIndex = i),
//   ),
//   floatingActionButton: SreaEmergencyFAB(),
//   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// )
// ─────────────────────────────────────────────────────────────
class SreaBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const SreaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      
    ),
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
      notchMargin: 8,
      elevation: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            // Left 2 items
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [0, 1].map((i) => _NavButton(
                  data: _items[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                )).toList(),
              ),
            ),

            // Center FAB gap
            const SizedBox(width: 72),

            // Right 2 items
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [2, 3].map((i) => _NavButton(
                  data: _items[i],
                  isActive: currentIndex == i,
                  onTap: () => onTap(i),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Individual nav button
// ─────────────────────────────────────────────────────────────
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    
  });
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
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? data.activeIcon : data.icon,
              color: isActive
                  ? SreaColors.bottomNavActive
                  : SreaColors.bottomNavInactive,
              size: 32,
            ),
            const SizedBox(height: 3),
           
            
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SreaEmergencyFAB — Round red emergency call button
// Always used with FloatingActionButtonLocation.centerDocked
//
// Usage:
// floatingActionButton: SreaEmergencyFAB(),
// floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
// ─────────────────────────────────────────────────────────────
class SreaEmergencyFAB extends StatelessWidget {
  final VoidCallback? onPressed;

  const SreaEmergencyFAB({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        onPressed: onPressed ?? () => _showEmergencyDialog(context),
        backgroundColor: SreaColors.fab,
        elevation: 6,
        shape: const CircleBorder(), // ensures perfect circle
        child: const Icon(
          Icons.phone_in_talk_rounded,
          color: SreaColors.fabIcon,
          size: 28,
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.modal),
        title: Text(
          'Emergency Call',
          style: SreaText.titleLarge.copyWith(color: SreaColors.textPrimary),
        ),
        content: Text(
          'This will place an emergency call to San Rafael DRRMO. Continue?',
          style:
              SreaText.bodySmall.copyWith(color: SreaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: SreaText.bodySmall
                  .copyWith(color: SreaColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: launch phone dialer
              // launchUrl(Uri.parse('tel:+63XXXXXXXXXX'));
            },
            child: Text(
              'Call Now',
              style: SreaText.bodySmall.copyWith(
                color: SreaColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
