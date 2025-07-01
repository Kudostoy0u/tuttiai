import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/main_layout.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  runApp(const TuttiApp());
}

class TuttiApp extends StatelessWidget {
  const TuttiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Tutti',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
              ),
              textTheme: GoogleFonts.interTextTheme(
                settings.isDarkMode
                    ? const TextTheme(
                        bodyLarge: TextStyle(color: Colors.white),
                        bodyMedium: TextStyle(color: Colors.white),
                        bodySmall: TextStyle(color: Colors.white),
                        headlineLarge: TextStyle(color: Colors.white),
                        headlineMedium: TextStyle(color: Colors.white),
                        headlineSmall: TextStyle(color: Colors.white),
                        titleLarge: TextStyle(color: Colors.white),
                        titleMedium: TextStyle(color: Colors.white),
                        titleSmall: TextStyle(color: Colors.white),
                        labelLarge: TextStyle(color: Colors.white),
                        labelMedium: TextStyle(color: Colors.white),
                        labelSmall: TextStyle(color: Colors.white),
                      )
                    : const TextTheme(
                        bodyLarge: TextStyle(color: Colors.black87),
                        bodyMedium: TextStyle(color: Colors.black87),
                        bodySmall: TextStyle(color: Colors.black87),
                        headlineLarge: TextStyle(color: Colors.black87),
                        headlineMedium: TextStyle(color: Colors.black87),
                        headlineSmall: TextStyle(color: Colors.black87),
                        titleLarge: TextStyle(color: Colors.black87),
                        titleMedium: TextStyle(color: Colors.black87),
                        titleSmall: TextStyle(color: Colors.black87),
                        labelLarge: TextStyle(color: Colors.black87),
                        labelMedium: TextStyle(color: Colors.black87),
                        labelSmall: TextStyle(color: Colors.black87),
                      ),
              ),
              scaffoldBackgroundColor: settings.isDarkMode 
                  ? const Color(0xFF0F0F23) 
                  : Colors.grey[50],
              appBarTheme: AppBarTheme(
                backgroundColor: settings.isDarkMode 
                    ? const Color(0xFF0F0F23) 
                    : Colors.white,
                elevation: 0,
                foregroundColor: settings.isDarkMode ? Colors.white : Colors.black,
                titleTextStyle: TextStyle(
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                iconTheme: IconThemeData(
                  color: settings.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              cardTheme: CardThemeData(
                color: settings.isDarkMode 
                    ? const Color(0xFF1E1E3F) 
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              iconTheme: IconThemeData(
                color: settings.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            home: const AppWrapper(),
          );
        },
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoading) {
          return const SplashScreen();
        }
        
        if (auth.isAuthenticated) {
          return const MainLayout();
        }
        
        return const LoginScreen();
      },
    );
  }
}
