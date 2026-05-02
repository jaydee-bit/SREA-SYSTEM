import 'package:flutter/material.dart';
import 'package:srea_shared/srea_shared.dart';
import 'package:google_fonts/google_fonts.dart';
import 'incident_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const IncidentListScreen(showAppBar: false), // ✅ no extra app bar
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SreaColors.background,
      appBar: AppBar(
        backgroundColor: SreaColors.primary,
        elevation: 0,
        title: Row(
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
                children: const [
                  TextSpan(
                    text: 'SR',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'EA',
                    style: TextStyle(color: Color(0xFFFF3B30)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: SreaRadius.pill,
              ),
              child: Text(
                'Responder',
                style: SreaText.label(context).copyWith(
                  color: SreaColors.textOnPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: SreaColors.primary,
        selectedItemColor: SreaColors.bottomNavActive,
        unselectedItemColor: SreaColors.bottomNavInactive,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
