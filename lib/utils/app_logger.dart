// lib/utils/app_logger.dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized app logger for consistent logging across the application.
/// Only logs in debug mode to prevent sensitive information leaking in production.
class AppLogger {
  AppLogger._();

  // 👇 Add this — set to true to only show websocket logs
  static const bool _websocketDebugOnly = false;

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

  static void debug(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.d(message);
    }
  }

  static void info(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.i(message);
    }
  }

  static void warning(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.w(message);
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  static void sync(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.i('🔄 $message');
    }
  }

  static void connectivity(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.i('📡 $message');
    }
  }

  static void database(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.i('🗄️ $message');
    }
  }

  static void auth(String message) {
    if (kDebugMode && !_websocketDebugOnly) {
      _logger.i('🔐 $message');
    }
  }

  // 👇 This one always shows regardless of the filter
  static void websocket(String message) {
    if (kDebugMode) {
      _logger.i('🔌 $message');
    }
  }
}
