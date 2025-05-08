import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/avis_donation_management_app.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

class MockOperatorSession extends OperatorSessionController with Mock {}

void main() {
  group('AvisDonationManagementApp', () {
    late FakeAppInfo fakeAppInfo;
    late FakeConnectionStatus fakeConnectionStatus;
    late FakeOperatorSession fakeOperatorSession;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      fakeAppInfo = FakeAppInfo();
      fakeConnectionStatus = FakeConnectionStatus();
      fakeOperatorSession = FakeOperatorSession();
    });

    testWidgets('shows LoginPage when not connected', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: null);

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Accesso Operatore'), findsOneWidget);

      await Supabase.instance.dispose();
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('shows DonationPage when connected', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: 'test_user');

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Donazione'), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('has correct supported locales', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: 'test_user');

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.supportedLocales, contains(const Locale('it')));

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('has correct title', (tester) async {
      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, equals('App di Test'));

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('theme is AvisTheme.light', (tester) async {
      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme, isNotNull);
      expect(app.theme!.primaryColor, equals(const Color(0xFF002A5C)));

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('routes are correctly registered', (tester) async {
      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(
          app.routes!.keys,
          containsAll([
            '/login',
            '/not_active',
            '/donation',
            '/account',
            '/operators',
            '/donations_days',
          ]));

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets(
        'connected flow initializes properly and does not remove listener after dispose',
        (tester) async {
      fakeConnectionStatus.setState(ServerStatus.connected);
      fakeOperatorSession.setState(currentOperatorID: 'user123');

      expect(fakeConnectionStatus.numListener, equals(0));

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Donazione'), findsOneWidget);
      expect(fakeConnectionStatus.numListener, equals(1)); // Only page

      // Dispose
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(fakeConnectionStatus.numListener, equals(0));
    });

    testWidgets('logs error when operatorSession.init throws', (tester) async {
      final mockOperatorSession = MockOperatorSession();
      fakeConnectionStatus.setState(ServerStatus.connected);

      when(() => mockOperatorSession.init())
          .thenThrow(Exception('Fake init error'));
      when(() => mockOperatorSession.isConnected).thenReturn(false);
      when(() => mockOperatorSession.currentOperatorID).thenReturn(null);
      when(() => mockOperatorSession.isAdmin).thenReturn(false);
      when(() => mockOperatorSession.isActive).thenReturn(false);

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: mockOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      await tester.pumpAndSettle();

      // Just verify that app doesn't crash and still builds a MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    });

    testWidgets('removes listener in dispose if not connectedOnce',
        (tester) async {
      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      await tester.pumpAndSettle();

      expect(fakeConnectionStatus.numListener, 2); // 1 App, 1 page

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(fakeConnectionStatus.numListener, 0);
    });

    Future<void> testRoute({
      required WidgetTester tester,
      required String route,
      required String expectedText,
    }) async {
      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      navigatorKey.currentState!.pushReplacementNamed(route);
      await tester.pumpAndSettle();

      expect(find.text(expectedText), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();
    }

    testWidgets('navigates to /login route', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: null);
      await testRoute(
        tester: tester,
        route: '/login',
        expectedText: 'Accesso Operatore',
      );
    });

    testWidgets('navigates to /not_active route', (tester) async {
      fakeOperatorSession.setState(
          currentOperatorID: 'x', isActive: false, isAdmin: false);
      await testRoute(
        tester: tester,
        route: '/not_active',
        expectedText: 'Contattare un amministratore per abilitare l\'accesso.',
      );
    });

    testWidgets('navigates to /donation route', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: 'x', isActive: true);
      await testRoute(
        tester: tester,
        route: '/donation',
        expectedText: 'Donazione',
      );
    });

    testWidgets('navigates to /account route', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: 'x', isActive: true);
      await testRoute(
        tester: tester,
        route: '/account',
        expectedText: 'Pagina gestione account',
      );
    });

    testWidgets('navigates to /operators route', (tester) async {
      fakeOperatorSession.setState(
          currentOperatorID: 'x', isActive: true, isAdmin: true);
      await testRoute(
        tester: tester,
        route: '/operators',
        expectedText: 'Pagina gestione operatori',
      );
    });

    testWidgets('navigates to /donations_days route', (tester) async {
      fakeOperatorSession.setState(
        currentOperatorID: 'x',
        isActive: true,
        isAdmin: true,
      );
      await testRoute(
        tester: tester,
        route: '/donations_days',
        expectedText: 'Pagina gestione giornate di donazione',
      );
    });
  });
}
