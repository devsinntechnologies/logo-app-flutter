import 'package:flutter/foundation.dart';
import 'package:logo_app_flutter/config/environment.dart';

/// Production-safe logging utility
/// Only logs in debug mode or when DEBUG_LOGS is enabled
class AppLogger {
  /// Log general information
  static void log(String message, {String? tag}) {
    if (Environment.enableDebugLogs || kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Log errors (always logged, even in production)
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final prefix = tag != null ? '[$tag] ' : '';
    debugPrint('❌ $prefix$message');
    if (error != null) {
      debugPrint('Error: $error');
    }
    if (stackTrace != null && (Environment.enableDebugLogs || kDebugMode)) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Log success messages
  static void success(String message, {String? tag}) {
    if (Environment.enableDebugLogs || kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('✅ $prefix$message');
    }
  }

  /// Log warnings
  static void warning(String message, {String? tag}) {
    if (Environment.enableDebugLogs || kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️  $prefix$message');
    }
  }

  /// Log API calls
  static void api(String method, String endpoint, {Map<String, dynamic>? data}) {
    if (Environment.enableDebugLogs || kDebugMode) {
      debugPrint('🌐 API $method: $endpoint');
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  /// Log canvas operations
  static void canvas(String message) {
    if (Environment.enableDebugLogs || kDebugMode) {
      debugPrint('🎨 Canvas: $message');
    }
  }

  /// Log auth operations
  static void auth(String message) {
    if (Environment.enableDebugLogs || kDebugMode) {
      debugPrint('🔐 Auth: $message');
    }
  }

  /// Log storage operations
  static void storage(String message) {
    if (Environment.enableDebugLogs || kDebugMode) {
      debugPrint('💾 Storage: $message');
    }
  }
}
