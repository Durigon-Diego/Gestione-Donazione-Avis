import 'dart:developer' as developer;

/// Logging levels (same as dart:developer conventions)
const int _levelInfo = 800;
const int _levelWarning = 900;
const int _levelError = 1000;

/// Logs an informational message
void logInfo(String message, {String name = 'info'}) {
  developer.log(message, name: name, level: _levelInfo);
}

/// Logs a warning message
void logWarning(String message, {String name = 'warning'}) {
  developer.log(message, name: name, level: _levelWarning);
}

/// Logs an error with optional stack trace
void logError(String message, Object error,
    [StackTrace? stackTrace, String name = 'error']) {
  developer.log(message,
      name: name, error: error, stackTrace: stackTrace, level: _levelError);
}
