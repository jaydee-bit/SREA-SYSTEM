import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const ResponderApp());
}

class ResponderApp extends StatelessWidget {
  const ResponderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SREA Responder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: SreaColors.background,
        fontFamily: 'PlusJakartaSans',
      ),
      home: const LoginScreen(),
    );
  }
}
