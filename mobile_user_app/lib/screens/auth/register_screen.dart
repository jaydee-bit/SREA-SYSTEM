import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:srea_shared/srea_shared.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // ── Residency ─────────────────────────────────────────────
  String? _residencyStatus; // 'resident' | 'non_resident'
  bool get _isResident => _residencyStatus == 'resident';

  // ── Personal info controllers ──────────────────────────────
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _gender;
  final _birthDateController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();

  // ── Address controllers (resident only) ───────────────────
  String? _barangay;
  final _streetController = TextEditingController();

  // ── Verification (resident only) ──────────────────────────
  String? _validIdType;
  File? _idImage;

  // ── Password controllers ───────────────────────────────────
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Dropdown options ───────────────────────────────────────
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
    'Ulingao'
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
    // TODO: integrate image_picker package
    // final picker = ImagePicker();
    // final picked = await picker.pickImage(source: ImageSource.gallery);
    // if (picked != null) setState(() => _idImage = File(picked.path));
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_residencyStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your residency status',
              style: SreaText.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: SreaColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: SreaRadius.input),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    // TODO: connect to your registration service
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    // TODO: navigate to next screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Compact header ───────────────────────────────
            _CompactHeader(
              onBack: () => Navigator.pop(context),
            ),

            // ── Scrollable form ──────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Section: Personal Information ────────
                      _SectionHeader(title: 'Personal Information'),
                      SizedBox(height: SreaSpacing.sectionHeaderGap),

                      // First name
                      SreaTextField(
                        label: 'First Name',
                        hint: 'Enter first name',
                        controller: _firstNameController,
                        required: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      // Middle name
                      SreaTextField(
                        label: 'Middle Name',
                        hint: 'Enter middle name (optional)',
                        controller: _middleNameController,
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      // Last name
                      SreaTextField(
                        label: 'Last Name',
                        hint: 'Enter last name',
                        controller: _lastNameController,
                        required: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      // Gender
                      SreaDropdown<String>(
                        label: 'Gender',
                        hint: 'Choose your Gender',
                        value: _gender,
                        items: _genderOptions,
                        required: true,
                        onChanged: (v) => setState(() => _gender = v),
                        validator: (v) =>
                            v == null ? 'Please select gender' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      // Birth date
                      SreaInputLabel(label: 'Birth Date', required: true),
                      SizedBox(height: SreaSpacing.inputLabelGap),
                      TextFormField(
                        controller: _birthDateController,
                        readOnly: true,
                        onTap: _pickBirthDate,
                        style: SreaText.bodySmall
                            .copyWith(color: SreaColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'MM/DD/YYYY',
                          hintStyle: SreaText.bodySmall
                              .copyWith(color: SreaColors.textHint),
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: SreaColors.textHint,
                          ),
                          contentPadding: SreaSpacing.inputPadding,
                          filled: true,
                          fillColor: SreaColors.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                                color: SreaColors.border, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                                color: SreaColors.borderFocused, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                                color: SreaColors.error, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: SreaRadius.input,
                            borderSide: const BorderSide(
                                color: SreaColors.error, width: 1.5),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      // Email
                      SreaTextField(
                        label: 'Email',
                        hint: 'example@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        required: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      // Contact
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
                      SizedBox(height: SreaSpacing.inputGap),

                      // ── Section: Residency Status ────────────
                      _SectionHeader(title: 'Residency Status'),
                      SizedBox(height: SreaSpacing.sectionHeaderGap),

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

                      // ── Conditional: Address (resident only) ─
                      if (_isResident) ...[
                        SizedBox(height: SreaSpacing.sectionGap),
                        _SectionHeader(title: 'Address'),
                        SizedBox(height: SreaSpacing.sectionHeaderGap),

                        // Province — fixed
                        SreaTextField(
                          label: 'Province',
                          hint: 'Bulacan',
                          enabled: false,
                        ),
                        SizedBox(height: SreaSpacing.inputGap),

                        // Municipality — fixed
                        SreaTextField(
                          label: 'Municipality',
                          hint: 'San Rafael',
                          enabled: false,
                        ),
                        SizedBox(height: SreaSpacing.inputGap),

                        // Barangay dropdown
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
                        SizedBox(height: SreaSpacing.inputGap),

                        // Street / House no.
                        SreaTextField(
                          label: 'Street / House No.',
                          hint: 'Enter your address',
                          controller: _streetController,
                          required: true,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),

                        // ── Conditional: Verification ─────────
                        SizedBox(height: SreaSpacing.sectionGap),
                        _SectionHeader(title: 'Verification'),
                        SizedBox(height: SreaSpacing.sectionHeaderGap),

                        // Valid ID type
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
                        SizedBox(height: SreaSpacing.inputGap),

                        // Upload ID image
                        SreaImageUpload(
                          label: 'Upload ID Photo',
                          hint: 'Tap to upload your ID',
                          selectedImage: _idImage,
                          onTap: _pickIdImage,
                          onRemove: () => setState(() => _idImage = null),
                        ),
                      ],

                      // ── Section: Password ────────────────────
                      SizedBox(height: SreaSpacing.sectionGap),
                      _SectionHeader(title: 'Password'),
                      SizedBox(height: SreaSpacing.sectionHeaderGap),

                      SreaPasswordField(
                        label: 'Password',
                        hint: 'Enter password',
                        controller: _passwordController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v.length < 8) {
                            return 'Minimum 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: SreaSpacing.inputGap),

                      SreaPasswordField(
                        label: 'Confirm Password',
                        hint: 'Re-enter password',
                        controller: _confirmPasswordController,
                        required: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (v != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 36),

                      // ── Register button ──────────────────────
                      SreaButton(
                        label: 'Register',
                        onPressed: _handleRegister,
                        fullWidth: true,
                        isLoading: _isLoading,
                        size: SreaButtonSize.large,
                      ),

                      const SizedBox(height: 16),

                      // Back to login
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account?  ',
                              style: SreaText.bodySmall.copyWith(
                                color: SreaColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: SreaText.bodySmall.copyWith(
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

// ─────────────────────────────────────────────────────────────
// Compact blue header with back button
// ─────────────────────────────────────────────────────────────
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
          // Back button
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: SreaColors.textOnPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Account',
                style: SreaText.headlineSmall.copyWith(
                  color: SreaColors.textOnPrimary,
                  fontSize: 20,
                ),
              ),
              Text(
                'Fill in the details below to register',
                style: SreaText.label.copyWith(
                  color: SreaColors.bottomNavInactive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section header with colored left bar
// ─────────────────────────────────────────────────────────────
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
          style: SreaText.titleLarge.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: SreaColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
