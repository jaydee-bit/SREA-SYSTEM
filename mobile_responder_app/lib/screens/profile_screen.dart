import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // TODO: Replace with actual responder data from API
  final String responderName = 'John M. Responder';
  final String responderEmail = 'john.responder@sanrafael.gov.ph';
  final String responderRole = 'Emergency Responder';
  final String responderBadge = 'Verified Responder';
  final int incidentsHandled = 47;
  final int activeIncidents = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SreaColors.primaryDark, SreaColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: SreaColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        size: 56,
                        color: SreaColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      responderName,
                      style: SreaText.headlineSmall(context).copyWith(
                        color: SreaColors.textOnPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      responderEmail,
                      style: SreaText.bodySmall(context).copyWith(
                        color: SreaColors.bottomNavInactive,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: SreaColors.lowBg,
                        borderRadius: SreaRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded, size: 14, color: SreaColors.low),
                          const SizedBox(width: 6),
                          Text(
                            responderBadge,
                            style: SreaText.label(context).copyWith(
                              color: SreaColors.low,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Stats cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Incidents Handled',
                        value: incidentsHandled.toString(),
                        icon: Icons.check_circle_outline_rounded,
                        color: SreaColors.buttonUpdate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Active Incidents',
                        value: activeIncidents.toString(),
                        icon: Icons.pending_actions_rounded,
                        color: SreaColors.medium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Role card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SreaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role Information',
                        style: SreaText.bodyLarge(context).copyWith(
                          fontWeight: FontWeight.w700,
                          color: SreaColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: SreaColors.primaryLight,
                              borderRadius: SreaRadius.input,
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              size: 20,
                              color: SreaColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Responder Role',
                                  style: SreaText.label(context).copyWith(
                                    color: SreaColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  responderRole,
                                  style: SreaText.bodySmall(context).copyWith(
                                    color: SreaColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SreaButton.report(
                  label: 'Logout',
                  onPressed: () => _confirmLogout(context),
                  fullWidth: true,
                  icon: Icons.logout_rounded,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.modal),
        title: Text(
          'Logout',
          style: SreaText.titleLarge(context).copyWith(color: SreaColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear session, tokens, etc.
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'Logout',
              style: SreaText.bodySmall(context).copyWith(
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SreaColors.surface,
        borderRadius: SreaRadius.card,
        boxShadow: [
          BoxShadow(
            color: SreaColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: SreaText.headlineSmall(context).copyWith(
              color: SreaColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: SreaText.label(context).copyWith(
              color: SreaColors.textSecondary,
            ),
            textAlign: TextAlign.center, // ✅ correct placement on Text widget
          ),
        ],
      ),
    );
  }
}