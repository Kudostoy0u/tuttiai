import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_modal.dart';
import 'dashboard_screen.dart';
import 'library_screen.dart';
import 'settings_screen.dart';
import '../../providers/settings_provider.dart';
import '../../services/localization_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOnboarding();
    });
  }

  void _checkOnboarding() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.hasCompletedOnboarding) {
      // Debugging: print that onboarding will show
      // ignore: avoid_print
      print('MainLayout: Onboarding incomplete, showing modal.');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const OnboardingModal(),
      );
    } else {
      // Debugging: print that onboarding is complete
      // ignore: avoid_print
      print('MainLayout: Onboarding already completed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: LocalizationService.translate('home', settings.language),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.library_music),
              label: LocalizationService.translate('library', settings.language),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: LocalizationService.translate('settings', settings.language),
            ),
          ],
        ),
      ),
    );
  }
} 