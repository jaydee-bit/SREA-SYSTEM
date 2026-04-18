// File: profile_screen.dart
// Path: mobile_user_app/lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srea_shared/srea_shared.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'auth/login_screen.dart'; // ← added import for LoginScreen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data – replace with API
  final Map<String, dynamic> _user = {
    'firstName': 'Leon',
    'middleName': 'Scott',
    'lastName': 'Kennedy',
    'email': 'leon.kennedy@example.com',
    'phone': '09123456789',
    'gender': 'Male',
    'birthDate': '1990-05-15',
    'barangay': 'Poblacion',
    'street': 'Rizal St. #123',
    'isVerified': true,
    'role': 'resident', // or 'non_resident'
    'validIdType': 'Driver\'s License',
    'validIdPhoto': null,
  };

  // Editable copies
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _birthDateController;

  String? _selectedGender;
  String? _selectedBarangay;
  String? _selectedValidIdType;
  File? _idImage;

  bool _isEditing = false;
  bool _isLoading = false;
  bool _showChangePassword = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];
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
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _firstNameController = TextEditingController(text: _user['firstName']);
    _middleNameController = TextEditingController(
      text: _user['middleName'] ?? '',
    );
    _lastNameController = TextEditingController(text: _user['lastName']);
    _emailController = TextEditingController(text: _user['email']);
    _phoneController = TextEditingController(text: _user['phone']);
    _streetController = TextEditingController(text: _user['street']);
    _birthDateController = TextEditingController(text: _user['birthDate']);
    _selectedGender = _user['gender'];
    _selectedBarangay = _user['barangay'];
    _selectedValidIdType = _user['validIdType'];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: SreaColors.primary,
            onPrimary: SreaColors.textOnPrimary,
            surface: SreaColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _birthDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _pickIdImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _idImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    // TODO: API call to update profile
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully',
          style: SreaText.bodySmall(context).copyWith(color: Colors.white),
        ),
        backgroundColor: SreaColors.buttonUpdate,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.input),
      ),
    );
  }

  // FIXED: Logout now works correctly
  Future<void> _logout() async {
    // TODO: Clear stored tokens, SharedPreferences, etc.
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isResident = _user['role'] == 'resident';

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
          'My Profile',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textOnPrimary),
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: Text(
                'Edit',
                style: SreaText.label(
                  context,
                ).copyWith(color: SreaColors.textOnPrimary),
              ),
            )
          else
            TextButton(
              onPressed: _saveChanges,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Save',
                      style: SreaText.label(
                        context,
                      ).copyWith(color: SreaColors.textOnPrimary),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: SreaSpacing.screenScrollPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: SreaColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: SreaColors.primary, width: 2),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: SreaColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_user['isVerified'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SreaColors.lowBg,
                          borderRadius: SreaRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: SreaColors.low,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Account',
                              style: SreaText.label(
                                context,
                              ).copyWith(color: SreaColors.low),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: SreaColors.criticalBg,
                          borderRadius: SreaRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pending_outlined,
                              size: 14,
                              color: SreaColors.critical,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pending Verification',
                              style: SreaText.label(
                                context,
                              ).copyWith(color: SreaColors.critical),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Information section
              _SectionHeader(title: 'Personal Information'),
              const SizedBox(height: 12),

              SreaCard(
                child: Column(
                  children: [
                    _ProfileField(
                      label: 'First Name',
                      value: _firstNameController.text,
                      isEditing: _isEditing,
                      onEdit: (v) => _firstNameController.text = v,
                      child: SreaTextField(
                        hint: 'First Name',
                        controller: _firstNameController,
                        required: true,
                      ),
                    ),
                    const Divider(height: 1, color: SreaColors.divider),
                    _ProfileField(
                      label: 'Middle Name',
                      value: _middleNameController.text,
                      isEditing: _isEditing,
                      onEdit: (v) => _middleNameController.text = v,
                      child: SreaTextField(
                        hint: 'Middle Name',
                        controller: _middleNameController,
                      ),
                    ),
                    const Divider(height: 1, color: SreaColors.divider),
                    _ProfileField(
                      label: 'Last Name',
                      value: _lastNameController.text,
                      isEditing: _isEditing,
                      onEdit: (v) => _lastNameController.text = v,
                      child: SreaTextField(
                        hint: 'Last Name',
                        controller: _lastNameController,
                        required: true,
                      ),
                    ),
                    const Divider(height: 1, color: SreaColors.divider),
                    _ProfileField(
                      label: 'Gender',
                      value: _selectedGender ?? '',
                      isEditing: _isEditing,
                      onEdit: (v) => setState(() => _selectedGender = v),
                      child: SreaDropdown<String>(
                        hint: 'Select Gender',
                        value: _selectedGender,
                        items: _genderOptions,
                        onChanged: (v) => setState(() => _selectedGender = v),
                      ),
                    ),
                    const Divider(height: 1, color: SreaColors.divider),
                    _ProfileField(
                      label: 'Birth Date',
                      value: _birthDateController.text,
                      isEditing: _isEditing,
                      onEdit: (_) => _pickBirthDate(),
                      child: TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        style: SreaText.bodySmall(
                          context,
                        ).copyWith(color: SreaColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contact Information section
              _SectionHeader(title: 'Contact Information'),
              const SizedBox(height: 12),

              SreaCard(
                child: Column(
                  children: [
                    _ProfileField(
                      label: 'Email',
                      value: _emailController.text,
                      isEditing: _isEditing,
                      onEdit: (v) => _emailController.text = v,
                      child: SreaTextField(
                        hint: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),
                    ),
                    const Divider(height: 1, color: SreaColors.divider),
                    _ProfileField(
                      label: 'Phone',
                      value: _phoneController.text,
                      isEditing: _isEditing,
                      onEdit: (v) => _phoneController.text = v,
                      child: SreaTextField(
                        hint: '09XXXXXXXXX',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        required: true,
                      ),
                    ),
                  ],
                ),
              ),

              if (isResident) ...[
                const SizedBox(height: 20),
                _SectionHeader(title: 'Address'),
                const SizedBox(height: 12),
                SreaCard(
                  child: Column(
                    children: [
                      _ReadOnlyField(label: 'Province', value: 'Bulacan'),
                      const Divider(height: 1, color: SreaColors.divider),
                      _ReadOnlyField(
                        label: 'Municipality',
                        value: 'San Rafael',
                      ),
                      const Divider(height: 1, color: SreaColors.divider),
                      if (_user['isVerified']) ...[
                        _ReadOnlyField(
                          label: 'Barangay',
                          value: _selectedBarangay ?? '',
                        ),
                        const Divider(height: 1, color: SreaColors.divider),
                        _ReadOnlyField(
                          label: 'Street / House No.',
                          value: _streetController.text,
                        ),
                      ] else ...[
                        _ProfileField(
                          label: 'Barangay',
                          value: _selectedBarangay ?? '',
                          isEditing: _isEditing,
                          onEdit: (v) => setState(() => _selectedBarangay = v),
                          child: SreaDropdown<String>(
                            hint: 'Select Barangay',
                            value: _selectedBarangay,
                            items: _barangayOptions,
                            onChanged: (v) =>
                                setState(() => _selectedBarangay = v),
                            required: true,
                          ),
                        ),
                        const Divider(height: 1, color: SreaColors.divider),
                        _ProfileField(
                          label: 'Street / House No.',
                          value: _streetController.text,
                          isEditing: _isEditing,
                          onEdit: (v) => _streetController.text = v,
                          child: SreaTextField(
                            hint: 'Street address',
                            controller: _streetController,
                            required: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                _SectionHeader(title: 'Verification'),
                const SizedBox(height: 12),
                SreaCard(
                  child: Column(
                    children: [
                      if (_user['isVerified']) ...[
                        _ReadOnlyField(
                          label: 'Valid ID Type',
                          value: _selectedValidIdType ?? '',
                        ),
                        const Divider(height: 1, color: SreaColors.divider),
                        _ReadOnlyField(
                          label: 'ID Photo',
                          value: _idImage != null
                              ? 'Image uploaded'
                              : (_user['validIdPhoto'] ?? 'Not uploaded'),
                        ),
                      ] else ...[
                        _ProfileField(
                          label: 'Valid ID Type',
                          value: _selectedValidIdType ?? '',
                          isEditing: _isEditing,
                          onEdit: (v) =>
                              setState(() => _selectedValidIdType = v),
                          child: SreaDropdown<String>(
                            hint: 'Select ID Type',
                            value: _selectedValidIdType,
                            items: _validIdOptions,
                            onChanged: (v) =>
                                setState(() => _selectedValidIdType = v),
                            required: true,
                          ),
                        ),
                        const Divider(height: 1, color: SreaColors.divider),
                        _ProfileField(
                          label: 'ID Photo',
                          value: _idImage != null
                              ? 'Image uploaded'
                              : (_user['validIdPhoto'] ?? 'Not uploaded'),
                          isEditing: _isEditing,
                          onEdit: (_) => _pickIdImage(),
                          child: SreaImageUpload(
                            selectedImage: _idImage,
                            onTap: _pickIdImage,
                            onRemove: () => setState(() => _idImage = null),
                            hint: 'Tap to upload ID',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Change Password button
              if (!_isEditing)
                SreaButton.outline(
                  label: 'Change Password',
                  onPressed: () => _showChangePasswordDialog(),
                  fullWidth: true,
                  icon: Icons.lock_outline_rounded,
                ),

              const SizedBox(height: 12),

              // Logout button (now works)
              if (!_isEditing)
                SreaButton.report(
                  label: 'Logout',
                  onPressed: _logout,
                  fullWidth: true,
                  icon: Icons.logout_rounded,
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPassword = TextEditingController();
    final newPassword = TextEditingController();
    final confirmPassword = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: SreaRadius.modal),
        title: Text(
          'Change Password',
          style: SreaText.titleLarge(
            context,
          ).copyWith(color: SreaColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SreaPasswordField(
                label: 'Current Password',
                hint: 'Enter current password',
                controller: currentPassword,
                required: true,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              SreaPasswordField(
                label: 'New Password',
                hint: 'Enter new password',
                controller: newPassword,
                required: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'Minimum 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SreaPasswordField(
                label: 'Confirm New Password',
                hint: 'Re-enter new password',
                controller: confirmPassword,
                required: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v != newPassword.text) return 'Passwords do not match';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                // TODO: API call to change password
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Password changed successfully',
                      style: SreaText.bodySmall(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    backgroundColor: SreaColors.buttonUpdate,
                  ),
                );
              }
            },
            child: Text(
              'Update',
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper: Section header with blue bar
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

// Helper: Display field in read or edit mode
class _ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditing;
  final Function(String) onEdit;
  final Widget child;

  const _ProfileField({
    required this.label,
    required this.value,
    required this.isEditing,
    required this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: SreaText.label(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isEditing
                ? child
                : Text(
                    value.isEmpty ? 'Not set' : value,
                    style: SreaText.bodySmall(
                      context,
                    ).copyWith(color: SreaColors.textPrimary),
                  ),
          ),
        ],
      ),
    );
  }
}

// Helper: Read-only field
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: SreaText.label(
                context,
              ).copyWith(color: SreaColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: SreaText.bodySmall(
                context,
              ).copyWith(color: SreaColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
