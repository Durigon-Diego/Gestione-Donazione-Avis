import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart'
    as logger_helper;

void main() {
  group('LoggerHelper', () {
    late List<Map<String, dynamic>> capturedLogs;

    // Helper function to replace developer.log
    void fakeLog(
      String message, {
      DateTime? time,
      String name = '',
      int level = 0,
      Object? error,
      StackTrace? stackTrace,
    }) {
      capturedLogs.add({
        'message': message,
        'time': time,
        'name': name,
        'level': level,
        'error': error,
        'stackTrace': stackTrace,
      });
    }

    setUp(() {
      capturedLogs = [];
      logger_helper.logFunction = fakeLog;
    });

    test('logTrace logs with correct level and default name', () {
      logger_helper.logTrace('Trace message');

      expect(capturedLogs.length, 1);
      final log = capturedLogs.first;
      expect(log['message'], 'Trace message');
      expect(log['name'], 'trace');
      expect(log['level'], 500);
    });

    test('logInfo logs with correct level and default name', () {
      logger_helper.logInfo('Info message');

      expect(capturedLogs.length, 1);
      final log = capturedLogs.first;
      expect(log['message'], 'Info message');
      expect(log['name'], 'info');
      expect(log['level'], 800);
    });

    test('logWarning logs with correct level and default name', () {
      logger_helper.logWarning('Warning message');

      expect(capturedLogs.length, 1);
      final log = capturedLogs.first;
      expect(log['message'], 'Warning message');
      expect(log['name'], 'warning');
      expect(log['level'], 900);
    });

    test('logError logs with correct level, error, and optional stackTrace',
        () {
      final error = Exception('Something went wrong');
      final stackTrace = StackTrace.current;

      logger_helper.logError('Error message', error, stackTrace);

      expect(capturedLogs.length, 1);
      final log = capturedLogs.first;
      expect(log['message'], 'Error message');
      expect(log['name'], 'error');
      expect(log['level'], 1000);
      expect(log['error'], error);
      expect(log['stackTrace'], stackTrace);
    });

    test('logError logs correctly even without stackTrace', () {
      final error = Exception('Another error');

      logger_helper.logError('Another error message', error);

      expect(capturedLogs.length, 1);
      final log = capturedLogs.first;
      expect(log['message'], 'Another error message');
      expect(log['name'], 'error');
      expect(log['level'], 1000);
      expect(log['error'], error);
      expect(log['stackTrace'], isNull);
    });
  });
}
