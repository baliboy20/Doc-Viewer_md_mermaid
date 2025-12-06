import 'package:flutter/foundation.dart';

/// Centralized logging service for the application
/// Provides structured logging with different severity levels
class AppLogger {
  // ANSI color codes for console output
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _green = '\x1B[32m';
  static const String _gray = '\x1B[90m';

  /// Logs a debug message (gray)
  /// Use for detailed debugging information
  static void debug(String message, {String? tag, Object? data}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final dataString = data != null ? '\n  Data: $data' : '';
      print('$_gray[DEBUG] $tagPrefix$message$dataString$_reset');
    }
  }

  /// Logs an info message (blue)
  /// Use for general informational messages
  static void info(String message, {String? tag, Object? data}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final dataString = data != null ? '\n  Data: $data' : '';
      print('$_blue[INFO] $tagPrefix$message$dataString$_reset');
    }
  }

  /// Logs a success message (green)
  /// Use for successful operations
  static void success(String message, {String? tag, Object? data}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final dataString = data != null ? '\n  Data: $data' : '';
      print('$_green[SUCCESS] $tagPrefix$message$dataString$_reset');
    }
  }

  /// Logs a warning message (yellow)
  /// Use for potentially problematic situations
  static void warning(String message, {String? tag, Object? data}) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final dataString = data != null ? '\n  Data: $data' : '';
      print('$_yellow[WARNING] $tagPrefix$message$dataString$_reset');
    }
  }

  /// Logs an error message (red)
  /// Use for error conditions
  static void error(
    String message, {
    String? tag,
    Object? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final tagPrefix = tag != null ? '[$tag] ' : '';
      final dataString = data != null ? '\n  Data: $data' : '';
      final errorString = error != null ? '\n  Error: $error' : '';
      final stackString = stackTrace != null ? '\n  Stack: $stackTrace' : '';
      print('$_red[ERROR] $tagPrefix$message$dataString$errorString$stackString$_reset');
    }
  }

  /// Logs a section divider for better readability
  static void divider({String? label}) {
    if (kDebugMode) {
      if (label != null) {
        print('$_gray${'=' * 20} $label ${'=' * 20}$_reset');
      } else {
        print('$_gray${'=' * 60}$_reset');
      }
    }
  }
}
