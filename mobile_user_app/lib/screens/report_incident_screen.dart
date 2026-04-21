import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srea_shared/srea_shared.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/incident_report_model.dart';
import 'incident_report_detail_screen.dart';

class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({super.key});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingLocation = false;

  String? _incidentType;
  final _descriptionController = TextEditingController();
  final _personsController = TextEditingController();
  String? _barangay;
  final _locationDetailsController = TextEditingController();
  File? _photo;

  LatLng? _selectedLatLng;
  String _selectedAddress = '';
  final MapController _mapController = MapController();
  double _currentZoom = 15.0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // TODO: Replace with actual user data from auth service
  final String _reporterRole = 'resident'; // or 'non_resident'
  final bool _reporterIsVerified = false; // from profile

  final List<String> _incidentTypes = [
    'Flooding',
    'Fire',
    'Road Accident',
    'Landslide',
    'Storm Damage',
    'Medical Emergency',
    'Other',
  ];
  final List<String> _barangayOptions = [
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

  final List<String> _typesRequiringPersons = [
    'Road Accident',
    'Fire',
    'Medical Emergency',
    'Flooding',
  ];

  bool get _showPersonsField =>
      _incidentType != null && _typesRequiringPersons.contains(_incidentType);

  @override
  void dispose() {
    _descriptionController.dispose();
    _personsController.dispose();
    _locationDetailsController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  String? _findMatchingBarangay(String detected) {
    if (detected.isEmpty) return null;
    final cleaned = detected.trim().toLowerCase().replaceAll(
      RegExp(r'^(barangay|brgy\.?)\s+'),
      '',
    );
    for (final option in _barangayOptions) {
      if (option.toLowerCase() == cleaned) return option;
    }
    for (final option in _barangayOptions) {
      if (cleaned.contains(option.toLowerCase()) ||
          option.toLowerCase().contains(cleaned))
        return option;
    }
    return null;
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            '${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.postalCode ?? ''}'
                .trim();
        if (address.isEmpty) address = 'Unknown location';
        setState(() => _selectedAddress = address);
        String detectedBarangay = place.subLocality ?? place.locality ?? '';
        final matched = _findMatchingBarangay(detectedBarangay);
        if (matched != null) setState(() => _barangay = matched);
        if (place.street != null && place.street!.isNotEmpty) {
          setState(() => _locationDetailsController.text = place.street!);
        }
      } else {
        setState(
          () => _selectedAddress =
              'Coordinates: ${latLng.latitude}, ${latLng.longitude}',
        );
      }
    } catch (e) {
      setState(
        () => _selectedAddress =
            'Coordinates: ${latLng.latitude}, ${latLng.longitude}',
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      setState(() => _isFetchingLocation = false);
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied.');
        setState(() => _isFetchingLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showError(
        'Location permissions permanently denied. Please enable from settings.',
      );
      setState(() => _isFetchingLocation = false);
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLatLng = latLng);
      await _updateAddressFromLatLng(latLng);
    } catch (e) {
      _showError('Failed to get location: $e');
    } finally {
      setState(() => _isFetchingLocation = false);
    }
  }

  void _onMapTap(LatLng latLng) async {
    setState(() => _selectedLatLng = latLng);
    await _updateAddressFromLatLng(latLng);
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isSearching = true);
    try {
      List<Location> locations = await locationFromAddress(
        _searchController.text,
      );
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        final latLng = LatLng(loc.latitude, loc.longitude);
        setState(() => _selectedLatLng = latLng);
        await _updateAddressFromLatLng(latLng);
      } else {
        _showError('Location not found.');
      }
    } catch (e) {
      _showError('Search failed: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: SreaColors.error),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: SreaRadius.bottomSheet),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: SreaColors.primary,
              ),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (picked != null) setState(() => _photo = File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: SreaColors.primary),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1024,
                  maxHeight: 1024,
                  imageQuality: 85,
                );
                if (picked != null) setState(() => _photo = File(picked.path));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_incidentType == null) {
      _showError('Please select an incident type');
      return;
    }
    if (_barangay == null) {
      _showError('Please select your barangay');
      return;
    }
    if (_selectedLatLng == null) {
      _showError('Please share your location');
      return;
    }
    int? persons;
    if (_showPersonsField && _personsController.text.isNotEmpty) {
      persons = int.tryParse(_personsController.text);
      if (persons == null || persons <= 0) {
        _showError('Please enter a valid number of persons involved');
        return;
      }
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (!mounted) return;

    final newReport = IncidentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _incidentType!,
      description: _descriptionController.text,
      photoPath: _photo?.path,
      barangay: _barangay!,
      locationDetails: _locationDetailsController.text,
      coordinates: _selectedLatLng!,
      address: _selectedAddress,
      status: 'Pending',
      reportedAt: DateTime.now(),
      personsInvolved: persons,
      reporterRole: _reporterRole,
      reporterIsVerified: _reporterIsVerified,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => IncidentReportDetailScreen(report: newReport),
      ),
    );
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
          'Report Incident',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Warning for unverified users
                if (!_reporterIsVerified)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SreaColors.mediumBg,
                      borderRadius: SreaRadius.card,
                      border: Border.all(
                        color: SreaColors.medium.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: SreaColors.medium,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your account is not verified. Reports from unverified users will be reviewed by admin and may have lower priority.',
                            style: SreaText.bodySmall(
                              context,
                            ).copyWith(color: SreaColors.medium),
                          ),
                        ),
                      ],
                    ),
                  ),
                _SectionHeader(title: 'Location'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a place...',
                          hintStyle: SreaText.bodySmall(
                            context,
                          ).copyWith(color: SreaColors.textHint),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: SreaColors.textHint,
                          ),
                          filled: true,
                          fillColor: SreaColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                              color: SreaColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                              color: SreaColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                              color: SreaColors.borderFocused,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchLocation(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _isSearching ? null : _searchLocation,
                      icon: _isSearching
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.arrow_forward_rounded,
                              color: SreaColors.primary,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: SreaColors.surface,
                    borderRadius: SreaRadius.card,
                    border: Border.all(color: SreaColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedAddress.isEmpty
                                  ? 'No location selected'
                                  : _selectedAddress,
                              style: SreaText.bodySmall(context).copyWith(
                                color: _selectedAddress.isEmpty
                                    ? SreaColors.textHint
                                    : SreaColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isFetchingLocation
                                ? null
                                : _getCurrentLocation,
                            icon: _isFetchingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.my_location, size: 18),
                            label: Text(
                              _isFetchingLocation
                                  ? 'Getting...'
                                  : 'Use my location',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SreaColors.primary,
                              foregroundColor: SreaColors.textOnPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: SreaRadius.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedLatLng != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 220,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedLatLng!,
                              initialZoom: _currentZoom,
                              onTap: (tapPos, latLng) => _onMapTap(latLng),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.mobile_user_app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 40,
                                    height: 40,
                                    point: _selectedLatLng!,
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
                          'Tap on map to adjust location',
                          style: SreaText.label(
                            context,
                          ).copyWith(color: SreaColors.textHint),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Incident Details'),
                const SizedBox(height: 12),
                SreaDropdown<String>(
                  label: 'Incident Type',
                  hint: 'Select type',
                  value: _incidentType,
                  items: _incidentTypes,
                  required: true,
                  onChanged: (v) => setState(() => _incidentType = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                SreaTextField(
                  label: 'Description',
                  hint: 'Describe what happened...',
                  controller: _descriptionController,
                  maxLines: 5,
                  required: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                if (_showPersonsField) ...[
                  const SizedBox(height: 16),
                  SreaTextField(
                    label: 'Number of persons involved (optional)',
                    hint: 'e.g., 5',
                    controller: _personsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
                const SizedBox(height: 16),
                _SectionHeader(title: 'Location Details'),
                const SizedBox(height: 12),
                SreaDropdown<String>(
                  label: 'Barangay',
                  hint: 'Select your barangay',
                  value: _barangay,
                  items: _barangayOptions,
                  required: true,
                  onChanged: (v) => setState(() => _barangay = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                SreaTextField(
                  label: 'Street / Landmark (optional)',
                  hint: 'e.g., Near the church, Barangay Hall',
                  controller: _locationDetailsController,
                ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Photo (Optional)'),
                const SizedBox(height: 12),
                SreaImageUpload(
                  selectedImage: _photo,
                  onTap: _pickPhoto,
                  onRemove: () => setState(() => _photo = null),
                  hint: 'Tap to add photo',
                ),
                const SizedBox(height: 32),
                SreaButton(
                  label: 'Submit Report',
                  onPressed: _submitReport,
                  fullWidth: true,
                  isLoading: _isLoading,
                  size: SreaButtonSize.large,
                  icon: Icons.send_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: SreaColors.primary,
            borderRadius: SreaRadius.pill,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: SreaText.titleLarge(
            context,
          ).copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
