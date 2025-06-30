import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;
  Map<String, dynamic> _userProfile = {};
  User? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  Map<String, dynamic> get userProfile => _userProfile;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user is already signed in with Supabase
      final session = SupabaseService.client.auth.currentSession;
      if (session != null) {
        _currentUser = session.user;
        _isAuthenticated = true;
        _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
        
        // Load user profile if exists
        final profileData = prefs.getString('userProfile');
        if (profileData != null) {
          _userProfile = jsonDecode(profileData);
        }
      } else {
        _isAuthenticated = false;
        _hasCompletedOnboarding = false;
      }
      
      // Listen to auth state changes
      SupabaseService.client.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        if (event == AuthChangeEvent.signedIn && session != null) {
          _currentUser = session.user;
          _isAuthenticated = true;
          notifyListeners();
        } else if (event == AuthChangeEvent.signedOut) {
          _currentUser = null;
          _isAuthenticated = false;
          _hasCompletedOnboarding = false;
          _userProfile = {};
          notifyListeners();
        }
      });
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = response.user;
        _isAuthenticated = true;
        _hasCompletedOnboarding = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setBool('hasCompletedOnboarding', false);
        
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      throw e.message ?? 'Sign up failed';
    } catch (e) {
      print('Unexpected error: $e');
      throw 'An unexpected error occurred';
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _currentUser = response.user;
        _isAuthenticated = true;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        
        // Check if user has completed onboarding
        _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? true;
        
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      print('Auth error: ${e.message}');
      throw e.message;
    } catch (e) {
      print('Unexpected error: $e');
      throw 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      await SupabaseService.client.auth.signOut();
      
      _currentUser = null;
      _isAuthenticated = false;
      _hasCompletedOnboarding = false;
      _userProfile = {};
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
      throw 'Failed to sign out';
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    try {
      _userProfile = profile;
      _hasCompletedOnboarding = true;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      await prefs.setString('userProfile', jsonEncode(profile));
      
      // Save to Supabase would go here
      // await SupabaseService.client.from('user_profiles').insert({
      //   ...profile,
      //   'user_id': _currentUser?.id,
      // });
      
      notifyListeners();
    } catch (e) {
      print('Error completing onboarding: $e');
      throw 'Failed to complete onboarding';
    }
  }
} 