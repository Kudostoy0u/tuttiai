import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://zbnyqtcrpbpzanhusyqi.supabase.co';
  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpibnlxdGNycGJwemFuaHVzeXFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEyNTU1MTYsImV4cCI6MjA2NjgzMTUxNn0.iFw4L5GMuT6lFB8yVHB8IhYF0sQEPrk19W_5I8cE7VQ';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
} 