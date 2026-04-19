// File: incident_report_screen.dart
// Path: mobile_user_app/lib/screens/incident_report_screen.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';

class IncidentReportScreen extends StatelessWidget {
  const IncidentReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you would get this from your auth service.
    // For demo, we assume not verified – replace with actual check.
    final bool isVerified = false; // TODO: replace with actual verification status

    return Scaffold(
      backgroundColor: SreaColors.background,
      appBar: AppBar(
        backgroundColor: SreaColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SreaColors.textOnPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Incident',
          style: SreaText.titleLarge(context).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: isVerified
              ? _ReportForm()
              : _LockedMessage(),
        ),
      ),
    );
  }
}

class _LockedMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 64, color: SreaColors.textHint),
          const SizedBox(height: 24),
          Text(
            'Incident Reporting Unavailable',
            style: SreaText.headlineSmall(context).copyWith(
              color: SreaColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Only verified residents of San Rafael can report incidents.\n\n'
            'Please complete your profile and wait for admin verification.',
            style: SreaText.bodySmall(context).copyWith(
              color: SreaColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SreaButton(
            label: 'Go to Profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            fullWidth: false,
            icon: Icons.person_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _ReportForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Placeholder for the actual incident report form
    return Center(
      child: Text(
        'Incident report form will be here',
        style: SreaText.bodyLarge(context).copyWith(color: SreaColors.textSecondary),
      ),
    );
  }
}