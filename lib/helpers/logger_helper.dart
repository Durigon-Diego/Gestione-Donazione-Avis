import 'dart:developer' as developer;

/// Logging delegate type
typedef LogFunction = void Function(
  String message, {
  DateTime? time,
  String name,
  int level,
  Object? error,
  StackTrace? stackTrace,
});

/// Delegate that actually does the logging
LogFunction logFunction = developer.log;

/// Logging levels (same as dart:developer conventions)
const int _levelTrace = 500;
const int _levelInfo = 800;
const int _levelWarning = 900;
const int _levelError = 1000;

/// Logs an trace message
void logTrace(String message, {String name = 'trace'}) {
  logFunction(
    message,
    time: DateTime.now(),
    name: name,
    level: _levelTrace,
  );
}

/// Logs an informational message
void logInfo(String message, {String name = 'info'}) {
  logFunction(
    message,
    time: DateTime.now(),
    name: name,
    level: _levelInfo,
  );
}

/// Logs a warning message
void logWarning(String message, {String name = 'warning'}) {
  logFunction(
    message,
    time: DateTime.now(),
    name: name,
    level: _levelWarning,
  );
}

/// Logs an error with optional stack trace
void logError(String message, Object error,
    [StackTrace? stackTrace, String name = 'error']) {
  logFunction(
    message,
    time: DateTime.now(),
    name: name,
    error: error,
    stackTrace: stackTrace,
    level: _levelError,
  );
}
