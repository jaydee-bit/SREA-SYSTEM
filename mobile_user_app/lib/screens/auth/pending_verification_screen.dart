// File: pending_verification_screen.dart
// Path: mobile_user_app/lib/screens/auth/pending_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'login_screen.dart';

class PendingVerificationScreen extends StatelessWidget {
  const PendingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated checkmark icon (pending style)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: SreaColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: SreaColors.primary, width: 2),
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 56,
                        color: SreaColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Account Pending Verification',
                  style: SreaText.headlineSmall(context).copyWith(
                    color: SreaColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Thank you for registering with SREA.\n\n'
                  'Your account is currently under review by the San Rafael DRRMO. '
                  'You will receive an email notification once your account is verified.\n\n'
                  'This usually takes 24–48 hours.',
                  style: SreaText.bodySmall(
                    context,
                  ).copyWith(color: SreaColors.textSecondary, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SreaColors.primaryLight,
                    borderRadius: SreaRadius.card,
                    border: Border.all(
                      color: SreaColors.borderFocused.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: SreaColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Check your email for updates',
                              style: SreaText.bodySmall(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: SreaColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.support_agent_outlined,
                            size: 20,
                            color: SreaColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Contact DRRMO if you have questions',
                              style: SreaText.bodySmall(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: SreaColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Back to Login button
                SreaButton(
                  label: 'Back to Login',
                  onPressed: () {
                    // Clear any pending session (if needed) and go to login
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  fullWidth: true,
                  size: SreaButtonSize.large,
                  icon: Icons.arrow_back_rounded,
                ),

                const SizedBox(height: 12),

                // Contact link
                TextButton(
                  onPressed: () {
                    // TODO: open email or phone dialer
                    // e.g., launchUrl(Uri.parse('mailto:drrmo@sanrafael.gov.ph'));
                  },
                  child: Text(
                    'Contact DRRMO Support',
                    style: SreaText.label(context).copyWith(
                      color: SreaColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
