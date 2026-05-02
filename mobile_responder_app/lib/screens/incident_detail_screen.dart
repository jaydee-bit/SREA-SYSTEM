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

  String? _selectedReassignReason;
  final TextEditingController _otherReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _incident = widget.incident;
    _notesController = TextEditingController(
      text: _incident.responderNotes ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _otherReasonController.dispose();
    super.dispose();
  }

  Future<void> _performUpdate(
    Map<String, dynamic> updates,
    String snackbarMessage,
    Color snackbarColor,
  ) async {
    setState(() => _isUpdating = true);

    final updatedIncident = IncidentReport(
      id: _incident.id,
      type: _incident.type,
      description: _incident.description,
      photoPath: _incident.photoPath,
      barangay: _incident.barangay,
      locationDetails: _incident.locationDetails,
      coordinates: _incident.coordinates,
      address: _incident.address,
      status: updates['status'] ?? _incident.status,
      reportedAt: _incident.reportedAt,
      personsInvolved: updates['personsInvolved'] ?? _incident.personsInvolved,
      reporterRole: _incident.reporterRole,
      reporterIsVerified: _incident.reporterIsVerified,
      responderNotes: updates['responderNotes'] ?? _notesController.text,
      escalationReason:
          updates['escalationReason'] ?? _incident.escalationReason,
      escalatedBy: updates['escalatedBy'] ?? _incident.escalatedBy,
      escalatedAt: updates['escalatedAt'] ?? _incident.escalatedAt,
      resolutionNotes: updates['resolutionNotes'] ?? _incident.resolutionNotes,
      resolvedAt: updates['resolvedAt'] != null
          ? DateTime.parse(updates['resolvedAt'])
          : _incident.resolvedAt,
    );
    setState(() => _incident = updatedIncident);
    _isUpdating = false;

    await Future.delayed(const Duration(milliseconds: 500));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          snackbarMessage,
          style: SreaText.bodySmall(context).copyWith(color: Colors.white),
        ),
        backgroundColor: snackbarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.input),
      ),
    );
  }

  Widget _buildResponsiveButtonRow({
    Key? key,
    required Widget primaryButton,
    required Widget secondaryButton,
    double spacing = 12,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        const double approxButtonWidth = 140;
        final neededWidth = approxButtonWidth * 2 + spacing;
        if (constraints.maxWidth >= neededWidth) {
          return Row(
            children: [
              Expanded(child: primaryButton),
              SizedBox(width: spacing),
              Expanded(child: secondaryButton),
            ],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              primaryButton,
              SizedBox(height: spacing),
              secondaryButton,
            ],
          );
        }
      },
    );
  }

  void _showRespondBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: SreaRadius.bottomSheet),
      builder: (context) => Padding(
        padding: SreaSpacing.bottomSheetPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DragHandle(),
            const SizedBox(height: 8),
            Text(
              'Respond to Incident',
              style: SreaText.titleLarge(
                context,
              ).copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'You are about to take responsibility for this incident.',
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SreaButton(
                  label: 'Confirm Respond',
                  onPressed: () async {
                    Navigator.pop(context);
                    await _performUpdate(
                      {'status': 'Under Review'}, // ✅ consistent status
                      'You are now assigned to this incident',
                      SreaColors.primary,
                    );
                  },
                  type: SreaButtonType.primary,
                ),
                const SizedBox(height: 12),
                SreaButton.outline(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _isReassignReasonValid =>
      _selectedReassignReason != null &&
      (_selectedReassignReason != 'Other' ||
          _otherReasonController.text.trim().isNotEmpty);

  void _showReassignBottomSheet() {
    _selectedReassignReason = null;
    _otherReasonController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: SreaRadius.bottomSheet),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: SreaSpacing.bottomSheetPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DragHandle(),
                const SizedBox(height: 8),
                Text(
                  'Reassign Incident',
                  style: SreaText.titleLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a reason for reassigning this incident to the admin.',
                  style: SreaText.bodySmall(
                    context,
                  ).copyWith(color: SreaColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SreaRadioGroup<String>(
                  groupValue: _selectedReassignReason,
                  onChanged: (value) =>
                      setSheetState(() => _selectedReassignReason = value),
                  options: const [
                    SreaRadioItem(
                      value: 'Hands full — please assign to another responder',
                      label: 'Hands full — please assign to another responder',
                    ),
                    SreaRadioItem(
                      value: 'Outside my jurisdiction or barangay',
                      label: 'Outside my jurisdiction or barangay',
                    ),
                    SreaRadioItem(
                      value: 'Requires additional resources or authority',
                      label: 'Requires additional resources or authority',
                    ),
                    SreaRadioItem(
                      value: 'Duplicate or related to another active incident',
                      label: 'Duplicate or related to another active incident',
                    ),
                    SreaRadioItem(value: 'Other', label: 'Other'),
                  ],
                ),
                if (_selectedReassignReason == 'Other') ...[
                  const SizedBox(height: 12),
                  SreaTextField(
                    label: 'Please specify',
                    hint: 'Enter reason...',
                    controller: _otherReasonController,
                    onChanged: (_) => setSheetState(() {}),
                  ),
                ],
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: _isReassignReasonValid && !_isUpdating
                          ? () async {
                              Navigator.pop(context);
                              final reason = _selectedReassignReason == 'Other'
                                  ? _otherReasonController.text.trim()
                                  : _selectedReassignReason!;
                              await _performUpdate(
                                {
                                  'status': 'Escalated', // ✅ consistent
                                  'escalationReason': reason,
                                  'escalatedBy': 'Current Responder',
                                  'escalatedAt': DateTime.now()
                                      .toIso8601String(),
                                },
                                'Incident has been reassigned to admin',
                                SreaColors.high,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SreaColors.high,
                        foregroundColor: SreaColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: SreaRadius.button,
                        ),
                        padding: SreaSpacing.buttonPadding(context),
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(
                        'Confirm Reassign',
                        style: SreaText.label(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SreaButton.outline(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showResolveBottomSheet() {
    final actualPersonsController = TextEditingController();
    final actionsController = TextEditingController();
    bool canResolve = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: SreaRadius.bottomSheet),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: SreaSpacing.bottomSheetPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DragHandle(),
                const SizedBox(height: 8),
                Text(
                  'Mark as Resolved',
                  style: SreaText.titleLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Provide verified data and actions taken.',
                  style: SreaText.bodySmall(
                    context,
                  ).copyWith(color: SreaColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Read‑only reported persons
                SreaTextField(
                  label: 'Reported persons involved (from resident)',
                  hint: 'Reported number',
                  controller: TextEditingController(
                    text:
                        _incident.personsInvolved?.toString() ??
                        'Not specified',
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 12),

                // Required: actual verified count
                SreaTextField(
                  label: 'Actual persons involved (verified by you) *',
                  hint: 'Enter verified count',
                  controller: actualPersonsController,
                  keyboardType: TextInputType.number,
                  required: true,
                  onChanged: (_) => setSheetState(() {
                    canResolve = actualPersonsController.text.trim().isNotEmpty;
                  }),
                ),
                const SizedBox(height: 12),

                // Optional: actions taken / resolution notes
                SreaTextField(
                  label: 'Actions taken / Resolution notes (optional)',
                  hint: 'Describe what was done',
                  controller: actionsController,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SreaButton.update(
                      label: 'Confirm Resolve',
                      onPressed: canResolve && !_isUpdating
                          ? () async {
                              Navigator.pop(context);
                              final actualPersons = int.tryParse(
                                actualPersonsController.text.trim(),
                              );
                              final actions = actionsController.text.trim();
                              await _performUpdate(
                                {
                                  'status': 'Resolved', // ✅ consistent
                                  'personsInvolved': actualPersons,
                                  'resolutionNotes': actions.isNotEmpty
                                      ? actions
                                      : null,
                                  'resolvedAt': DateTime.now()
                                      .toIso8601String(),
                                },
                                'Incident marked as resolved',
                                SreaColors.buttonUpdate,
                              );
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    SreaButton.outline(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddEditNotesBottomSheet() {
    final notesController = TextEditingController(text: _notesController.text);
    bool canSave = notesController.text.trim().isNotEmpty;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: SreaRadius.bottomSheet),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: SreaSpacing.bottomSheetPadding(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _DragHandle(),
                const SizedBox(height: 8),
                Text(
                  _notesController.text.isEmpty ? 'Add Notes' : 'Edit Notes',
                  style: SreaText.titleLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add internal notes about this incident. These notes are only visible to responders and admins.',
                  style: SreaText.bodySmall(
                    context,
                  ).copyWith(color: SreaColors.textSecondary),
                ),
                const SizedBox(height: 20),
                SreaTextField(
                  label: 'Responder Notes',
                  hint: 'Enter notes...',
                  controller: notesController,
                  maxLines: 4,
                  required: true,
                  onChanged: (_) => setSheetState(
                    () => canSave = notesController.text.trim().isNotEmpty,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SreaButton(
                      label: 'Save Notes',
                      onPressed: canSave && !_isUpdating
                          ? () async {
                              Navigator.pop(context);
                              await _performUpdate(
                                {'responderNotes': notesController.text.trim()},
                                'Notes saved successfully',
                                SreaColors.primary,
                              );
                              _notesController.text = notesController.text
                                  .trim();
                            }
                          : null,
                      type: SreaButtonType.primary,
                      icon: Icons.note_add_rounded,
                    ),
                    const SizedBox(height: 12),
                    SreaButton.outline(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Normalise status for safety (but we now use exact strings)
    final String status = _incident.status;
    switch (status) {
      case 'Pending':
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildResponsiveButtonRow(
            key: const ValueKey('pending'),
            primaryButton: SreaButton(
              label: 'Respond',
              onPressed: _isUpdating ? null : _showRespondBottomSheet,
              type: SreaButtonType.primary,
              icon: Icons.assignment_turned_in_rounded,
            ),
            secondaryButton: ElevatedButton(
              onPressed: _isUpdating ? null : _showReassignBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: SreaColors.high,
                foregroundColor: SreaColors.textOnPrimary,
                shape: RoundedRectangleBorder(borderRadius: SreaRadius.button),
                padding: SreaSpacing.buttonPadding(context),
                minimumSize: const Size(0, 48),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.swap_horiz_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reassign',
                    style: SreaText.label(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        );
      case 'Under Review':
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Column(
            key: const ValueKey('under_review'),
            children: [
              _buildResponsiveButtonRow(
                primaryButton: SreaButton.update(
                  label: 'Resolve',
                  onPressed: _isUpdating ? null : _showResolveBottomSheet,
                  icon: Icons.check_circle_outline_rounded,
                ),
                secondaryButton: ElevatedButton(
                  onPressed: _isUpdating ? null : _showReassignBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SreaColors.high,
                    foregroundColor: SreaColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: SreaRadius.button,
                    ),
                    padding: SreaSpacing.buttonPadding(context),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.swap_horiz_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Reassign',
                        style: SreaText.label(
                          context,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SreaButton.outline(
                label: 'Add Notes',
                onPressed: _isUpdating ? null : _showAddEditNotesBottomSheet,
                fullWidth: true,
                icon: Icons.note_add_rounded,
              ),
            ],
          ),
        );
      case 'Escalated':
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: const ValueKey('escalated'),
            padding: SreaSpacing.cardPaddingSmall(context),
            decoration: BoxDecoration(
              color: SreaColors.highBg,
              borderRadius: SreaRadius.card,
              border: Border.all(color: SreaColors.high.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: SreaColors.high,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Reassigned',
                        style: SreaText.bodySmall(context).copyWith(
                          color: SreaColors.high,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'This incident has been reassigned to admin. Waiting for a new responder to be assigned.',
                        style: SreaText.label(
                          context,
                        ).copyWith(color: SreaColors.high),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 'Resolved':
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Container(
            key: const ValueKey('resolved'),
            padding: SreaSpacing.cardPaddingSmall(context),
            decoration: BoxDecoration(
              color: SreaColors.lowBg,
              borderRadius: SreaRadius.card,
              border: Border.all(color: SreaColors.low.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: SreaColors.low,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Incident Resolved',
                        style: SreaText.bodySmall(context).copyWith(
                          color: SreaColors.low,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'This incident has been marked as resolved. No further action is required.',
                        style: SreaText.label(
                          context,
                        ).copyWith(color: SreaColors.low),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolvedOrEscalated =
        _incident.status == 'Resolved' || _incident.status == 'Escalated';
    final hasNotes = _notesController.text.trim().isNotEmpty;

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
        actions: [
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _incident.type,
                      style: SreaText.headlineSmall(
                        context,
                      ).copyWith(fontWeight: FontWeight.w800),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (_incident.reporterRole == 'resident' &&
                          _incident.reporterIsVerified)
                      ? SreaColors.lowBg
                      : SreaColors.mediumBg,
                  borderRadius: SreaRadius.pill,
                ),
                child: Text(
                  _incident.reporterRole == 'resident'
                      ? (_incident.reporterIsVerified
                            ? 'Verified Resident'
                            : 'Unverified Resident')
                      : 'Non-Resident',
                  style: SreaText.label(context).copyWith(
                    color:
                        (_incident.reporterRole == 'resident' &&
                            _incident.reporterIsVerified)
                        ? SreaColors.low
                        : SreaColors.medium,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                        '${_incident.barangay}${_incident.locationDetails != null ? ' • ${_incident.locationDetails}' : ''}',
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
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: SreaColors.textHint,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(_incident.reportedAt),
                    style: SreaText.bodySmall(
                      context,
                    ).copyWith(color: SreaColors.textHint),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Description',
                style: SreaText.bodyLarge(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _incident.description,
                style: SreaText.bodySmall(
                  context,
                ).copyWith(color: SreaColors.textSecondary, height: 1.6),
              ),
              if (_incident.personsInvolved != null) ...[
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
                      'Persons involved: ${_incident.personsInvolved}',
                      style: SreaText.bodySmall(
                        context,
                      ).copyWith(color: SreaColors.textSecondary),
                    ),
                  ],
                ),
              ],
              if (_incident.photoPath != null) ...[
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
                    File(_incident.photoPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ],
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
                    initialCenter: _incident.coordinates,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.responder_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 40,
                          height: 40,
                          point: _incident.coordinates,
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
                _incident.address,
                style: SreaText.label(
                  context,
                ).copyWith(color: SreaColors.textHint),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildActionButtons(context),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Responder Notes',
                    style: SreaText.bodyLarge(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (!isResolvedOrEscalated)
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: SreaColors.primary,
                      ),
                      onPressed: _showAddEditNotesBottomSheet,
                      tooltip: 'Edit notes (visible to admins)',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: SreaSpacing.cardPaddingSmall(context),
                decoration: BoxDecoration(
                  color: SreaColors.surfaceVariant,
                  borderRadius: SreaRadius.card,
                  border: Border.all(color: SreaColors.border),
                ),
                child: hasNotes
                    ? Text(
                        _notesController.text,
                        style: SreaText.bodySmall(
                          context,
                        ).copyWith(color: SreaColors.textPrimary),
                      )
                    : Text(
                        'No notes added yet.',
                        style: SreaText.bodySmall(context).copyWith(
                          color: SreaColors.textHint,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),

              if (_incident.resolutionNotes != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Resolution Notes (Actions taken)',
                  style: SreaText.bodyLarge(
                    context,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: SreaSpacing.cardPaddingSmall(context),
                  decoration: BoxDecoration(
                    color: SreaColors.lowBg,
                    borderRadius: SreaRadius.card,
                    border: Border.all(color: SreaColors.low.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _incident.resolutionNotes!,
                        style: SreaText.bodySmall(
                          context,
                        ).copyWith(color: SreaColors.textPrimary),
                      ),
                      if (_incident.resolvedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Resolved on: ${_formatDate(_incident.resolvedAt!)}',
                          style: SreaText.label(
                            context,
                          ).copyWith(color: SreaColors.textHint),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

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
                            'For assistance, contact MDRRMO',
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
    switch (status) {
      case 'Resolved':
        return SreaBadgeType.resolved;
      case 'Rejected':
        return SreaBadgeType.rejected;
      case 'Under Review':
        return SreaBadgeType.underReview;
      case 'Escalated':
        return SreaBadgeType.high;
      default:
        return SreaBadgeType.pending;
    }
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: SreaColors.border,
        borderRadius: SreaRadius.pill,
      ),
    );
  }
}
