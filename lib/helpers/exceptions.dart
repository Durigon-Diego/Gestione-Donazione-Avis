/// Custom exception for login-related errors
class LoginException implements Exception {
  final String message;

  LoginException(this.message);

  @override
  String toString() => message;
}

/// Custom exception for login-related errors
class LoadException implements Exception {
  final String message;

  LoadException(this.message);

  @override
  String toString() => message;
}
