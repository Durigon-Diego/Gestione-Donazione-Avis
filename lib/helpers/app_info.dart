import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';
import 'package:avis_donation_management/helpers/exceptions.dart';
import 'package:avis_donation_management/helpers/app_info_controller.dart';

/// Real implementation of AppInfoController for production
class AppInfo implements AppInfoController {
  @override
  late final String appName;

  @override
  late final String appVersion;

  @override
  late final String appDescription;

  @override
  late final String supportEmail;

  @override
  late final String supabaseURL;

  @override
  late final String supabaseKey;

  /// Loads metadata from package_info and dotenv
  @override
  Future<void> load({String envFileName = '.env'}) async {
    final info = await PackageInfo.fromPlatform();
    await dotenv.load(fileName: envFileName);

    appName = dotenv.env['APP_NAME_OVERRIDE'] ?? info.appName;
    appVersion = info.version;
    logInfo('Application $appName v $appVersion');

    String? appDescriptionVal = dotenv.env['APP_DESCRIPTION'];
    if (appDescriptionVal == null) {
      throw LoadException('Missing APP_DESCRIPTION value on "$envFileName".');
    }
    appDescription = appDescriptionVal;
    logInfo('Application description: "$appDescription"');

    String? supportEmailVal = dotenv.env['SUPPORT_EMAIL'];
    if (supportEmailVal == null) {
      throw LoadException('Missing SUPPORT_EMAIL value on "$envFileName".');
    }
    supportEmail = supportEmailVal;
    logInfo('Support email: $supportEmail');

    String? supabaseUrlVal = dotenv.env['SUPABASE_URL'];
    String? supabaseKeyVal = dotenv.env['SUPABASE_ANON_KEY'];
    if (supabaseUrlVal == null || supabaseKeyVal == null) {
      throw LoadException(
        'Missing SUPABASE_URL or SUPABASE_ANON_KEY values on "$envFileName".',
      );
    }
    supabaseURL = supabaseUrlVal;
    supabaseKey = supabaseKeyVal;
    logInfo('SUPABASE_URL: $supabaseURL');
    logInfo('SUPABASE_ANON_KEY: ${supabaseKey.substring(0, 8)}...');
  }
}
