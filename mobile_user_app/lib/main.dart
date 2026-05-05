import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const SreaApp());
}

class SreaApp extends StatelessWidget {
  const SreaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SREA - San Rafael Emergency',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: SreaColors.primary,
        scaffoldBackgroundColor: SreaColors.background,
        colorScheme: const ColorScheme.light(
          primary: SreaColors.primary,
          secondary: SreaColors.primary,
          surface: SreaColors.surface,
          error: SreaColors.error,
        ),
        fontFamily: 'PlusJakartaSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: SreaColors.primary,
          foregroundColor: SreaColors.textOnPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SreaRadius.md),
            borderSide: const BorderSide(color: SreaColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SreaRadius.md),
            borderSide: const BorderSide(color: SreaColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SreaRadius.md),
            borderSide: const BorderSide(color: SreaColors.primary, width: 2),
          ),
          filled: true,
          fillColor: SreaColors.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SreaColors.primary,
            foregroundColor: SreaColors.textOnPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SreaRadius.md),
            ),
          ),
        ),
      ),
      home: const AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });
        return;
      }

      // Token exists – validate by fetching user
      final api = ApiService();
      await api.getUser();
      // If no exception, token is valid
      setState(() {
        _isAuthenticated = true;
        _isChecking = false;
      });
    } catch (e) {
      // Token invalid – clear it and go to login
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'auth_token');
      setState(() {
        _isAuthenticated = false;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Scaffold(
        backgroundColor: SreaColors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: SreaText.bodyLarge(
                  context,
                ).copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
