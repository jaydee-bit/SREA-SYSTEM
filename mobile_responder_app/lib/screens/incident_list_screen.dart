import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident_report_model.dart';
import 'incident_detail_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_service.dart';

class IncidentListScreen extends StatefulWidget {
  final String? initialFilter; // 'active', 'resolved', or null for all
  final bool showAppBar; // whether to show its own app bar (default true)
  const IncidentListScreen({
    super.key,
    this.initialFilter,
    this.showAppBar = true,
  });

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  List<IncidentReport> _incidents = [];
  String _filterStatus = 'All';
  String? _filterBarangay;
  String _filterReporter = 'All';

  final ResponderNotificationService _notificationService =
      ResponderNotificationService();

  final List<String> _statusOptions = [
    'All',
    'Active', // pending + under review
    'Pending',
    'Under Review',
    'Resolved',
  ];
  final List<String> _barangayOptions = [
    'All',
    'Banca-Banca',
    'BMA – Balagtas',
    'Caingin',
    'Capihan',
    'Coral na Bato',
    'Cruz na Daan',
    'Dagat-Dagatan',
    'Diliman I',
    'Diliman II',
    'Libis',
    'Lico',
    'Maasim',
    'Mabalas-Balas',
    'Maguinao',
    'Maronquillo',
    'Paco',
    'Pansumaloc',
    'Pantubig',
    'Pasong Bangkal',
    'Pasong Callos',
    'Pasong Intsik',
    'Pinacpinacan',
    'Poblacion',
    'Pulo',
    'Pulong Bayabas',
    'Salapungan',
    'Sampaloc',
    'San Agustin',
    'San Roque',
    'Sapang Pahalang',
    'Talacsan',
    'Tambubong',
    'Tukod',
    'Ulingao',
  ];
  final List<String> _reporterOptions = [
    'All',
    'Verified Resident',
    'Unverified Resident',
    'Non-Resident',
  ];

  @override
  void initState() {
    super.initState();
    _loadMockIncidents();
    _applyInitialFilter();
    // Ensure notification service has mock data
    if (_notificationService.notifications.isEmpty) {
      _notificationService.loadMockNotifications();
    }
  }

  void _applyInitialFilter() {
    if (widget.initialFilter == 'active') {
      _filterStatus = 'Active';
    } else if (widget.initialFilter == 'resolved') {
      _filterStatus = 'Resolved';
    }
  }

  void _loadMockIncidents() {
    _incidents = [
      IncidentReport(
        id: '1',
        type: 'Flooding',
        description: 'Heavy flooding near the river. Several houses submerged.',
        photoPath: null,
        barangay: 'Poblacion',
        locationDetails: 'Near the church',
        coordinates: const LatLng(15.0153, 120.9996),
        address: 'Poblacion, San Rafael',
        status: 'Pending',
        reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
        personsInvolved: 25,
        reporterRole: 'resident',
        reporterIsVerified: true,
        responderNotes: null,
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
        status: 'Pending',
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        personsInvolved: 3,
        reporterRole: 'non_resident',
        reporterIsVerified: false,
        responderNotes: null,
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
        status: 'Under Review',
        reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        personsInvolved: 0,
        reporterRole: 'resident',
        reporterIsVerified: false,
        responderNotes: 'Dispatch team en route.',
      ),
    ];
    setState(() {});
  }

  List<IncidentReport> get _filteredIncidents {
    List<IncidentReport> filtered = List.from(_incidents);

    if (_filterStatus != 'All') {
      if (_filterStatus == 'Active') {
        filtered = filtered
            .where(
              (inc) => inc.status == 'Pending' || inc.status == 'Under Review',
            )
            .toList();
      } else {
        filtered = filtered
            .where((inc) => inc.status == _filterStatus)
            .toList();
      }
    }

    if (_filterBarangay != null && _filterBarangay != 'All') {
      filtered = filtered
          .where((inc) => inc.barangay == _filterBarangay)
          .toList();
    }

    switch (_filterReporter) {
      case 'Verified Resident':
        filtered = filtered
            .where(
              (inc) => inc.reporterRole == 'resident' && inc.reporterIsVerified,
            )
            .toList();
        break;
      case 'Unverified Resident':
        filtered = filtered
            .where(
              (inc) =>
                  inc.reporterRole == 'resident' && !inc.reporterIsVerified,
            )
            .toList();
        break;
      case 'Non-Resident':
        filtered = filtered
            .where((inc) => inc.reporterRole != 'resident')
            .toList();
        break;
      default:
        break;
    }

    filtered.sort((a, b) {
      int getPriority(IncidentReport inc) {
        if (inc.status == 'Pending') return 0;
        if (inc.status == 'Under Review') return 1;
        return 2;
      }

      final aPriority = getPriority(a);
      final bPriority = getPriority(b);
      if (aPriority != bPriority) return aPriority.compareTo(bPriority);
      if (aPriority == 0 || aPriority == 1) {
        final aIsVerified =
            a.reporterRole == 'resident' && a.reporterIsVerified;
        final bIsVerified =
            b.reporterRole == 'resident' && b.reporterIsVerified;
        if (aIsVerified != bIsVerified) return aIsVerified ? -1 : 1;
      }
      return b.reportedAt.compareTo(a.reportedAt);
    });

    return filtered;
  }

  Widget _buildBody() {
    final filtered = _filteredIncidents;
    final unreadCount = _notificationService.unreadCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and bell icon (only when showAppBar is false)
        if (!widget.showAppBar)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Incidents',
                  style: SreaText.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.w800,
                    color: SreaColors.textPrimary,
                  ),
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(),
                          ),
                        );
                      },
                      color: SreaColors.primary,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        // Title when showAppBar is true (no bell here – optional, but we keep it simple)
        if (widget.showAppBar)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Incidents',
              style: SreaText.headlineSmall(context).copyWith(
                fontWeight: FontWeight.w800,
                color: SreaColors.textPrimary,
              ),
            ),
          ),
        // Filters
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SreaDropdown<String>(
                      label: 'Status',
                      hint: 'All',
                      value: _filterStatus,
                      items: _statusOptions,
                      onChanged: (v) => setState(() => _filterStatus = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SreaDropdown<String>(
                      label: 'Barangay',
                      hint: 'All',
                      value: _filterBarangay ?? 'All',
                      items: _barangayOptions,
                      onChanged: (v) => setState(
                        () => _filterBarangay = v == 'All' ? null : v,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SreaDropdown<String>(
                label: 'Reporter Type',
                hint: 'All',
                value: _filterReporter,
                items: _reporterOptions,
                onChanged: (v) => setState(() => _filterReporter = v!),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'No incidents found',
                    style: SreaText.bodyLarge(
                      context,
                    ).copyWith(color: SreaColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final inc = filtered[index];
                    return _IncidentCard(incident: inc);
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return Scaffold(
        backgroundColor: SreaColors.background,
        body: _buildBody(),
      );
    }

    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: SreaColors.background,
      appBar: AppBar(
        toolbarHeight: 48,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
                color: SreaColors.textOnPrimary,
              )
            : null,
        backgroundColor: SreaColors.primary,
        elevation: 0,
        title: null,
      ),
      body: _buildBody(),
    );
  }
}

// _IncidentCard class unchanged – included for completeness
class _IncidentCard extends StatelessWidget {
  final IncidentReport incident;
  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    String reporterLabel;
    Color reporterColor;
    if (incident.reporterRole == 'resident') {
      if (incident.reporterIsVerified) {
        reporterLabel = 'Verified Resident';
        reporterColor = SreaColors.low;
      } else {
        reporterLabel = 'Unverified Resident';
        reporterColor = SreaColors.medium;
      }
    } else {
      reporterLabel = 'Non-Resident';
      reporterColor = SreaColors.textHint;
    }

    String dateStr =
        '${_monthAbbr(incident.reportedAt.month)} ${incident.reportedAt.day}, ${incident.reportedAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SreaCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IncidentDetailScreen(incident: incident),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    incident.type,
                    style: SreaText.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                SreaBadge(
                  type: _statusToBadgeType(incident.status),
                  label: incident.status,
                  showDot: true,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              incident.barangay,
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: reporterColor.withValues(alpha: 0.1),
                    borderRadius: SreaRadius.pill,
                  ),
                  child: Text(
                    reporterLabel,
                    style: SreaText.label(
                      context,
                    ).copyWith(color: reporterColor, fontSize: 10),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: SreaColors.textHint,
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: SreaText.label(
                    context,
                  ).copyWith(color: SreaColors.textHint),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incident.description.length > 100
                  ? '${incident.description.substring(0, 100)}...'
                  : incident.description,
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary),
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
}
