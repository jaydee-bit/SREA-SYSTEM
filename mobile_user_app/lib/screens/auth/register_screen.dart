// File: register_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srea_shared/srea_shared.dart';
import 'pending_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _residencyStatus;
  bool get _isResident => _residencyStatus == 'resident';

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();

  String? _barangay;
  final _streetController = TextEditingController();

  String? _validIdType;
  File? _idImage;

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];
  final List<String> _barangayOptions = [
    'Banca-Banca', 'BMA – Balagtas', 'Caingin', 'Capihan', 'Coral na Bato',
    'Cruz na Daan', 'Dagat-Dagatan', 'Diliman I', 'Diliman II', 'Libis',
    'Lico', 'Maasim', 'Mabalas-Balas', 'Maguinao', 'Maronquillo', 'Paco',
    'Pansumaloc', 'Pantubig', 'Pasong Bangkal', 'Pasong Callos', 'Pasong Intsik',
    'Pinacpinacan', 'Poblacion', 'Pulo', 'Pulong Bayabas', 'Salapungan',
    'Sampaloc', 'San Agustin', 'San Roque', 'Sapang Pahalang', 'Talacsan',
    'Tambubong', 'Tukod', 'Ulingao'
  ];
  final List<String> _validIdOptions = [
    'PhilSys / National ID', 'Driver\'s License', 'Passport', 'Voter\'s ID',
    'Postal ID', 'SSS ID', 'GSIS ID', 'Barangay ID',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _streetController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SreaColors.primary,
              onPrimary: SreaColors.textOnPrimary,
              surface: SreaColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _birthDateController.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _pickIdImage() async {
    // TODO: implement image picker
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_residencyStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select your residency status',
            style: SreaText.bodySmall(context).copyWith(color: Colors.white),
          ),
          backgroundColor: SreaColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: SreaRadius.input),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // After successful registration, navigate to pending screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PendingVerificationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _CompactHeader(onBack: () => Navigator.pop(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: 'Personal Information'),
                      SizedBox(height: SreaSpacing.sectionHeaderGap(context)),
                      SreaTextField(
                        label: 'First Name',
                        hint: 'Enter first name',
                        controller: _firstNameController,
                        required: true,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaTextField(
                        label: 'Middle Name',
                        hint: 'Enter middle name (optional)',
                        controller: _middleNameController,
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaTextField(
                        label: 'Last Name',
                        hint: 'Enter last name',
                        controller: _lastNameController,
                        required: true,
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaDropdown<String>(
                        label: 'Gender',
                        hint: 'Choose your Gender',
                        value: _gender,
                        items: _genderOptions,
                        required: true,
                        onChanged: (v) => setState(() => _gender = v),
                        validator: (v) => v == null ? 'Please select gender' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaInputLabel(label: 'Birth Date', required: true),
                      SizedBox(height: SreaSpacing.inputLabelGap(context)),
                      TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        style: SreaText.bodySmall(context).copyWith(color: SreaColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'MM/DD/YYYY',
                          hintStyle: SreaText.bodySmall(context).copyWith(color: SreaColors.textHint),
                          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 18, color: SreaColors.textHint),
                          contentPadding: SreaSpacing.inputPadding(context),
                          filled: true,
                          fillColor: SreaColors.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(color: SreaColors.border, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(color: SreaColors.borderFocused, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(color: SreaColors.error, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(color: SreaColors.error, width: 1.5),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaTextField(
                        label: 'Email',
                        hint: 'example@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        required: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaTextField(
                        label: 'Contact Number',
                        hint: '09XXXXXXXXX',
                        controller: _contactController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        required: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 11) return 'Enter a valid 11-digit number';
                          return null;
                        },
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      _SectionHeader(title: 'Residency Status'),
                      SizedBox(height: SreaSpacing.sectionHeaderGap(context)),
                      SreaRadioGroup<String>(
                        groupValue: _residencyStatus,
                        onChanged: (v) => setState(() => _residencyStatus = v),
                        options: const [
                          SreaRadioItem(
                            label: 'Resident of San Rafael',
                            value: 'resident',
                            subtitle: 'I live in San Rafael, Bulacan',
                          ),
                          SreaRadioItem(
                            label: 'Non-Resident',
                            value: 'non_resident',
                            subtitle: 'I do not reside in San Rafael',
                          ),
                        ],
                      ),
                      if (_isResident) ...[
                        SizedBox(height: SreaSpacing.sectionGap(context)),
                        _SectionHeader(title: 'Address'),
                        SizedBox(height: SreaSpacing.sectionHeaderGap(context)),
                        SreaTextField(label: 'Province', hint: 'Bulacan', enabled: false),
                        SizedBox(height: SreaSpacing.inputGap(context)),
                        SreaTextField(label: 'Municipality', hint: 'San Rafael', enabled: false),
                        SizedBox(height: SreaSpacing.inputGap(context)),
                        SreaDropdown<String>(
                          label: 'Barangay',
                          hint: 'Choose your Barangay',
                          value: _barangay,
                          items: _barangayOptions,
                          required: true,
                          onChanged: (v) => setState(() => _barangay = v),
                          validator: (v) => v == null ? 'Please select your barangay' : null,
                        ),
                        SizedBox(height: SreaSpacing.inputGap(context)),
                        SreaTextField(
                          label: 'Street / House No.',
                          hint: 'Enter your address',
                          controller: _streetController,
                          required: true,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        SizedBox(height: SreaSpacing.sectionGap(context)),
                        _SectionHeader(title: 'Verification'),
                        SizedBox(height: SreaSpacing.sectionHeaderGap(context)),
                        SreaDropdown<String>(
                          label: 'Valid ID',
                          hint: 'Choose your ID type',
                          value: _validIdType,
                          items: _validIdOptions,
                          required: true,
                          onChanged: (v) => setState(() => _validIdType = v),
                          validator: (v) => v == null ? 'Please select an ID type' : null,
                        ),
                        SizedBox(height: SreaSpacing.inputGap(context)),
                        SreaImageUpload(
                          label: 'Upload ID Photo',
                          hint: 'Tap to upload your ID',
                          selectedImage: _idImage,
                          onTap: _pickIdImage,
                          onRemove: () => setState(() => _idImage = null),
                        ),
                      ],
                      SizedBox(height: SreaSpacing.sectionGap(context)),
                      _SectionHeader(title: 'Password'),
                      SizedBox(height: SreaSpacing.sectionHeaderGap(context)),
                      SreaPasswordField(
                        label: 'Password',
                        hint: 'Enter password',
                        controller: _passwordController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      SizedBox(height: SreaSpacing.inputGap(context)),
                      SreaPasswordField(
                        label: 'Confirm Password',
                        hint: 'Re-enter password',
                        controller: _confirmPasswordController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 36),
                      SreaButton(
                        label: 'Register',
                        onPressed: _handleRegister,
                        fullWidth: true,
                        isLoading: _isLoading,
                        size: SreaButtonSize.large,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account?  ',
                              style: SreaText.bodySmall(context).copyWith(color: SreaColors.textSecondary),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: SreaText.bodySmall(context).copyWith(
                                    color: SreaColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  final VoidCallback onBack;
  const _CompactHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 16, 24, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [SreaColors.primaryDark, SreaColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: SreaColors.textOnPrimary, size: 20),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: SreaText.headlineSmall(context).copyWith(
                  color: SreaColors.textOnPrimary,
                  fontSize: 20,
                ),
              ),
              Text(
                'Fill in the details below to register',
                style: SreaText.label(context).copyWith(color: SreaColors.bottomNavInactive),
              ),
            ],
          ),
        ],
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
          style: SreaText.titleLarge(context).copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: SreaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}