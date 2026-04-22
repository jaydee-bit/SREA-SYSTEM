// File: home_screen.dart
// Path: mobile_user_app/lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import '../widgets/srea_sidebar.dart';
import '../widgets/srea_bottom_nav.dart';
import 'auth/login_screen.dart';
import 'complete_profile_screen.dart';
import 'incident_reports_screen.dart';
import 'profile_screen.dart';
import 'announcements_screen.dart';
import 'traffic_advisories_screen.dart';
import 'privacy_policy_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // TOGGLE THESE FLAGS TO TEST DIFFERENT STATES
  final bool _isResident = true;
  final bool _hasAddressAndId = false;
  final bool _isVerified = false;

  final String _userName = 'Leon S. Kennedy';
  final String _email = 'leon@gmail.com';
  final String _barangay = 'Poblacion';
  String? _profileImageUrl;

  final bool _hasActiveAlert = false;
  final String _activeAlertLevel = 'none';

  final ValueNotifier<int> _unreadCountNotifier = ValueNotifier(0);

  final List<Map<String, dynamic>> _recentUpdates = [
    {
      'type': 'traffic',
      'title': 'Road closure along San Rafael–Angat highway',
      'location': 'Barangay Sampaloc',
      'time': '2 hrs ago',
      'badgeType': SreaBadgeType.medium,
      'badgeLabel': 'Medium',
      'icon': Icons.traffic_outlined,
    },
    {
      'type': 'alert',
      'title': 'Flooding reported near Madlum river area',
      'location': 'Barangay Madlum',
      'time': '5 hrs ago',
      'badgeType': SreaBadgeType.high,
      'badgeLabel': 'High',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'type': 'announcement',
      'title': 'Power interruption scheduled maintenance',
      'location': 'Barangay Poblacion',
      'time': 'Yesterday',
      'badgeType': null,
      'badgeLabel': null,
      'icon': Icons.campaign_outlined,
    },
  ];

  final List<Map<String, String>> _goBagItems = [
    {
      'text':
          'Valid ID, Birth Certificate and other important documents in a waterproof folder.',
    },
    {
      'text':
          '3-day supply of water (1 liter/person/day) and non-perishable food.',
    },
    {'text': 'First aid kit, flashlight, extra batteries, and whistle.'},
    {'text': 'Nearest evacuation center location saved on your phone.'},
    {'text': 'Emergency contact numbers of family, barangay, and MDRRMC.'},
  ];

  @override
  void initState() {
    super.initState();
    // Schedule after the first frame to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnreadCount();
      NotificationService().addListener(_updateUnreadCount);
    });
  }

  @override
  void dispose() {
    NotificationService().removeListener(_updateUnreadCount);
    _unreadCountNotifier.dispose();
    super.dispose();
  }

  void _updateUnreadCount() {
    _unreadCountNotifier.value = NotificationService().unreadCount;
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrafficAdvisoriesScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProfileScreen(onProfileImageUpdated: _updateProfileImage),
          ),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
    }
  }

  void _updateProfileImage(String? imagePath) {
    setState(() {
      _profileImageUrl = imagePath;
    });
  }

  void _onSidebarNavigate(String route) {
    switch (route) {
      case '/profile':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProfileScreen(onProfileImageUpdated: _updateProfileImage),
          ),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case '/announcements':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case '/traffic':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TrafficAdvisoriesScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case '/incidents':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IncidentReportsScreen()),
        ).then((_) => setState(() => _currentIndex = 0));
        break;
      case '/privacy':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
        );
        break;
      case '/about':
        break;
      default:
        debugPrint('Navigate to $route');
    }
  }

  void _onLogout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      drawer: SreaSidebar(
        userName: _userName,
        email: _email,
        isVerified: _isVerified,
        activeRoute: '/home',
        onNavigate: _onSidebarNavigate,
        onLogout: _onLogout,
        profileImageUrl: _profileImageUrl,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _SreaAppBar(
              userName: _userName.split(' ').first,
              unreadCountNotifier: _unreadCountNotifier,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _hasActiveAlert
                        ? _ActiveAlertBanner(level: _activeAlertLevel)
                        : const SreaAllClearBanner(),
                    const SizedBox(height: 20),

                    if (_isResident && !_hasAddressAndId) ...[
                      const _CompleteProfileBanner(),
                      const SizedBox(height: 16),
                    ] else if (_isResident && !_isVerified) ...[
                      const _PendingVerificationBanner(),
                      const SizedBox(height: 16),
                    ],

                    _SectionLabel(title: 'Emergency Preparedness'),
                    const SizedBox(height: 10),
                    const _PreparednessBanner(),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel(title: 'Recent Updates'),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NotificationsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'See all',
                            style: SreaText.label(context).copyWith(
                              color: SreaColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_recentUpdates.isEmpty)
                      _EmptyAlerts()
                    else
                      Column(
                        children: _recentUpdates.map((update) {
                          final badgeWidget = update['badgeType'] != null
                              ? SreaBadge(
                                  type: update['badgeType'] as SreaBadgeType,
                                  label: update['badgeLabel'] as String,
                                )
                              : const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SreaAlertCard(
                              title: update['title'] as String,
                              location: update['location'] as String,
                              time: update['time'] as String,
                              icon: update['icon'] as IconData,
                              badge: badgeWidget,
                              onTap: () {},
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),

                    _SectionLabel(title: 'Disaster Preparedness'),
                    const SizedBox(height: 10),
                    _GoBagCard(items: _goBagItems),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SreaBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: const SreaEmergencyFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ─── AppBar with notification badge ───────────────────────────────────
class _SreaAppBar extends StatelessWidget {
  final String userName;
  final ValueNotifier<int> unreadCountNotifier;

  const _SreaAppBar({
    required this.userName,
    required this.unreadCountNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: SreaColors.primary),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: SreaRadius.input,
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: SreaColors.textOnPrimary,
                size: 22,
              ),
            ),
          ),
          SizedBox(width: SreaSpacing.iconGap(context)),
          Expanded(
            child: Text(
              'Welcome, $userName!',
              style: SreaText.titleLarge(context).copyWith(
                color: SreaColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: unreadCountNotifier,
            builder: (context, count, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: SreaColors.textOnPrimary,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: SreaColors.buttonReport,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Active alert banner ─────────────────────────────────────────────
class _ActiveAlertBanner extends StatelessWidget {
  final String level;
  const _ActiveAlertBanner({required this.level});

  Color get _color {
    switch (level) {
      case 'critical':
        return SreaColors.critical;
      case 'high':
        return SreaColors.high;
      case 'medium':
        return SreaColors.medium;
      default:
        return SreaColors.low;
    }
  }

  Color get _bgColor {
    switch (level) {
      case 'critical':
        return SreaColors.criticalBg;
      case 'high':
        return SreaColors.highBg;
      case 'medium':
        return SreaColors.mediumBg;
      default:
        return SreaColors.lowBg;
    }
  }

  String get _message {
    switch (level) {
      case 'critical':
        return 'Critical alert active in your area!';
      case 'high':
        return 'High-risk alert in your area';
      case 'medium':
        return 'Advisory issued for your area';
      default:
        return 'Low-level alert in your area';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SreaSpacing.cardPaddingSmall(context),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: SreaRadius.card,
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.warning_amber_rounded, color: _color, size: 20),
          ),
          SizedBox(width: SreaSpacing.iconGap(context)),
          Expanded(
            child: Text(
              _message,
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: _color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: SreaText.bodySmall(context).copyWith(
        color: SreaColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─── Empty alerts state ─────────────────────────────────────────────
class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SreaSpacing.cardPadding(context),
      decoration: BoxDecoration(
        color: SreaColors.surface,
        borderRadius: SreaRadius.card,
        border: Border.all(color: SreaColors.divider),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: SreaColors.low,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No recent updates',
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Preparedness banner ────────────────────────────────────────────
class _PreparednessBanner extends StatelessWidget {
  const _PreparednessBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: SreaSpacing.cardPadding(context),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SreaColors.primaryDark, SreaColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: SreaRadius.card,
        boxShadow: [
          BoxShadow(
            color: SreaColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.safety_check_rounded,
                color: SreaColors.textOnPrimary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Be Ready, Be Safe',
                  style: SreaText.titleLarge(context).copyWith(
                    color: SreaColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '• Always have your go‑bag ready\n'
            '• Know your barangay evacuation center\n'
            '• Save emergency contacts: MDRRMO, Barangay, NDRRMC\n'
            '• Monitor official weather updates from PAGASA\n'
            '• Stay tuned to SREA alerts for real‑time information',
            style: SreaText.bodySmall(
              context,
            ).copyWith(color: SreaColors.textOnPrimary, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: SreaRadius.pill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone_in_talk_rounded,
                  size: 14,
                  color: SreaColors.textOnPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Emergency Hotline: (044) 123-4567',
                  style: SreaText.label(context).copyWith(
                    color: SreaColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Complete Profile Banner (Blue) ─────────────────────────────────
class _CompleteProfileBanner extends StatelessWidget {
  const _CompleteProfileBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SreaSpacing.cardPaddingSmall(context),
      decoration: BoxDecoration(
        color: SreaColors.primaryLight,
        borderRadius: SreaRadius.card,
        border: Border.all(color: SreaColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_document, color: SreaColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Get verified',
                  style: SreaText.bodySmall(context).copyWith(
                    color: SreaColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Verified reports are prioritized by MDRRMO. Complete your profile to increase credibility.',
                  style: SreaText.label(
                    context,
                  ).copyWith(color: SreaColors.primary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompleteProfileScreen(),
                ),
              );
            },
            child: Text(
              'Verify now',
              style: SreaText.label(context).copyWith(
                color: SreaColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pending Verification Banner (Yellow) ───────────────────────────
class _PendingVerificationBanner extends StatelessWidget {
  const _PendingVerificationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SreaSpacing.cardPaddingSmall(context),
      decoration: BoxDecoration(
        color: SreaColors.mediumBg,
        borderRadius: SreaRadius.card,
        border: Border.all(color: SreaColors.medium.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.pending_actions_rounded,
            color: SreaColors.medium,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification pending',
                  style: SreaText.bodySmall(context).copyWith(
                    color: SreaColors.medium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Your account is under review. You\'ll be notified when approved.',
                  style: SreaText.label(
                    context,
                  ).copyWith(color: SreaColors.medium),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Go-Bag card ────────────────────────────────────────────────────
class _GoBagCard extends StatelessWidget {
  final List<Map<String, String>> items;
  const _GoBagCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return SreaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SreaColors.primaryLight,
                  borderRadius: SreaRadius.input,
                ),
                child: const Icon(
                  Icons.backpack_outlined,
                  color: SreaColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: SreaSpacing.iconGap(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Go-Bag Checklist',
                      style: SreaText.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: SreaColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Be ready in case of evacuation',
                      style: SreaText.label(
                        context,
                      ).copyWith(color: SreaColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: SreaColors.divider, height: 1),
          const SizedBox(height: 14),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < items.length - 1 ? 10 : 0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SreaColors.primaryLight,
                  borderRadius: SreaRadius.input,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: SreaColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: SreaText.label(context).copyWith(
                            color: SreaColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SreaSpacing.iconGap(context)),
                    Expanded(
                      child: Text(
                        item['text']!,
                        style: SreaText.bodySmall(
                          context,
                        ).copyWith(color: SreaColors.textPrimary, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
