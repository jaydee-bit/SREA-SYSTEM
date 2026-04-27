import 'package:latlong2/latlong.dart';

class IncidentReport {
  final String id;
  final String type;
  final String description;
  final String? photoPath;
  final String barangay;
  final String? locationDetails;
  final LatLng coordinates;
  final String address;
  final String status;
  final DateTime reportedAt;
  final int? personsInvolved;
  final String reporterRole;
  final bool reporterIsVerified;
  final String? responderNotes;
  final String? escalationReason;
  final String? escalatedBy;
  final String? escalatedAt;
  final String? resolutionNotes;
  final DateTime? resolvedAt;

  IncidentReport({
    required this.id,
    required this.type,
    required this.description,
    this.photoPath,
    required this.barangay,
    this.locationDetails,
    required this.coordinates,
    required this.address,
    required this.status,
    required this.reportedAt,
    this.personsInvolved,
    required this.reporterRole,
    required this.reporterIsVerified,
    this.responderNotes,
    this.escalationReason,
    this.escalatedBy,
    this.escalatedAt,
    this.resolutionNotes,
    this.resolvedAt,
  });

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      photoPath: json['photoPath'] as String?,
      barangay: json['barangay'] as String,
      locationDetails: json['locationDetails'] as String?,
      coordinates: LatLng(
        (json['latitude'] as num).toDouble(),
        (json['longitude'] as num).toDouble(),
      ),
      address: json['address'] as String,
      status: json['status'] as String,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      personsInvolved: json['personsInvolved'] as int?,
      reporterRole: json['reporterRole'] as String,
      reporterIsVerified: json['reporterIsVerified'] as bool,
      responderNotes: json['responderNotes'] as String?,
      escalationReason: json['escalationReason'] as String?,
      escalatedBy: json['escalatedBy'] as String?,
      escalatedAt: json['escalatedAt'] as String?,
      resolutionNotes: json['resolutionNotes'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'photoPath': photoPath,
      'barangay': barangay,
      'locationDetails': locationDetails,
      'latitude': coordinates.latitude,
      'longitude': coordinates.longitude,
      'address': address,
      'status': status,
      'reportedAt': reportedAt.toIso8601String(),
      'personsInvolved': personsInvolved,
      'reporterRole': reporterRole,
      'reporterIsVerified': reporterIsVerified,
      'responderNotes': responderNotes,
      'escalationReason': escalationReason,
      'escalatedBy': escalatedBy,
      'escalatedAt': escalatedAt,
      'resolutionNotes': resolutionNotes,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  IncidentReport copyWith({
    String? id,
    String? type,
    String? description,
    String? photoPath,
    String? barangay,
    String? locationDetails,
    LatLng? coordinates,
    String? address,
    String? status,
    DateTime? reportedAt,
    int? personsInvolved,
    String? reporterRole,
    bool? reporterIsVerified,
    String? responderNotes,
    String? escalationReason,
    String? escalatedBy,
    String? escalatedAt,
    String? resolutionNotes,
    DateTime? resolvedAt,
  }) {
    return IncidentReport(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      barangay: barangay ?? this.barangay,
      locationDetails: locationDetails ?? this.locationDetails,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      status: status ?? this.status,
      reportedAt: reportedAt ?? this.reportedAt,
      personsInvolved: personsInvolved ?? this.personsInvolved,
      reporterRole: reporterRole ?? this.reporterRole,
      reporterIsVerified: reporterIsVerified ?? this.reporterIsVerified,
      responderNotes: responderNotes ?? this.responderNotes,
      escalationReason: escalationReason ?? this.escalationReason,
      escalatedBy: escalatedBy ?? this.escalatedBy,
      escalatedAt: escalatedAt ?? this.escalatedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
