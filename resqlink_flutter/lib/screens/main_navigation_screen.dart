import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'admin_screen.dart';
import 'auth_screen.dart';
import 'citizen_screen.dart';
import 'profile_screen.dart';
import 'responder_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CitizenScreen(),
    ResponderScreen(),
    AdminScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading && !auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.bgDarkest,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryRed),
        ),
      );
    }

    if (!auth.isAuthenticated) {
      return const AuthScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.emergency_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emergency_rounded,
                color: AppTheme.primaryRed,
              ),
            ),
            label: 'Citizen SOS',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.medical_services_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.successMint.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: AppTheme.successMint,
              ),
            ),
            label: 'Responder',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_customize_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF9D4EDD).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dashboard_customize_rounded,
                color: Color(0xFF9D4EDD),
              ),
            ),
            label: 'Admin',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            activeIcon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.infoCyan.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_rounded, color: AppTheme.infoCyan),
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
