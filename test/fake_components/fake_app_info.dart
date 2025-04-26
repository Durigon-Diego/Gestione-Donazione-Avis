import 'package:avis_donor_app/helpers/app_info_controller.dart';

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
}
