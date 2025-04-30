import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/main.dart' as main_entry;
import 'package:avis_donation_management/avis_donation_management_app.dart';

import 'fake_components/fake_app_info.dart';

void main() {
  group('main()', () {
    late FakeAppInfo fakeAppInfo;
    late Widget? capturedApp;

    setUp(() {
      fakeAppInfo = FakeAppInfo();
      capturedApp = null;
      main_entry.runAppFunction = (Widget app) {
        capturedApp = app;
      };
    });

    test('runApp receives AvisDonationManagementApp if load succeeds',
        () async {
      bool loadCalled = false;
      fakeAppInfo.loadCallback = (_) async {
        loadCalled = true;
      };

      await main_entry.main(customAppInfo: fakeAppInfo);

      expect(loadCalled, isTrue);
      expect(capturedApp, isA<AvisDonationManagementApp>());

      final appWidget = capturedApp as AvisDonationManagementApp;
      expect(appWidget.appInfo.appName, equals('App di Test'));
    });

    test('runApp receives ErrorApp if load throws', () async {
      fakeAppInfo.loadCallback = (_) async {
        throw Exception('env error');
      };

      await main_entry.main(customAppInfo: fakeAppInfo);

      expect(capturedApp, isA<main_entry.ErrorApp>());
      final errorApp = capturedApp as main_entry.ErrorApp;
      expect(errorApp.error, 'Errore di inizializzazione');
    });

    test('runApp uses AppInfo() when no customAppInfo is provided', () async {
      Widget? captured;

      main_entry.runAppFunction = (Widget widget) {
        captured = widget;
      };

      await main_entry.main(); // <-- Nessun customAppInfo

      expect(captured, isNotNull);
    });

    test('runApp receives ErrorApp if AvisDonationManagementApp throws',
        () async {
      fakeAppInfo.loadCallback = (_) async {};
      main_entry.runAppFunction = (Widget app) {
        if (app is AvisDonationManagementApp) throw Exception('boom');
        capturedApp = app;
      };

      await main_entry.main(customAppInfo: fakeAppInfo);

      expect(capturedApp, isA<main_entry.ErrorApp>());
      final errorApp = capturedApp as main_entry.ErrorApp;
      expect(errorApp.error, 'Errore di avvio');
    });
  });

  group('ErrorApp', () {
    testWidgets('renders MaterialApp with error message and title',
        (tester) async {
      const fakeError = 'Errore test rendering';
      final fakeAppInfo = FakeAppInfo();

      await tester.pumpWidget(
        main_entry.ErrorApp(
          error: fakeError,
          appInfo: fakeAppInfo,
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.textContaining(fakeError), findsOneWidget);
      expect(find.textContaining('Errore durante l\'inizializzazione'),
          findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('App di Test - Errore'));
    });
  });
}
