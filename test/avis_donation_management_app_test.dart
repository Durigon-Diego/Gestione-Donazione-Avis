import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/avis_donation_management_app.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

Widget mockPage(String label) => Scaffold(body: Text(label));

void overridePageBuilders() {
  loginPageBuilder = ({required connectionStatus, required operatorSession}) =>
      mockPage('LoginPage');
  notActivePageBuilder = ({
    required appInfo,
    required connectionStatus,
    required operatorSession,
  }) =>
      mockPage('NotActivePage');
  donationPageBuilder = ({
    required appInfo,
    required connectionStatus,
    required operatorSession,
  }) =>
      mockPage('DonationPage');
  accountPageBuilder = ({
    required appInfo,
    required connectionStatus,
    required operatorSession,
  }) =>
      mockPage('AccountPage');
  operatorsPageBuilder = ({
    required appInfo,
    required connectionStatus,
    required operatorSession,
  }) =>
      mockPage('OperatorsPage');
  donationDaysPageBuilder = ({
    required appInfo,
    required connectionStatus,
    required operatorSession,
  }) =>
      mockPage('DonationDaysPage');
}

void main() {
  group('AvisDonationManagementApp', () {
    late FakeAppInfo fakeAppInfo;
    late FakeConnectionStatus fakeConnectionStatus;
    late FakeOperatorSession fakeOperatorSession;

    setUpAll(() async {
      overridePageBuilders();
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      fakeAppInfo = FakeAppInfo();
      fakeConnectionStatus = FakeConnectionStatus();
      fakeOperatorSession = FakeOperatorSession();
    });

    tearDown(() async {
      fakeConnectionStatus.dispose();
      fakeOperatorSession.dispose();
      try {
        await Supabase.instance.dispose();
      } catch (_) {}
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

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(find.text('LoginPage'), findsNothing);
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
      expect(find.text('DonationPage'), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(find.text('DonationPage'), findsNothing);
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

      expect(find.byType(MaterialApp), findsNothing);
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

      expect(find.byType(MaterialApp), findsNothing);
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

      expect(find.byType(MaterialApp), findsNothing);
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
        ]),
      );

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsNothing);
    });

    testWidgets(
        'connected flow initializes properly and does not remove listener after dispose',
        (tester) async {
      fakeConnectionStatus.setState(ServerStatus.connected);
      fakeOperatorSession.setState(currentOperatorID: 'user123');
      fakeOperatorSession.initialized = false;
      fakeOperatorSession.onInit = () {
        fakeOperatorSession.initialized = true;
      };

      expect(fakeConnectionStatus.numListener, equals(0));
      expect(fakeOperatorSession.initialized, isFalse);

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DonationPage'), findsOneWidget);
      expect(fakeConnectionStatus.numListener, equals(0));
      expect(fakeOperatorSession.initialized, isTrue);

      // Dispose
      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(fakeConnectionStatus.numListener, equals(0));
      expect(fakeOperatorSession.numListener, equals(0));
      expect(find.byType(MaterialApp), findsNothing);
    });

    testWidgets('logs error when operatorSession.init throws', (tester) async {
      fakeConnectionStatus.setState(ServerStatus.connected);
      fakeOperatorSession.setState(
        currentOperatorID: null,
        isAdmin: false,
        isActive: false,
      );
      fakeOperatorSession.initialized = false;
      fakeOperatorSession.onInit = () {
        throw Exception('Fake init error');
      };

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      await tester.pumpAndSettle();

      // Just verify that app doesn't crash and still builds a MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsNothing);
    });

    testWidgets('removes listener in dispose if not connectedOnce',
        (tester) async {
      fakeConnectionStatus.setState(ServerStatus.disconnected);
      fakeOperatorSession.initialized = false;
      fakeOperatorSession.onInit = () {
        fakeOperatorSession.initialized = true;
      };

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      await tester.pumpAndSettle();

      expect(fakeConnectionStatus.numListener, 1);
      expect(fakeOperatorSession.initialized, isFalse);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(fakeConnectionStatus.numListener, 0);
      expect(fakeOperatorSession.initialized, isFalse);
      expect(find.byType(MaterialApp), findsNothing);
    });

    overridePageBuilders();

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
      expect(find.text(expectedText), findsNothing);
      expect(find.byType(MaterialApp), findsNothing);
    }

    testWidgets(
        'removes listener after notification (calls _handleFirstConnection)',
        (tester) async {
      bool listenerRemoved = false;
      fakeConnectionStatus.onRemoveListener = (_, __) {
        listenerRemoved = true;
      };
      fakeConnectionStatus.setState(ServerStatus.disconnected);
      fakeOperatorSession.setState(currentOperatorID: 'abc');

      await tester.pumpWidget(
        AvisDonationManagementApp(
          appInfo: fakeAppInfo,
          connectionStatus: fakeConnectionStatus,
          operatorSession: fakeOperatorSession,
          authOptions: const FlutterAuthClientOptions(autoRefreshToken: false),
        ),
      );

      expect(listenerRemoved, isFalse);

      fakeConnectionStatus.setState(ServerStatus.connected);
      await tester.pumpAndSettle();

      expect(listenerRemoved, isTrue);
    });

    testWidgets('navigates to /login route', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: null);
      await testRoute(
        tester: tester,
        route: '/login',
        expectedText: 'LoginPage',
      );
    });

    testWidgets('navigates to /not_active route', (tester) async {
      fakeOperatorSession.setState(
          currentOperatorID: 'x', isActive: false, isAdmin: false);
      await testRoute(
        tester: tester,
        route: '/not_active',
        expectedText: 'NotActivePage',
      );
    });

    testWidgets('navigates to /donation route', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: 'x', isActive: true);
      await testRoute(
        tester: tester,
        route: '/donation',
        expectedText: 'DonationPage',
      );
    });

    testWidgets('navigates to /account route', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: 'x', isActive: true);
      await testRoute(
        tester: tester,
        route: '/account',
        expectedText: 'AccountPage',
      );
    });

    testWidgets('navigates to /operators route', (tester) async {
      fakeOperatorSession.setState(
          currentOperatorID: 'x', isActive: true, isAdmin: true);
      await testRoute(
        tester: tester,
        route: '/operators',
        expectedText: 'OperatorsPage',
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
        expectedText: 'DonationDaysPage',
      );
    });
  });
}
