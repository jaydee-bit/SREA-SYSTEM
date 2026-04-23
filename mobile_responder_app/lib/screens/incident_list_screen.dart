import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident_report_model.dart';
import 'incident_detail_screen.dart';

class IncidentListScreen extends StatefulWidget {
  const IncidentListScreen({super.key});

  @override
  State<IncidentListScreen> createState() => _IncidentListScreenState();
}

class _IncidentListScreenState extends State<IncidentListScreen> {
  List<IncidentReport> _incidents = [];
  String _filterStatus = 'All';
  String? _filterBarangay;
  String _filterReporter = 'All';

  final List<String> _statusOptions = ['All', 'Pending', 'Under Review', 'Resolved', 'Rejected'];
  final List<String> _barangayOptions = [
    'All',
    'Banca-Banca', 'BMA – Balagtas', 'Caingin', 'Capihan', 'Coral na Bato',
    'Cruz na Daan', 'Dagat-Dagatan', 'Diliman I', 'Diliman II', 'Libis',
    'Lico', 'Maasim', 'Mabalas-Balas', 'Maguinao', 'Maronquillo', 'Paco',
    'Pansumaloc', 'Pantubig', 'Pasong Bangkal', 'Pasong Callos', 'Pasong Intsik',
    'Pinacpinacan', 'Poblacion', 'Pulo', 'Pulong Bayabas', 'Salapungan',
    'Sampaloc', 'San Agustin', 'San Roque', 'Sapang Pahalang', 'Talacsan',
    'Tambubong', 'Tukod', 'Ulingao'
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
  }

  void _loadMockIncidents() {
    _incidents = [
      IncidentReport(
        id: '1', type: 'Flooding',
        description: 'Heavy flooding near the river. Several houses submerged.',
        photoPath: null, barangay: 'Poblacion', locationDetails: 'Near the church',
        coordinates: const LatLng(15.0153, 120.9996), address: 'Poblacion, San Rafael',
        status: 'Pending', reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
        personsInvolved: 25, reporterRole: 'resident', reporterIsVerified: true,
        responderNotes: null,
      ),
      IncidentReport(
        id: '2', type: 'Road Accident',
        description: 'Two vehicles collided near the highway junction. Injuries reported.',
        photoPath: null, barangay: 'Sampaloc', locationDetails: 'Highway junction',
        coordinates: const LatLng(15.0153, 120.9996), address: 'Sampaloc, San Rafael',
        status: 'Pending', reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        personsInvolved: 3, reporterRole: 'non_resident', reporterIsVerified: false,
        responderNotes: null,
      ),
      IncidentReport(
        id: '3', type: 'Fire',
        description: 'Fire in a residential area. Firefighters are on site.',
        photoPath: null, barangay: 'Caingin', locationDetails: 'Near the market',
        coordinates: const LatLng(15.0153, 120.9996), address: 'Caingin, San Rafael',
        status: 'Under Review', reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        personsInvolved: 0, reporterRole: 'resident', reporterIsVerified: false,
        responderNotes: 'Dispatch team en route.',
      ),
    ];
    setState(() {});
  }

  List<IncidentReport> get _filteredIncidents {
    // Explicitly typed as List<IncidentReport>
    List<IncidentReport> filtered = List.from(_incidents);
    
    if (_filterStatus != 'All') {
      filtered = filtered.where((inc) => inc.status == _filterStatus).toList();
    }
    if (_filterBarangay != null && _filterBarangay != 'All') {
      filtered = filtered.where((inc) => inc.barangay == _filterBarangay).toList();
    }
    switch (_filterReporter) {
      case 'Verified Resident':
        filtered = filtered.where((inc) => inc.reporterRole == 'resident' && inc.reporterIsVerified).toList();
        break;
      case 'Unverified Resident':
        filtered = filtered.where((inc) => inc.reporterRole == 'resident' && !inc.reporterIsVerified).toList();
        break;
      case 'Non-Resident':
        filtered = filtered.where((inc) => inc.reporterRole != 'resident').toList();
        break;
      default: break;
    }
    filtered.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredIncidents;
    return Column(
      children: [
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
                      onChanged: (v) => setState(() => _filterBarangay = v == 'All' ? null : v),
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
              ? Center(child: Text('No incidents found', style: SreaText.bodyLarge(context).copyWith(color: SreaColors.textSecondary)))
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
}

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

    String dateStr = '${_monthAbbr(incident.reportedAt.month)} ${incident.reportedAt.day}, ${incident.reportedAt.year}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SreaCard(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => IncidentDetailScreen(incident: incident)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(incident.type, style: SreaText.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                ),
                SreaBadge(type: _statusToBadgeType(incident.status), label: incident.status, showDot: true),
              ],
            ),
            const SizedBox(height: 4),
            Text(incident.barangay, style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: reporterColor.withValues(alpha: 0.1), borderRadius: SreaRadius.pill),
                  child: Text(reporterLabel, style: SreaText.label(context).copyWith(color: reporterColor, fontSize: 10)),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: 12, color: SreaColors.textHint),
                const SizedBox(width: 4),
                Text(dateStr, style: SreaText.label(context).copyWith(color: SreaColors.textHint)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incident.description.length > 100 ? '${incident.description.substring(0, 100)}...' : incident.description,
              style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text('View details →', style: SreaText.label(context).copyWith(color: SreaColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  SreaBadgeType _statusToBadgeType(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return SreaBadgeType.resolved;
      case 'rejected': return SreaBadgeType.rejected;
      case 'under review': return SreaBadgeType.underReview;
      default: return SreaBadgeType.pending;
    }
  }

  String _monthAbbr(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}