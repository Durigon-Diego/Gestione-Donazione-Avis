import 'package:avis_donation_management/helpers/app_info_controller.dart';

/// Fake implementation of AppInfo for tests
class FakeAppInfo extends AppInfoController {
  @override
  String appName = 'App di Test';

  @override
  String appVersion = '0.0.1';

  @override
  String appDescription = 'Descrizione di test';

  @override
  String supportEmail = 'supporto@test.com';

  @override
  String supabaseURL = 'https://fake.supabase.co';

  @override
  String supabaseKey = 'fake-key';

  Future<void> Function(String) loadCallback = (_) async {};

  @override
  Future<void> load({String envFileName = '.env'}) async {
    await loadCallback.call(envFileName);
  }
}
