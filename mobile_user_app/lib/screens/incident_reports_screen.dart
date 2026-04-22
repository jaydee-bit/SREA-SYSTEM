import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident_report_model.dart';
import 'report_incident_screen.dart';
import 'incident_report_detail_screen.dart';

class IncidentReportsScreen extends StatefulWidget {
  const IncidentReportsScreen({super.key});

  @override
  State<IncidentReportsScreen> createState() => _IncidentReportsScreenState();
}

class _IncidentReportsScreenState extends State<IncidentReportsScreen> {
  List<IncidentReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  void _loadReports() {
    _reports = [
      IncidentReport(
        id: '1',
        type: 'Flooding',
        description:
            'Heavy flooding near the river. Several houses already submerged.',
        photoPath: null,
        barangay: 'Poblacion',
        locationDetails: 'Near the church',
        coordinates: const LatLng(15.0153, 120.9996),
        address: 'Poblacion, San Rafael',
        status: 'Pending',
        reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        personsInvolved: 25,
        reporterRole: 'resident',
        reporterIsVerified: true,
      ),
      IncidentReport(
        id: '2',
        type: 'Road Accident',
        description:
            'Two vehicles collided near the highway junction. Injuries reported.',
        photoPath: null,
        barangay: 'Sampaloc',
        locationDetails: 'Highway junction',
        coordinates: const LatLng(15.0153, 120.9996),
        address: 'Sampaloc, San Rafael',
        status: 'Under Review',
        reportedAt: DateTime.now().subtract(const Duration(days: 2)),
        personsInvolved: 3,
        reporterRole: 'non_resident',
        reporterIsVerified: false,
      ),
      IncidentReport(
        id: '3',
        type: 'Fire',
        description: 'Fire in a residential area. Firefighters are on site.',
        photoPath: null,
        barangay: 'Caingin',
        locationDetails: 'Near the market',
        coordinates: const LatLng(15.0153, 120.9996),
        address: 'Caingin, San Rafael',
        status: 'Resolved',
        reportedAt: DateTime.now().subtract(const Duration(days: 5)),
        personsInvolved: 0,
        reporterRole: 'resident',
        reporterIsVerified: false,
      ),
    ];
    setState(() {});
  }

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
          'My Incident Reports',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 4,
              borderRadius: SreaRadius.button,
              shadowColor: SreaColors.buttonReport.withValues(alpha: 0.4),
              child: SreaButton.report(
                label: 'Report Incident',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReportIncidentScreen(),
                    ),
                  ).then((_) => _loadReports());
                },
                fullWidth: true,
                icon: Icons.add_alert_rounded,
              ),
            ),
          ),
          Expanded(
            child: _reports.isEmpty
                ? _EmptyReports()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      return _ReportCard(
                        report: report,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                IncidentReportDetailScreen(report: report),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IncidentReport report;
  final VoidCallback onTap;
  const _ReportCard({required this.report, required this.onTap});

  @override
  Widget build(BuildContext context) {
    String descriptionPreview = report.description.length > 80
        ? '${report.description.substring(0, 80)}...'
        : report.description;
    String reporterBadgeText;
    Color reporterBadgeColor;
    if (report.reporterRole == 'resident') {
      if (report.reporterIsVerified) {
        reporterBadgeText = 'Verified Resident';
        reporterBadgeColor = SreaColors.low;
      } else {
        reporterBadgeText = 'Unverified Resident';
        reporterBadgeColor = SreaColors.medium;
      }
    } else {
      reporterBadgeText = 'Non-Resident';
      reporterBadgeColor = SreaColors.textHint;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SreaCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.type,
                        style: SreaText.bodyLarge(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.barangay,
                        style: SreaText.bodySmall(
                          context,
                        ).copyWith(color: SreaColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(report.reportedAt),
                        style: SreaText.label(
                          context,
                        ).copyWith(color: SreaColors.textHint),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SreaBadge(
                      type: _statusToBadgeType(report.status),
                      label: report.status,
                      showDot: true,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: reporterBadgeColor.withValues(alpha: 0.1),
                        borderRadius: SreaRadius.pill,
                      ),
                      child: Text(
                        reporterBadgeText,
                        style: SreaText.label(context).copyWith(
                          color: reporterBadgeColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (descriptionPreview.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                descriptionPreview,
                style: SreaText.bodySmall(
                  context,
                ).copyWith(color: SreaColors.textSecondary, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (report.locationDetails != null &&
                report.locationDetails!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 12,
                    color: SreaColors.textHint,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      report.locationDetails!,
                      style: SreaText.label(
                        context,
                      ).copyWith(color: SreaColors.textHint),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onTap,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View details →',
                  style: SreaText.label(context).copyWith(
                    color: SreaColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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

class _EmptyReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report_off_outlined, size: 64, color: SreaColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No incident reports',
            style: SreaText.bodyLarge(
              context,
            ).copyWith(color: SreaColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button above to report an incident.',
            style: SreaText.bodySmall(
              context,
            ).copyWith(color: SreaColors.textHint),
          ),
        ],
      ),
    );
  }
}
