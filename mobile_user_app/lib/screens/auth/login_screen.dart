import 'package:flutter/material.dart';
import 'package:mobile_user_app/screens/auth/register_screen.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: connect to your auth service
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Top blue wave header with logo ───────────
                  _HeaderSection(),

                  // ── Form section ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Welcome back',
                            style: SreaText.headlineSmall.copyWith(
                              color: SreaColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to continue to SREA',
                            style: SreaText.bodySmall.copyWith(
                              color: SreaColors.textSecondary,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Email field
                          SreaTextField(
                            label: 'Email',
                            hint: 'example@gmail.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail_outline_rounded,
                            required: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Email is required';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: SreaSpacing.inputGap),

                          // Password field
                          SreaPasswordField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            required: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }
                              if (v.length < 6) {
                                return 'Minimum 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: navigate to forgot password screen
                              },
                              child: Text(
                                'Forgot password?',
                                style: SreaText.bodySmall.copyWith(
                                  color: SreaColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Login button
                          SreaButton(
                            label: 'Login',
                            onPressed: _handleLogin,
                            fullWidth: true,
                            isLoading: _isLoading,
                            size: SreaButtonSize.large,
                          ),

                          const SizedBox(height: 24),

                          // Divider with "or"
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: SreaColors.divider),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or',
                                  style: SreaText.label.copyWith(
                                    color: SreaColors.textHint,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: SreaColors.divider),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Register link
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account?  ",
                                  style: SreaText.bodySmall.copyWith(
                                    color: SreaColors.textSecondary,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Register',
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

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Blue wave header with logo
// ─────────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Blue gradient wave background
        ClipPath(
          clipper: _WaveClipper(),
          child: Container(
            height: 260,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SreaColors.primaryDark, SreaColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),

        // Logo + app name centered in wave
        Positioned(
          top: 32,
          child: Column(
            children: [
              // ── SREA Logo ─────────────────────────────────
              // PNG has transparent background — rendered directly
              // on the blue wave. No container or clip needed.
              // File: assets/images/logooo.png
              RichText(
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 56,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 4,
                  ),
                  children: [
                    TextSpan(
                      text: 'SR',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'EA',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 0, 0), // red
                      ),
                    ),
                  ],
                ),
              ),

              // ──────────────────────────────────────────────
              const SizedBox(height: 8),

              Text(
                'San Rafael Emergency Alert',
                style: SreaText.label.copyWith(
                  color: SreaColors.bottomNavInactive,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Wave shape clipper
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 28,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height - 56,
      size.width,
      size.height - 18,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
