// File: traffic_advisories_screen.dart
// Path: mobile_user_app/lib/screens/traffic_advisories_screen.dart

import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'traffic_advisory_detail_screen.dart';

class TrafficAdvisory {
  final int id;
  final String title;
  final String description;
  final String location;
  final SreaBadgeType severity;
  final DateTime publishedAt;
  final DateTime? effectiveFrom;
  final DateTime? effectiveTo;

  TrafficAdvisory({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.severity,
    required this.publishedAt,
    this.effectiveFrom,
    this.effectiveTo,
  });

  String get formattedDate {
    return '${_monthAbbr(publishedAt.month)} ${publishedAt.day}, ${publishedAt.year}';
  }

  String _monthAbbr(int month) {
    const months = [
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
    ];
    return months[month - 1];
  }

  String get effectiveDateRange {
    if (effectiveFrom == null && effectiveTo == null) return '';
    if (effectiveFrom != null && effectiveTo == null) {
      return 'From ${_formatDate(effectiveFrom!)}';
    }
    if (effectiveFrom == null && effectiveTo != null) {
      return 'Until ${_formatDate(effectiveTo!)}';
    }
    return '${_formatDate(effectiveFrom!)} – ${_formatDate(effectiveTo!)}';
  }

  String _formatDate(DateTime date) {
    return '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  }
}

// Mock data – severity labels now match Recent Updates case
final List<TrafficAdvisory> _mockAdvisories = [
  TrafficAdvisory(
    id: 1,
    title: 'Major road closure – San Rafael‑Angat highway',
    description:
        'The highway will be closed for repair from April 25 to April 30, 2026. Use alternate routes via Barangay Sampaloc.',
    location: 'Barangay Sampaloc',
    severity: SreaBadgeType.high,
    publishedAt: DateTime(2026, 4, 20),
    effectiveFrom: DateTime(2026, 4, 25),
    effectiveTo: DateTime(2026, 4, 30),
  ),
  TrafficAdvisory(
    id: 2,
    title: 'Heavy traffic due to market day',
    description:
        'Expect heavy traffic around Poblacion market on April 22, 2026, from 7 AM to 2 PM. Plan your trip accordingly.',
    location: 'Poblacion',
    severity: SreaBadgeType.medium,
    publishedAt: DateTime(2026, 4, 19),
    effectiveFrom: DateTime(2026, 4, 22),
    effectiveTo: null,
  ),
  TrafficAdvisory(
    id: 3,
    title: 'Road painting on shoulder lane',
    description:
        'Shoulder lane painting along National Highway from April 21 to April 23. No lane closures, but proceed with caution.',
    location: 'National Highway',
    severity: SreaBadgeType.low,
    publishedAt: DateTime(2026, 4, 18),
    effectiveFrom: DateTime(2026, 4, 21),
    effectiveTo: DateTime(2026, 4, 23),
  ),
];

class TrafficAdvisoriesScreen extends StatefulWidget {
  const TrafficAdvisoriesScreen({super.key});

  @override
  State<TrafficAdvisoriesScreen> createState() =>
      _TrafficAdvisoriesScreenState();
}

class _TrafficAdvisoriesScreenState extends State<TrafficAdvisoriesScreen> {
  bool _isLoading = true;
  List<TrafficAdvisory> _advisories = [];

  @override
  void initState() {
    super.initState();
    _loadAdvisories();
  }

  Future<void> _loadAdvisories() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _advisories = _mockAdvisories;
      _isLoading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadAdvisories();
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
          'Traffic Advisories',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          color: SreaColors.primary,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: SreaColors.primary),
                )
              : _advisories.isEmpty
              ? _EmptyAdvisories()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _advisories.length,
                  itemBuilder: (context, index) {
                    final advisory = _advisories[index];
                    return _AdvisoryCard(
                      advisory: advisory,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TrafficAdvisoryDetailScreen(advisory: advisory),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  final TrafficAdvisory advisory;
  final VoidCallback onTap;

  const _AdvisoryCard({required this.advisory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasLongDesc = advisory.description.length > 100;
    final preview = hasLongDesc
        ? '${advisory.description.substring(0, 100)}...'
        : advisory.description;

    // Use same label casing as Recent Updates
    final String severityLabel =
        advisory.severity.name[0].toUpperCase() +
        advisory.severity.name.substring(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SreaCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with severity badge (same styling as Recent Updates)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    advisory.title,
                    style: SreaText.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w700,
                      color: SreaColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SreaBadge(
                  type: advisory.severity,
                  label: severityLabel,
                  showDot: true,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Larger mock map thumbnail (80x80)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SreaColors.primaryLight,
                    borderRadius: SreaRadius.input,
                    border: Border.all(color: SreaColors.border),
                  ),
                  child: const Icon(
                    Icons.map_outlined,
                    size: 40,
                    color: SreaColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: SreaColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              advisory.location,
                              style: SreaText.bodySmall(context).copyWith(
                                color: SreaColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Published date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: SreaColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            advisory.formattedDate,
                            style: SreaText.label(
                              context,
                            ).copyWith(color: SreaColors.textHint),
                          ),
                        ],
                      ),
                      // Effective date range (if any)
                      if (advisory.effectiveDateRange.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 12,
                              color: SreaColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              advisory.effectiveDateRange,
                              style: SreaText.label(
                                context,
                              ).copyWith(color: SreaColors.textHint),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Description preview
            Text(
              preview,
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View details →',
                style: SreaText.label(context).copyWith(
                  color: SreaColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAdvisories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.traffic_outlined, size: 64, color: SreaColors.textHint),
          const SizedBox(height: 16),
          Text(
            'No traffic advisories',
            style: SreaText.bodyLarge(
              context,
            ).copyWith(color: SreaColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates.',
            style: SreaText.bodySmall(
              context,
            ).copyWith(color: SreaColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
