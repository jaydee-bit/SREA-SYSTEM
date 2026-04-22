// File: profile_screen.dart
// Path: mobile_user_app/lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srea_shared/srea_shared.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final Function(String?)? onProfileImageUpdated;

  const ProfileScreen({super.key, this.onProfileImageUpdated});

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
    'barangay': '',
    'street': '',
    'isVerified': false,
    'role': 'resident',
    'validIdType': '',
    'validIdPhoto': null,
    'profileImage': null,
    'isProfileComplete': false,
  };

  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthDateController;

  String? _selectedGender;
  File? _profileImage;

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingProfileImage = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];

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
    _birthDateController = TextEditingController(text: _user['birthDate']);
    _selectedGender = _user['gender'];
    if (_user['profileImage'] != null && _user['profileImage'] is String) {
      _profileImage = File(_user['profileImage']);
    }
  }

  Future<void> _pickProfileImage() async {
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
                await _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: SreaColors.primary),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isUploadingProfileImage = true);
    final picker = ImagePicker();
    try {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        setState(() => _profileImage = File(picked.path));
        _user['profileImage'] = picked.path;
        widget.onProfileImageUpdated?.call(picked.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile picture updated',
                style: SreaText.bodySmall(
                  context,
                ).copyWith(color: Colors.white),
              ),
              backgroundColor: SreaColors.buttonUpdate,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile picture',
              style: SreaText.bodySmall(context).copyWith(color: Colors.white),
            ),
            backgroundColor: SreaColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingProfileImage = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
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

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isResident = _user['role'] == 'resident';
    final fullName = '${_firstNameController.text} ${_lastNameController.text}';

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
          child: Column(
            children: [
              _ProfileHeader(
                userName: fullName,
                email: _emailController.text,
                isVerified: _user['isVerified'],
                profileImage: _profileImage,
                isUploading: _isUploadingProfileImage,
                onImageTap: _pickProfileImage,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v),
                            ),
                          ),
                          const Divider(height: 1, color: SreaColors.divider),
                          _ReadOnlyField(
                            label: 'Birth Date',
                            value: _birthDateController.text.isEmpty
                                ? 'Not set'
                                : _birthDateController.text,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      _SectionHeader(title: 'Address & Verification'),
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
                            _ReadOnlyField(
                              label: 'Barangay',
                              value: _user['barangay'].isEmpty
                                  ? 'Not set'
                                  : _user['barangay'],
                            ),
                            const Divider(height: 1, color: SreaColors.divider),
                            _ReadOnlyField(
                              label: 'Street',
                              value: _user['street'].isEmpty
                                  ? 'Not set'
                                  : _user['street'],
                            ),
                            const Divider(height: 1, color: SreaColors.divider),
                            _ReadOnlyField(
                              label: 'Valid ID Type',
                              value: _user['validIdType'].isEmpty
                                  ? 'Not set'
                                  : _user['validIdType'],
                            ),
                            const Divider(height: 1, color: SreaColors.divider),
                            _ReadOnlyField(
                              label: 'ID Photo',
                              value: _user['validIdPhoto'] != null
                                  ? 'Uploaded'
                                  : 'Not uploaded',
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (!_isEditing)
                      SreaButton.outline(
                        label: 'Change Password',
                        onPressed: () => _showChangePasswordDialog(),
                        fullWidth: true,
                        icon: Icons.lock_outline_rounded,
                      ),
                    const SizedBox(height: 12),
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

// ─── Blue header ───────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String email;
  final bool isVerified;
  final File? profileImage;
  final bool isUploading;
  final VoidCallback onImageTap;

  const _ProfileHeader({
    required this.userName,
    required this.email,
    required this.isVerified,
    required this.profileImage,
    required this.isUploading,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SreaColors.primaryDark, SreaColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SreaColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: profileImage != null
                        ? Image.file(
                            profileImage!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person_outline_rounded,
                            size: 44,
                            color: SreaColors.primary,
                          ),
                  ),
                ),
                if (isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: SreaColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: SreaText.titleLarge(context).copyWith(
              color: SreaColors.textOnPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: SreaText.bodySmall(
              context,
            ).copyWith(color: SreaColors.bottomNavInactive),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: SreaRadius.pill,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: SreaColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Account',
                    style: SreaText.label(context).copyWith(
                      color: SreaColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: SreaRadius.pill,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pending_outlined,
                    size: 14,
                    color: SreaColors.textOnPrimary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pending Verification',
                    style: SreaText.label(context).copyWith(
                      color: SreaColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ─────────────────────────────────────────
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
