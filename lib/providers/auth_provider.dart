import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;
  Map<String, dynamic> _userProfile = {};

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  Map<String, dynamic> get userProfile => _userProfile;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
      
      // Load user profile if exists
      final profileData = prefs.getString('userProfile');
      if (profileData != null) {
        // _userProfile = jsonDecode(profileData);
      }
      
      // For MVP - simulate loading time
      await Future.delayed(const Duration(seconds: 2));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      // Supabase sign up would go here
      // final response = await Supabase.instance.client.auth.signUp(
      //   email: email,
      //   password: password,
      // );
      
      // For MVP - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isAuthenticated = true;
      _hasCompletedOnboarding = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setBool('hasCompletedOnboarding', false);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      // Supabase sign in would go here
      // final response = await Supabase.instance.client.auth.signInWithPassword(
      //   email: email,
      //   password: password,
      // );
      
      // For MVP - simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _isAuthenticated = true;
      _hasCompletedOnboarding = true; // Assume returning users completed onboarding
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setBool('hasCompletedOnboarding', true);
      
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Supabase sign out would go here
      // await Supabase.instance.client.auth.signOut();
      
      _isAuthenticated = false;
      _hasCompletedOnboarding = false;
      _userProfile = {};
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    try {
      _userProfile = profile;
      _hasCompletedOnboarding = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      // await prefs.setString('userProfile', jsonEncode(profile));
      
      // Save to Supabase would go here
      // await Supabase.instance.client.from('user_profiles').insert(profile);
      
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
} 