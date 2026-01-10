// lib/config/supabase_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Validate that credentials are loaded
  static bool get isValid => url.isNotEmpty && anonKey.isNotEmpty;

  /// Debug method to check configuration status (only logs in debug mode)
  static void printConfigStatus() {
    if (kDebugMode) {
      AppLogger.info('🔧 Supabase Configuration Status:');
      AppLogger.info('   URL: ${url.isNotEmpty ? "✅ Set" : "❌ Missing"}');
      AppLogger.info('   Anon Key: ${anonKey.isNotEmpty ? "✅ Set" : "❌ Missing"}');
      AppLogger.info('   Auth Mode: RLS-based (user authentication required for sync)');
    }
  }
}
