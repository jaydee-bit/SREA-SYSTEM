// File: complete_profile_screen.dart
// Path: mobile_user_app/lib/screens/complete_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srea_shared/srea_shared.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _barangay;
  final _streetController = TextEditingController();
  String? _validIdType;
  File? _idImage;

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
  final List<String> _validIdOptions = [
    'PhilSys / National ID',
    'Driver\'s License',
    'Passport',
    'Voter\'s ID',
    'Postal ID',
    'SSS ID',
    'GSIS ID',
    'Barangay ID',
  ];

  @override
  void dispose() {
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _pickIdImage() async {
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
                if (picked != null) {
                  setState(() => _idImage = File(picked.path));
                }
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
                if (picked != null) {
                  setState(() => _idImage = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_barangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your barangay'),
          backgroundColor: SreaColors.error,
        ),
      );
      return;
    }
    if (_validIdType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your valid ID type'),
          backgroundColor: SreaColors.error,
        ),
      );
      return;
    }
    if (_idImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload a photo of your valid ID'),
          backgroundColor: SreaColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: API call to save address and ID, then update user status to pending
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.modal),
        title: Text(
          'Profile Submitted',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textPrimary),
        ),
        content: Text(
          'Your address and ID have been submitted for verification. You will be notified once approved.',
          style: SreaText.bodySmall(
            context,
          ).copyWith(color: SreaColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to home
            },
            child: Text(
              'OK',
              style: SreaText.bodySmall(context).copyWith(
                color: SreaColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
          'Complete Your Profile',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'Address'),
                const SizedBox(height: 12),

                SreaTextField(
                  label: 'Province',
                  hint: 'Bulacan',
                  enabled: false,
                ),
                const SizedBox(height: 16),

                SreaTextField(
                  label: 'Municipality',
                  hint: 'San Rafael',
                  enabled: false,
                ),
                const SizedBox(height: 16),

                SreaDropdown<String>(
                  label: 'Barangay',
                  hint: 'Choose your Barangay',
                  value: _barangay,
                  items: _barangayOptions,
                  required: true,
                  onChanged: (v) => setState(() => _barangay = v),
                  validator: (v) =>
                      v == null ? 'Please select your barangay' : null,
                ),
                const SizedBox(height: 16),

                SreaTextField(
                  label: 'Street / House No.',
                  hint: 'Enter your address',
                  controller: _streetController,
                  required: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: 'Verification'),
                const SizedBox(height: 12),

                SreaDropdown<String>(
                  label: 'Valid ID',
                  hint: 'Choose your ID type',
                  value: _validIdType,
                  items: _validIdOptions,
                  required: true,
                  onChanged: (v) => setState(() => _validIdType = v),
                  validator: (v) =>
                      v == null ? 'Please select an ID type' : null,
                ),
                const SizedBox(height: 16),

                SreaImageUpload(
                  label: 'Upload ID Photo',
                  hint: 'Tap to upload your ID',
                  selectedImage: _idImage,
                  onTap: _pickIdImage,
                  onRemove: () => setState(() => _idImage = null),
                ),

                const SizedBox(height: 32),

                SreaButton(
                  label: 'Submit for Verification',
                  onPressed: _submit,
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
