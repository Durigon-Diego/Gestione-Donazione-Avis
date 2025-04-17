import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'exceptions.dart';
import 'logger_helper.dart';

/// Centralized access to app metadata
class AppInfo {
  static final AppInfo _instance = AppInfo._internal();

  late final String appName;
  late final String appVersion;
  late final String appDescription;
  late final String supportEmail;
  late final String supabaseUrl;
  late final String supabaseKey;

  AppInfo._internal();

  /// Singleton instance
  factory AppInfo() => _instance;

  /// Initialize app information
  Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    await dotenv.load(fileName: ".env");

    appName = dotenv.env['APP_NAME_OVERRIDE'] ?? info.appName;
    appVersion = info.version;
    logInfo('Application $appName v $appVersion');

    String? appDescriptionVal = dotenv.env['APP_DESCRIPTION'];
    if (appDescriptionVal == null) {
      throw LoadException('Missing APP_DESCRIPTION value on ".env".');
    }
    appDescription = appDescriptionVal;
    logInfo('Application description: "$appDescription"');

    String? supportEmailVal = dotenv.env['SUPPORT_EMAIL'];
    if (supportEmailVal == null) {
      throw LoadException('Missing SUPPORT_EMAIL value on ".env".');
    }
    supportEmail = supportEmailVal;
    logInfo('Support email: $supportEmail');

    String? supabaseUrlVal = dotenv.env['SUPABASE_URL'];
    String? supabaseKeyVal = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrlVal == null || supabaseKeyVal == null) {
      throw LoadException(
          'Missing SUPABASE_URL or SUPABASE_ANON_KEY values on ".env".');
    }
    supabaseUrl = supabaseUrlVal;
    supabaseKey = supabaseKeyVal;
    logInfo('SUPABASE_URL: $supabaseUrl');
    logInfo('SUPABASE_ANON_KEY: ${supabaseKey.substring(0, 8)}...');
  }
}

/// Global access to AppInfo
final appInfo = AppInfo();
