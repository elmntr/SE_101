// lib/utils/app_logger.dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized app logger for consistent logging across the application.
/// Only logs in debug mode to prevent sensitive information leaking in production.
class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.debug : Level.off,
  );

  /// Log debug information
  static void debug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  /// Log info messages
  static void info(String message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  /// Log warning messages
  static void warning(String message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  /// Log error messages
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log sync-related messages with sync emoji
  static void sync(String message) {
    if (kDebugMode) {
      _logger.i('🔄 $message');
    }
  }

  /// Log connectivity-related messages
  static void connectivity(String message) {
    if (kDebugMode) {
      _logger.i('📡 $message');
    }
  }

  /// Log database-related messages
  static void database(String message) {
    if (kDebugMode) {
      _logger.i('🗄️ $message');
    }
  }

  /// Log auth-related messages
  static void auth(String message) {
    if (kDebugMode) {
      _logger.i('🔐 $message');
    }
  }
}
