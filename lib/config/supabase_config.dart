// lib/config/supabase_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Validate that credentials are loaded
  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;

  /// Debug method to check configuration status
  static void printConfigStatus() {
    print('🔧 Supabase Configuration Status:');
    print('   URL: ${url.isNotEmpty ? "✅ Set" : "❌ Missing"}');
    print('   Anon Key: ${anonKey.isNotEmpty ? "✅ Set (${anonKey.substring(0, 20)}...)" : "❌ Missing"}');
    print('   Auth Mode: RLS-based (user authentication required for sync)');
  }
}
