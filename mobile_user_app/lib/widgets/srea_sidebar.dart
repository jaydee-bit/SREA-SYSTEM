// File: srea_sidebar.dart
// Path: mobile_user_app/lib/widgets/srea_sidebar.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:srea_shared/srea_shared.dart';
import '../screens/about_screen.dart';

class SreaSidebar extends StatelessWidget {
  final String userName;
  final String email;
  final bool isVerified;
  final String activeRoute;
  final void Function(String route) onNavigate;
  final VoidCallback onLogout;
  final String? profileImageUrl; // supports network URL or local file path

  const SreaSidebar({
    super.key,
    required this.userName,
    required this.email,
    this.isVerified = false,
    this.activeRoute = '/home',
    required this.onNavigate,
    required this.onLogout,
    this.profileImageUrl,
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
            Padding(
              padding: EdgeInsets.fromLTRB(
                SreaSpacing.lg(context),
                SreaSpacing.xl(context),
                SreaSpacing.lg(context),
                SreaSpacing.lg(context),
              ),
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
                    child: ClipOval(
                      child:
                          profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? (profileImageUrl!.startsWith('http')
                                ? Image.network(
                                    profileImageUrl!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_outline_rounded,
                                      size: 38,
                                      color: SreaColors.primary,
                                    ),
                                  )
                                : Image.file(
                                    File(profileImageUrl!),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person_outline_rounded,
                                      size: 38,
                                      color: SreaColors.primary,
                                    ),
                                  ))
                          : const Icon(
                              Icons.person_outline_rounded,
                              size: 38,
                              color: SreaColors.primary,
                            ),
                    ),
                  ),
                  SizedBox(height: SreaSpacing.md(context)),
                  Text(
                    userName,
                    style: SreaText.titleLarge(context).copyWith(
                      color: SreaColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: SreaSpacing.xs(context)),
                  Text(
                    email,
                    style: SreaText.bodySmall(
                      context,
                    ).copyWith(color: SreaColors.bottomNavInactive),
                  ),
                  SizedBox(height: SreaSpacing.sm(context)),
                  if (isVerified)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SreaSpacing.sm(context),
                        vertical: SreaSpacing.xs(context),
                      ),
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
                          SizedBox(width: SreaSpacing.xs(context)),
                          Text(
                            'Verified',
                            style: SreaText.label(context).copyWith(
                              color: SreaColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SreaSpacing.sm(context),
                        vertical: SreaSpacing.xs(context),
                      ),
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
                          SizedBox(width: SreaSpacing.xs(context)),
                          Text(
                            'Pending Verification',
                            style: SreaText.label(
                              context,
                            ).copyWith(color: SreaColors.textOnPrimary),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            SizedBox(height: SreaSpacing.sm(context)),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: SreaSpacing.sm(context),
                  vertical: SreaSpacing.sm(context),
                ),
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
                  SizedBox(height: SreaSpacing.sm(context)),
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  SizedBox(height: SreaSpacing.sm(context)),
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
            Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
            Padding(
              padding: EdgeInsets.all(SreaSpacing.sm(context)),
              child: _SidebarLogoutButton(onLogout: onLogout),
            ),
          ],
        ),
      ),
    );
  }
}

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
      padding: EdgeInsets.only(bottom: SreaSpacing.xs(context)),
      child: Material(
        color: _isActive
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: SreaRadius.input,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
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
            padding: EdgeInsets.symmetric(
              horizontal: SreaSpacing.md(context),
              vertical: SreaSpacing.sm(context),
            ),
            child: Row(
              children: [
                Icon(
                  _isActive ? activeIcon : icon,
                  color: _isActive
                      ? SreaColors.textOnPrimary
                      : SreaColors.bottomNavInactive,
                  size: 22,
                ),
                SizedBox(width: SreaSpacing.avatarGap(context)),
                Text(
                  label,
                  style: SreaText.bodySmall(context).copyWith(
                    color: _isActive
                        ? SreaColors.textOnPrimary
                        : SreaColors.bottomNavInactive,
                    fontWeight: _isActive ? FontWeight.w700 : FontWeight.w400,
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
          padding: EdgeInsets.symmetric(
            horizontal: SreaSpacing.md(context),
            vertical: SreaSpacing.sm(context),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: SreaColors.textOnPrimary,
                size: 22,
              ),
              SizedBox(width: SreaSpacing.avatarGap(context)),
              Text(
                'Log out',
                style: SreaText.bodySmall(context).copyWith(
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
