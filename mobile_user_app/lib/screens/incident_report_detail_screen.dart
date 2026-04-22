// File: incident_report_detail_screen.dart
// Path: mobile_user_app/lib/screens/incident_report_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../models/incident_report_model.dart';

class IncidentReportDetailScreen extends StatelessWidget {
  final IncidentReport report;
  const IncidentReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      appBar: AppBar(
        backgroundColor: SreaColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: SreaColors.textOnPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Incident Details',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Align(
                alignment: Alignment.centerRight,
                child: SreaBadge(
                  type: _statusToBadgeType(report.status),
                  label: report.status,
                  showDot: true,
                ),
              ),
              const SizedBox(height: 8),

              // Reporter badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (report.reporterRole == 'resident' &&
                          report.reporterIsVerified)
                      ? SreaColors.lowBg
                      : SreaColors.mediumBg,
                  borderRadius: SreaRadius.pill,
                ),
                child: Text(
                  report.reporterRole == 'resident'
                      ? (report.reporterIsVerified
                            ? 'Verified Resident'
                            : 'Unverified Resident')
                      : 'Non-Resident',
                  style: SreaText.label(context).copyWith(
                    color:
                        (report.reporterRole == 'resident' &&
                            report.reporterIsVerified)
                        ? SreaColors.low
                        : SreaColors.medium,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Incident type
              Text(
                report.type,
                style: SreaText.headlineSmall(
                  context,
                ).copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),

              // Location summary (barangay + details)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: SreaColors.primaryLight,
                  borderRadius: SreaRadius.input,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: SreaColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${report.barangay}${report.locationDetails != null ? ' • ${report.locationDetails}' : ''}',
                        style: SreaText.bodySmall(context).copyWith(
                          color: SreaColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date reported
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: SreaColors.textHint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(report.reportedAt),
                    style: SreaText.bodySmall(
                      context,
                    ).copyWith(color: SreaColors.textHint),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'Description',
                style: SreaText.bodyLarge(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                report.description,
                style: SreaText.bodySmall(
                  context,
                ).copyWith(color: SreaColors.textSecondary, height: 1.6),
              ),

              // Persons involved (if any)
              if (report.personsInvolved != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: SreaColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Persons involved: ${report.personsInvolved}',
                      style: SreaText.bodySmall(
                        context,
                      ).copyWith(color: SreaColors.textSecondary),
                    ),
                  ],
                ),
              ],

              // Photo (if any)
              if (report.photoPath != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Photo',
                  style: SreaText.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SreaRadius.md),
                  child: Image.file(
                    File(report.photoPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ],

              // Map preview
              const SizedBox(height: 20),
              Text(
                'Location on Map',
                style: SreaText.bodyLarge(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SreaRadius.md),
                  border: Border.all(color: SreaColors.border),
                ),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: report.coordinates,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mobile_user_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: report.coordinates,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                report.address,
                style: SreaText.label(
                  context,
                ).copyWith(color: SreaColors.textHint),
                textAlign: TextAlign.center,
              ),

              // MDRRMO contact footer
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SreaColors.primaryLight,
                  borderRadius: SreaRadius.input,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_in_talk_rounded,
                      size: 20,
                      color: SreaColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'For questions, contact MDRRMO',
                            style: SreaText.bodySmall(context).copyWith(
                              fontWeight: FontWeight.w700,
                              color: SreaColors.primary,
                            ),
                          ),
                          Text(
                            '(044) 123-4567',
                            style: SreaText.label(
                              context,
                            ).copyWith(color: SreaColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  String _monthAbbr(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];

  SreaBadgeType _statusToBadgeType(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return SreaBadgeType.resolved;
      case 'rejected':
        return SreaBadgeType.rejected;
      case 'under review':
        return SreaBadgeType.underReview;
      default:
        return SreaBadgeType.pending;
    }
  }
}
