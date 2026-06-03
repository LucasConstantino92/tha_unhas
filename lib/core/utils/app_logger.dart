import 'dart:developer' as developer;

class AppLogger {
  static void info(String message, [String? tag]) {
    _log('\x1B[34m[INFO]\x1B[0m', message, tag);
  }

  static void success(String message, [String? tag]) {
    _log('\x1B[32m[SUCCESS]\x1B[0m', message, tag);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    final errorDetail = error != null ? ' | Error: $error' : '';
    _log('\x1B[31m[ERROR]\x1B[0m', '$message$errorDetail', tag, error, stackTrace);
  }

  static void _log(String prefix, String message, String? tag, [Object? error, StackTrace? stackTrace]) {
    final tagString = tag != null ? '[$tag] ' : '';
    developer.log(
      '$prefix $tagString$message',
      name: 'ThaUnhas',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
