import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import '../widgets/srea_weather_card.dart';
import '../widgets/srea_sidebar.dart';
import '../widgets/srea_bottom_nav.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: Replace with actual user data from your auth service
  final String _userName = 'Leon S. Kennedy';
  final String _email = 'leon@gmail.com';
  final String _barangay = 'Brgy. Poblacion';
  final bool _isVerified = true;

  // Mock alert status — replace with actual API data
  final bool _hasActiveAlert = false;
  final String _activeAlertLevel = 'none'; // 'critical','high','medium','low'

  // Mock recent alerts — replace with actual API data
  final List<Map<String, dynamic>> _recentAlerts = [
    {
      'title': 'Road closure along San Rafael–Angat highway',
      'location': 'Barangay Sampaloc',
      'time': '2 hrs ago',
      'type': SreaBadgeType.medium,
      'badgeLabel': 'Medium',
      'icon': Icons.warning_amber_rounded,
    },
    {
      'title': 'Flooding reported near Madlum river area',
      'location': 'Barangay Madlum',
      'time': '5 hrs ago',
      'type': SreaBadgeType.high,
      'badgeLabel': 'High',
      'icon': Icons.water_outlined,
    },
    {
      'title': 'Power interruption scheduled maintenance',
      'location': 'Barangay Poblacion',
      'time': 'Yesterday',
      'type': SreaBadgeType.low,
      'badgeLabel': 'Low',
      'icon': Icons.flash_off_outlined,
    },
  ];

  // Disaster preparedness checklist items
  final List<Map<String, String>> _goBagItems = [
    {
      'text':
          'Valid ID, Birth Certificate and other important documents in a waterproof folder.',
    },
    {
      'text':
          '3-day supply of water (1 liter/person/day) and non-perishable food.',
    },
    {
      'text':
          'First aid kit, flashlight, extra batteries, and whistle.',
    },
    {
      'text':
          'Nearest evacuation center location saved on your phone.',
    },
    {
      'text':
          'Emergency contact numbers of family, barangay, and NDRRMC.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      drawer: SreaSidebar(
        userName: _userName,
        email: _email,
        isVerified: _isVerified,
        activeRoute: '/home',
        onNavigate: (route) {
          // TODO: handle navigation per route
          debugPrint('Navigate to $route');
        },
        onLogout: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────────────────
            _SreaAppBar(userName: _userName.split(' ').first),

            // ── Scrollable content ───────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Alert Status Banner ──────────────────
                    _hasActiveAlert
                        ? _ActiveAlertBanner(level: _activeAlertLevel)
                        : const SreaAllClearBanner(),

                    const SizedBox(height: 20),

                    // ── Section: Current Conditions ──────────
                    _SectionLabel(title: 'Current Conditions'),
                    const SizedBox(height: 10),
                    SreaWeatherCard(barangay: _barangay),

                    const SizedBox(height: 24),

                    // ── Section: Recent Alerts ───────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel(title: 'Recent Alerts'),
                        GestureDetector(
                          onTap: () {
                            // TODO: navigate to all alerts screen
                          },
                          child: Text(
                            'See all',
                            style: SreaText.label.copyWith(
                              color: SreaColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_recentAlerts.isEmpty)
                      _EmptyAlerts()
                    else
                      Column(
                        children: _recentAlerts.map((alert) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10),
                            child: SreaAlertCard(
                              title: alert['title'] as String,
                              location: alert['location'] as String,
                              time: alert['time'] as String,
                              icon: alert['icon'] as IconData,
                              badge: SreaBadge(
                                type: alert['type'] as SreaBadgeType,
                                label: alert['badgeLabel'] as String,
                              ),
                              onTap: () {
                                // TODO: navigate to alert detail
                              },
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    // ── Section: Disaster Preparedness ───────
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

      // ── Bottom Navigation + FAB ──────────────────────────
      bottomNavigationBar: SreaBottomNav(
        currentIndex: 0,
        onTap: (i) {
          // TODO: handle tab switching
          debugPrint('Tab tapped: $i');
        },
      ),
      floatingActionButton: const SreaEmergencyFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AppBar with hamburger + greeting
// ─────────────────────────────────────────────────────────────
class _SreaAppBar extends StatelessWidget {
  final String userName;

  const _SreaAppBar({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: SreaColors.primary,
      ),
      child: Row(
        children: [
          // Hamburger menu
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
          SizedBox(width: SreaSpacing.iconGap),
          Expanded(
            child: Text(
              'Welcome, $userName!',
              style: SreaText.titleLarge.copyWith(
                color: SreaColors.textOnPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // Notification bell
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: SreaColors.textOnPrimary,
                  size: 24,
                ),
                onPressed: () {
                  // TODO: open notifications
                },
              ),
              // Notification dot
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: SreaColors.buttonReport,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Active alert banner (shown when there's an active alert)
// ─────────────────────────────────────────────────────────────
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
      padding: SreaSpacing.cardPaddingSmall,
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
            child: Icon(
              Icons.warning_amber_rounded,
              color: _color,
              size: 20,
            ),
          ),
          SizedBox(width: SreaSpacing.iconGap),
          Expanded(
            child: Text(
              _message,
              style: SreaText.bodySmall.copyWith(
                color: _color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: SreaText.bodySmall.copyWith(
        color: SreaColors.textSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Empty alerts state
// ─────────────────────────────────────────────────────────────
class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SreaSpacing.cardPadding,
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
              'No recent alerts',
              style: SreaText.bodySmall.copyWith(
                color: SreaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Go-Bag checklist card
// ─────────────────────────────────────────────────────────────
class _GoBagCard extends StatelessWidget {
  final List<Map<String, String>> items;

  const _GoBagCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return SreaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              SizedBox(width: SreaSpacing.iconGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Go-Bag Checklist',
                      style: SreaText.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: SreaColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Be ready in case of evacuation',
                      style: SreaText.label.copyWith(
                        color: SreaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: SreaColors.divider, height: 1),
          const SizedBox(height: 14),

          // Checklist items
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
                          style: SreaText.label.copyWith(
                            color: SreaColors.textOnPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: SreaSpacing.iconGap),
                    Expanded(
                      child: Text(
                        item['text']!,
                        style: SreaText.bodySmall.copyWith(
                          color: SreaColors.textPrimary,
                          height: 1.5,
                        ),
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

