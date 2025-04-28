import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donor_app/helpers/exceptions.dart';

void main() {
  group('Custom Exceptions', () {
    test('LoginException stores and returns the correct message', () {
      const errorMessage = 'Invalid credentials';
      final exception = LoginException(errorMessage);

      expect(exception.message, errorMessage);
      expect(exception.toString(), errorMessage);
    });

    test('LoadException stores and returns the correct message', () {
      const errorMessage = 'Failed to load data';
      final exception = LoadException(errorMessage);

      expect(exception.message, errorMessage);
      expect(exception.toString(), errorMessage);
    });
  });
}
