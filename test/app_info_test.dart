import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:avis_donation_management/helpers/app_info.dart';
import 'package:avis_donation_management/helpers/exceptions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppInfo', () {
    late AppInfo appInfo;
    const String testEnvAsset = 'assets/.env.test';

    setUp(() async {
      appInfo = AppInfo();
    });

    tearDown(() async {
      rootBundle.clear();
    });

    test('throws LoadException if APP_DESCRIPTION is missing', () async {
      const fakeEnv = '''
SUPPORT_EMAIL=test@example.com
SUPABASE_URL=https://fake.supabase.co
SUPABASE_ANON_KEY=fake-key
''';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (_) async =>
            ByteData.view(Uint8List.fromList(utf8.encode(fakeEnv)).buffer),
      );

      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      expect(
        () => appInfo.load(envFileName: testEnvAsset),
        throwsA(isA<LoadException>().having(
          (e) => e.message,
          'message',
          contains('APP_DESCRIPTION'),
        )),
      );
    });

    test('throws LoadException if SUPPORT_EMAIL is missing', () async {
      const fakeEnv = '''
APP_DESCRIPTION=Descrizione
SUPABASE_URL=https://fake.supabase.co
SUPABASE_ANON_KEY=fake-key
''';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (_) async =>
            ByteData.view(Uint8List.fromList(utf8.encode(fakeEnv)).buffer),
      );

      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      expect(
        () => appInfo.load(envFileName: testEnvAsset),
        throwsA(isA<LoadException>().having(
          (e) => e.message,
          'message',
          contains('SUPPORT_EMAIL'),
        )),
      );
    });

    test('throws LoadException if SUPABASE_URL or SUPABASE_ANON_KEY is missing',
        () async {
      const fakeEnv = '''
APP_DESCRIPTION=Descrizione
SUPPORT_EMAIL=test@example.com
''';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (_) async =>
            ByteData.view(Uint8List.fromList(utf8.encode(fakeEnv)).buffer),
      );

      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.example.test',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      expect(
        () => appInfo.load(envFileName: testEnvAsset),
        throwsA(isA<LoadException>().having(
          (e) => e.message,
          'message',
          contains('SUPABASE_URL'),
        )),
      );
    });

    test('loads all values correctly', () async {
      const fakeEnv = '''
APP_DESCRIPTION=Descrizione App
SUPPORT_EMAIL=support@example.com
SUPABASE_URL=https://fake.supabase.co
SUPABASE_ANON_KEY=fake-key
''';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (_) async =>
            ByteData.view(Uint8List.fromList(utf8.encode(fakeEnv)).buffer),
      );

      PackageInfo.setMockInitialValues(
        appName: 'App Name',
        packageName: 'com.test',
        version: '1.2.3',
        buildNumber: '1',
        buildSignature: '',
      );

      await appInfo.load(envFileName: testEnvAsset);

      expect(appInfo.appName, 'App Name');
      expect(appInfo.appVersion, '1.2.3');
      expect(appInfo.appDescription, 'Descrizione App');
      expect(appInfo.supportEmail, 'support@example.com');
      expect(appInfo.supabaseURL, 'https://fake.supabase.co');
      expect(appInfo.supabaseKey, 'fake-key');
    });
  });
}
