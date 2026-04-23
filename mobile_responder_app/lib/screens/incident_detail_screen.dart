import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import '../models/incident_report_model.dart';

class IncidentDetailScreen extends StatefulWidget {
  final IncidentReport incident;
  const IncidentDetailScreen({super.key, required this.incident});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  late IncidentReport _incident;
  late TextEditingController _notesController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
    _notesController = TextEditingController(text: _incident.responderNotes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    // TODO: API call to update status
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _incident = IncidentReport(
        id: _incident.id,
        type: _incident.type,
        description: _incident.description,
        photoPath: _incident.photoPath,
        barangay: _incident.barangay,
        locationDetails: _incident.locationDetails,
        coordinates: _incident.coordinates,
        address: _incident.address,
        status: newStatus,
        reportedAt: _incident.reportedAt,
        personsInvolved: _incident.personsInvolved,
        reporterRole: _incident.reporterRole,
        reporterIsVerified: _incident.reporterIsVerified,
        responderNotes: _notesController.text,
      );
      _isUpdating = false;
    });

    Color snackbarColor;
    switch (newStatus.toLowerCase()) {
      case 'resolved':
        snackbarColor = SreaColors.buttonUpdate;
        break;
      case 'rejected':
        snackbarColor = SreaColors.buttonReport;
        break;
      case 'under review':
        snackbarColor = SreaColors.tagUnderReview;
        break;
      default:
        snackbarColor = SreaColors.buttonUpdate;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to $newStatus', style: SreaText.bodySmall(context).copyWith(color: Colors.white)),
        backgroundColor: snackbarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.input),
      ),
    );
  }

  void _confirmAndUpdate(String newStatus, {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.modal),
        title: Text(title, style: SreaText.titleLarge(context).copyWith(color: SreaColors.textPrimary)),
        content: Text(message, style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(newStatus);
            },
            child: Text(
              'Confirm',
              style: SreaText.bodySmall(context).copyWith(
                color: newStatus == 'Resolved' ? SreaColors.buttonUpdate : SreaColors.buttonReport,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNotes() async {
    setState(() => _isUpdating = true);
    // TODO: API call to save notes
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _incident = IncidentReport(
        id: _incident.id,
        type: _incident.type,
        description: _incident.description,
        photoPath: _incident.photoPath,
        barangay: _incident.barangay,
        locationDetails: _incident.locationDetails,
        coordinates: _incident.coordinates,
        address: _incident.address,
        status: _incident.status,
        reportedAt: _incident.reportedAt,
        personsInvolved: _incident.personsInvolved,
        reporterRole: _incident.reporterRole,
        reporterIsVerified: _incident.reporterIsVerified,
        responderNotes: _notesController.text,
      );
      _isUpdating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notes saved', style: SreaText.bodySmall(context).copyWith(color: Colors.white)),
        backgroundColor: SreaColors.buttonUpdate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.input),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = _incident.status == 'Resolved' || _incident.status == 'Rejected';

    return Scaffold(
      backgroundColor: SreaColors.background,
      appBar: AppBar(
        backgroundColor: SreaColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SreaColors.textOnPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Incident Details', style: SreaText.titleLarge(context).copyWith(color: SreaColors.textOnPrimary)),
        actions: [
          if (_isUpdating)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Incident type + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _incident.type,
                      style: SreaText.headlineSmall(context).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  SreaBadge(
                    type: _statusToBadgeType(_incident.status),
                    label: _incident.status,
                    showDot: true,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Reporter badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: (_incident.reporterRole == 'resident' && _incident.reporterIsVerified)
                      ? SreaColors.lowBg
                      : SreaColors.mediumBg,
                  borderRadius: SreaRadius.pill,
                ),
                child: Text(
                  _incident.reporterRole == 'resident'
                      ? (_incident.reporterIsVerified ? 'Verified Resident' : 'Unverified Resident')
                      : 'Non-Resident',
                  style: SreaText.label(context).copyWith(
                    color: (_incident.reporterRole == 'resident' && _incident.reporterIsVerified)
                        ? SreaColors.low
                        : SreaColors.medium,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location summary
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: SreaColors.primaryLight, borderRadius: SreaRadius.input),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: SreaColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_incident.barangay}${_incident.locationDetails != null ? ' • ${_incident.locationDetails}' : ''}',
                        style: SreaText.bodySmall(context).copyWith(color: SreaColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: SreaColors.textHint),
                  const SizedBox(width: 6),
                  Text(_formatDate(_incident.reportedAt), style: SreaText.bodySmall(context).copyWith(color: SreaColors.textHint)),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text('Description', style: SreaText.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(_incident.description, style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary, height: 1.6)),

              if (_incident.personsInvolved != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 14, color: SreaColors.textHint),
                    const SizedBox(width: 6),
                    Text('Persons involved: ${_incident.personsInvolved}', style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary)),
                  ],
                ),
              ],

              if (_incident.photoPath != null) ...[
                const SizedBox(height: 20),
                Text('Photo', style: SreaText.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SreaRadius.md),
                  child: Image.file(File(_incident.photoPath!), height: 200, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100)),
                ),
              ],

              // Map
              const SizedBox(height: 20),
              Text('Location on Map', style: SreaText.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(SreaRadius.md), border: Border.all(color: SreaColors.border)),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _incident.coordinates,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.responder_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: _incident.coordinates,
                          child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(_incident.address, style: SreaText.label(context).copyWith(color: SreaColors.textHint), textAlign: TextAlign.center),

              // Status update section (only if not resolved/rejected)
              if (!isResolved) ...[
                const SizedBox(height: 20),
                Text('Update Status', style: SreaText.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // Under Review button – orange, no confirmation
                ElevatedButton(
                  onPressed: _incident.status != 'Under Review' ? () => _updateStatus('Under Review') : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SreaColors.tagUnderReview,
                    foregroundColor: SreaColors.textOnPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: SreaRadius.button),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('Under Review', style: SreaText.label(context).copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Resolve (green) with confirmation
                ElevatedButton(
                  onPressed: () {
                    _confirmAndUpdate(
                      'Resolved',
                      title: 'Resolve Incident',
                      message: 'Are you sure you want to mark this incident as resolved? This action will notify the reporter.',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SreaColors.buttonUpdate,
                    foregroundColor: SreaColors.textOnPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: SreaRadius.button),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('Resolve', style: SreaText.label(context).copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Reject (red) with confirmation
                ElevatedButton(
                  onPressed: () {
                    _confirmAndUpdate(
                      'Rejected',
                      title: 'Reject Incident',
                      message: 'Are you sure you want to reject this incident report? This action will notify the reporter and close the report.',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SreaColors.buttonReport,
                    foregroundColor: SreaColors.textOnPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: SreaRadius.button),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel_outlined, size: 20),
                      const SizedBox(width: 8),
                      Text('Reject', style: SreaText.label(context).copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Text('Responder Notes', style: SreaText.bodyLarge(context).copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add internal notes...',
                  border: OutlineInputBorder(borderRadius: SreaRadius.input),
                  filled: true,
                  fillColor: SreaColors.surface,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _saveNotes,
                  child: Text('Save Notes', style: SreaText.label(context).copyWith(color: SreaColors.primary)),
                ),
              ),

              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: SreaColors.primaryLight, borderRadius: SreaRadius.input),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, size: 20, color: SreaColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('For assistance, contact MDRRMO', style: SreaText.bodySmall(context).copyWith(fontWeight: FontWeight.w700, color: SreaColors.primary)),
                          Text('(044) 123-4567', style: SreaText.label(context).copyWith(color: SreaColors.primary)),
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

  String _formatDate(DateTime date) => '${_monthAbbr(date.month)} ${date.day}, ${date.year}';
  String _monthAbbr(int m) => const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];

  SreaBadgeType _statusToBadgeType(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return SreaBadgeType.resolved;
      case 'rejected': return SreaBadgeType.rejected;
      case 'under review': return SreaBadgeType.underReview;
      default: return SreaBadgeType.pending;
    }
  }
}