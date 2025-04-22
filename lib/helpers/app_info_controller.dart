/// Interface for accessing application information
abstract class AppInfoController {
  String get appName;
  String get appVersion;
  String get appDescription;
  String get supportEmail;
  String get supabaseUrl;
  String get supabaseKey;
}
