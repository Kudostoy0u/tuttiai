import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _practiceRemindersKey = 'practice_reminders';
  static const String _reminderTimeKey = 'reminder_time';
  static const String _defaultTuningKey = 'default_tuning';
  static const String _metronomeTempoKey = 'metronome_tempo';
  static const String _languageKey = 'language';

  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _practiceReminders = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  String _defaultTuning = 'A4 = 440 Hz';
  int _metronomeDefaultTempo = 120;
  String _language = 'English';

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get practiceReminders => _practiceReminders;
  TimeOfDay get reminderTime => _reminderTime;
  String get defaultTuning => _defaultTuning;
  int get metronomeDefaultTempo => _metronomeDefaultTempo;
  String get language => _language;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isDarkMode = prefs.getBool(_darkModeKey) ?? true;
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _practiceReminders = prefs.getBool(_practiceRemindersKey) ?? false;
    
    // Load reminder time
    final reminderHour = prefs.getInt('${_reminderTimeKey}_hour') ?? 18;
    final reminderMinute = prefs.getInt('${_reminderTimeKey}_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);
    
    _defaultTuning = prefs.getString(_defaultTuningKey) ?? 'A4 = 440 Hz';
    _metronomeDefaultTempo = prefs.getInt(_metronomeTempoKey) ?? 120;
    _language = prefs.getString(_languageKey) ?? 'English';
    
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    notifyListeners();
  }

  Future<void> setPracticeReminders(bool value) async {
    _practiceReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_practiceRemindersKey, value);
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_reminderTimeKey}_hour', time.hour);
    await prefs.setInt('${_reminderTimeKey}_minute', time.minute);
    notifyListeners();
  }

  Future<void> setDefaultTuning(String tuning) async {
    _defaultTuning = tuning;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultTuningKey, tuning);
    notifyListeners();
  }

  Future<void> setMetronomeDefaultTempo(int tempo) async {
    _metronomeDefaultTempo = tempo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_metronomeTempoKey, tempo);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    notifyListeners();
  }
} 