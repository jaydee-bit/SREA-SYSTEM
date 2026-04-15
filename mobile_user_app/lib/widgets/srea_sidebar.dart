import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import '../screens/about_screen.dart';

// ─────────────────────────────────────────────────────────────
// SreaSidebar — Left drawer with user profile + nav items
//
// Usage: Add as the drawer in your Scaffold:
// Scaffold(
//   drawer: SreaSidebar(
//     userName: 'Leon S. Kennedy',
//     email: 'leon@gmail.com',
//     isVerified: true,
//     onNavigate: (route) => Navigator.pushNamed(context, route),
//     onLogout: () { ... },
//   ),
// )
// ─────────────────────────────────────────────────────────────
class SreaSidebar extends StatelessWidget {
  final String userName;
  final String email;
  final bool isVerified;
  final String activeRoute;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;

  const SreaSidebar({
    super.key,
    required this.userName,
    required this.email,
    this.isVerified = false,
    this.activeRoute = '/home',
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.80,
      backgroundColor: SreaColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile section ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: SreaColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: SreaColors.primary,
                      size: 38,
                    ),
                  ),
                  // TODO: Replace icon with user profile photo:
                  // ClipOval(child: Image.network(photoUrl, fit: BoxFit.cover))

                  const SizedBox(height: 14),

                  // Name
                  Text(
                    userName,
                    style: SreaText.titleLarge.copyWith(
                      color: SreaColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Email
                  Text(
                    email,
                    style: SreaText.bodySmall.copyWith(
                      color: SreaColors.bottomNavInactive,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Verified badge
                  if (isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: SreaRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: SreaColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: SreaText.label.copyWith(
                              color: SreaColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: SreaRadius.pill,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pending_outlined,
                            size: 14,
                            color: SreaColors.textOnPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pending Verification',
                            style: SreaText.label.copyWith(
                              color: SreaColors.textOnPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15),
            ),

            const SizedBox(height: 8),

            // ── Nav items ─────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                children: [
                  _SidebarItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home',
                    route: '/home',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                  _SidebarItem(
                    icon: Icons.campaign_outlined,
                    activeIcon: Icons.campaign_rounded,
                    label: 'Announcements',
                    route: '/announcements',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                  _SidebarItem(
                    icon: Icons.traffic_outlined,
                    activeIcon: Icons.traffic_rounded,
                    label: 'Traffic Advisories',
                    route: '/traffic',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                  _SidebarItem(
                    icon: Icons.report_outlined,
                    activeIcon: Icons.report_rounded,
                    label: 'Incident Reports',
                    route: '/incidents',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                  _SidebarItem(
                    icon: Icons.phone_missed_outlined,
                    activeIcon: Icons.phone_missed_rounded,
                    label: 'Emergency Call History',
                    route: '/call-history',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                  _SidebarItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile',
                    route: '/profile',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),

                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 8),

                  _SidebarItem(
                    icon: Icons.privacy_tip_outlined,
                    activeIcon: Icons.privacy_tip_rounded,
                    label: 'Privacy Policy',
                    route: '/privacy',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                  _SidebarItem(
                    icon: Icons.groups_outlined,
                    activeIcon: Icons.groups_rounded,
                    label: 'About Us',
                    route: '/about',
                    activeRoute: activeRoute,
                    onTap: onNavigate,
                  ),
                ],
              ),
            ),

            // ── Logout ────────────────────────────────────────
            Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: _SidebarLogoutButton(onLogout: onLogout),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Individual sidebar nav item
// ─────────────────────────────────────────────────────────────
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String activeRoute;
  final void Function(String) onTap;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.activeRoute,
    required this.onTap,
  });

  bool get _isActive => activeRoute == route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: _isActive
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: SreaRadius.input,
        child: InkWell(
          onTap: () {
            Navigator.pop(context); // close drawer
            if (route == '/about') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            } else {
              onTap(route);
            }
          },
          borderRadius: SreaRadius.input,
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(
                  _isActive ? activeIcon : icon,
                  color: _isActive
                      ? SreaColors.textOnPrimary
                      : SreaColors.bottomNavInactive,
                  size: 22,
                ),
                SizedBox(width: SreaSpacing.avatarGap),
                Text(
                  label,
                  style: SreaText.bodySmall.copyWith(
                    color: _isActive
                        ? SreaColors.textOnPrimary
                        : SreaColors.bottomNavInactive,
                    fontWeight: _isActive
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                if (_isActive) ...[
                  const Spacer(),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: SreaColors.textOnPrimary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logout button
// ─────────────────────────────────────────────────────────────
class _SidebarLogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _SidebarLogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: SreaRadius.input,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onLogout();
        },
        borderRadius: SreaRadius.input,
        splashColor: SreaColors.error.withValues(alpha: 0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 13),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: SreaColors.textOnPrimary,
                size: 22,
              ),
              SizedBox(width: SreaSpacing.avatarGap),
              Text(
                'Log out',
                style: SreaText.bodySmall.copyWith(
                  color: SreaColors.textOnPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
