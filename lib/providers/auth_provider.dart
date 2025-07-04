import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;
  bool _isNewUser = false;
  Map<String, dynamic> _userProfile = {};
  User? _currentUser;

  // NEW: Helper keys list for onboarding fields
  static const List<String> _onboardingKeys = [
    'instrument',
    'skill_level',
    'genre',
    'genres',
    'practice_frequency',
    'has_teacher',
    'goals',
  ];

  // NEW: Determine if onboarding is completed based on profile data
  bool _isProfileComplete(dynamic profile) {
    if (profile == null || profile is! Map) {
      if (kDebugMode) print('Profile is null or not a map -> incomplete');
      return false;
    }
    final mapProfile = profile;
    for (final key in _onboardingKeys) {
      final value = mapProfile[key];
      if (kDebugMode) {
        print('Onboarding field "$key" value: $value');
      }
      if (value != null) {
        if (value is String && value.trim().isEmpty) continue;
        if (value is Iterable && value.isEmpty) continue;
        if (kDebugMode) print('Profile considered complete due to "$key"');
        return true;
      }
    }
    if (kDebugMode) print('No onboarding fields populated -> incomplete');
    return false;
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isNewUser => _isNewUser;
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

        // Try fetching profile from Supabase as the source of truth for onboarding
        if (_currentUser?.id != null) {
          try {
            final response = await SupabaseService.client
                .from('user_profiles')
                .select()
                .eq('user_id', _currentUser!.id)
                .maybeSingle();
            // EDIT: Determine onboarding completion using helper
            if (_isProfileComplete(response)) {
              _userProfile = Map<String, dynamic>.from(response!);
              _hasCompletedOnboarding = true;
              await prefs.setString('userProfile', jsonEncode(_userProfile));
              await prefs.setBool('hasCompletedOnboarding', true);
            } else {
              // Profile doesn't exist or is incomplete, so onboarding is not complete
              _hasCompletedOnboarding = false;
              await prefs.setBool('hasCompletedOnboarding', false);
            }
          } catch (e) {
            // If Supabase fetch fails, fallback to local storage
            if (kDebugMode) {
              print('Error fetching profile from Supabase: $e');
            }
            _hasCompletedOnboarding =
                prefs.getBool('hasCompletedOnboarding') ?? false;
            final profileData = prefs.getString('userProfile');
            if (profileData != null) {
              _userProfile = jsonDecode(profileData);
            }
            _userProfile['name'] = _currentUser?.userMetadata?['name'];
          }
        } else {
          _hasCompletedOnboarding =
              prefs.getBool('hasCompletedOnboarding') ?? false;
        }
      } else {
        _isAuthenticated = false;
        _hasCompletedOnboarding = false;
      }
      
      // Listen to auth state changes and process profile before notifying.
      SupabaseService.client.auth.onAuthStateChange.listen((data) async {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;

        if (event == AuthChangeEvent.signedIn && session != null) {
          await _handleSignedIn(session);
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
      if (kDebugMode) {
        print('Error initializing auth: $e');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user != null) {
        _currentUser = response.user;
        _isNewUser = true; // Flag as new user
        _hasCompletedOnboarding = false;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasCompletedOnboarding', false);
        
        notifyListeners();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Auth error: ${e.message}');
      }
      throw e.message;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      throw 'An unexpected error occurred';
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final response = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session == null) {
        // This indicates the user's email is not yet confirmed
        throw 'Please confirm your email before logging in.';
      }
      
      if (response.user != null) {
        _currentUser = response.user;
        _isAuthenticated = true;
        _isNewUser = false; // User is signing in, so not "new" in this context
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        
        // No need to fetch profile here; the auth state change listener will handle it
        return true;
      }
      return false;
    } on AuthException catch (e) {
      if (kDebugMode) {
        print('Auth error: ${e.message}');
      }
      throw e.message;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error: $e');
      }
      if (e is String) {
        rethrow;
      }
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
      await prefs.remove('isAuthenticated');
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      throw 'Failed to sign out';
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profile) async {
    try {
      final currentUser = SupabaseService.client.auth.currentUser;
      if (currentUser == null) {
        throw 'Cannot complete onboarding. User is not authenticated.';
      }

      _userProfile = {
        'name': currentUser.userMetadata?['name'],
        ...profile,
      };
      _hasCompletedOnboarding = true;
      _isNewUser = false; // Reset the new user flag
      _isAuthenticated = true; // Officially authenticate now
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      await prefs.setString('userProfile', jsonEncode(_userProfile));
      
      // Save to Supabase
      final profileForDb = {
        'user_id': currentUser.id,
        'name': _userProfile['name'],
        'instrument': _userProfile['instrument'],
        'skill_level': _userProfile['skillLevel'],
        'genres': _userProfile['genres'],
        'practice_frequency': _userProfile['practiceFrequency'],
        'has_teacher': _userProfile['hasTeacher'],
        'goals': _userProfile['goals'],
      };
      profileForDb.removeWhere((key, value) => value == null);

      await SupabaseService.client.from('user_profiles').upsert(profileForDb);
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error completing onboarding: $e');
      }
      throw 'Failed to complete onboarding';
    }
  }

  // NEW: Handle signed-in event by fetching profile before notifying listeners.
  Future<void> _handleSignedIn(Session session) async {
    _currentUser = session.user;
    if (kDebugMode) print('Auth change: processing signed-in user ${_currentUser?.id}');

    final prefs = await SharedPreferences.getInstance();

    try {
      final profileResponse = await SupabaseService.client
          .from('user_profiles')
          .select()
          .eq('user_id', _currentUser!.id)
          .maybeSingle();

      if (_isProfileComplete(profileResponse)) {
        _userProfile = Map<String, dynamic>.from(profileResponse!);
        _hasCompletedOnboarding = true;
        if (kDebugMode) print('HandleSignedIn: Profile complete.');
        await prefs.setString('userProfile', jsonEncode(_userProfile));
        await prefs.setBool('hasCompletedOnboarding', true);
      } else {
        if (kDebugMode) print('HandleSignedIn: Profile incomplete.');
        _hasCompletedOnboarding = false;
        await prefs.setBool('hasCompletedOnboarding', false);
      }
    } catch (e) {
      if (kDebugMode) {
        print('HandleSignedIn: Error fetching profile: $e');
      }
      _hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
    }

    // Authenticate the user unless it's a new-user sign-up that hasn't completed onboarding yet.
    if (!_isNewUser) {
      _isAuthenticated = true;
    }

    // Notify listeners AFTER all fields are finalized.
    notifyListeners();
  }

  // -------- Profile update helpers --------
  Future<void> updateEmail(String newEmail) async {
    try {
      final response = await SupabaseService.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      if (response.user != null) {
        _currentUser = response.user;
        notifyListeners();
      }
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw e.message;
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> data) async {
    if (_currentUser == null) throw 'Not authenticated';

    final payload = {
      'user_id': _currentUser!.id,
      ...data,
    };
    payload.removeWhere((key, value) => value == null);

    await SupabaseService.client.from('user_profiles').upsert(payload);

    _userProfile.addAll(data);
    notifyListeners();
  }
} 