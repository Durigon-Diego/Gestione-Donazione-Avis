import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/pages/account_page.dart';
import 'package:avis_donation_management/pages/donation_days_page.dart';
import 'package:avis_donation_management/pages/donation_page.dart';
import 'package:avis_donation_management/pages/login_page.dart';
import 'package:avis_donation_management/pages/not_active_page.dart';
import 'package:avis_donation_management/pages/operators_page.dart';
import 'package:avis_donation_management/avis_donation_management_app.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

void main() {
  group('Builder default assignment', () {
    late MockSupabaseClient mockClient;
    late MockAuth mockAuth;
    late MockSession mockSession;
    late FakeAppInfo fakeAppInfo;
    late FakeConnectionStatus fakeConnectionStatus;
    late FakeOperatorSession fakeOperatorSession;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockAuth();
      mockSession = MockSession();
      fakeAppInfo = FakeAppInfo();
      fakeConnectionStatus =
          FakeConnectionStatus(state: ServerStatus.connected);
      fakeOperatorSession = FakeOperatorSession(onInit: () {
        Supabase.instance.client = mockClient;
        when(() => mockClient.auth).thenReturn(mockAuth);
        when(() => mockAuth.currentSession).thenReturn(mockSession);
      });
    });

    tearDown(() async {
      fakeConnectionStatus.dispose();
      fakeOperatorSession.dispose();
      try {
        await Supabase.instance.dispose();
      } catch (_) {}
    });

    Future<void> testDefaultPage({
      required WidgetTester tester,
      required String route,
      required Type expectedWidget,
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

      expect(find.byType(expectedWidget), findsOneWidget);

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(find.byType(expectedWidget), findsNothing);
    }

    testWidgets('default loginPageBuilder', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: null);
      await testDefaultPage(
          tester: tester, route: '/login', expectedWidget: LoginPage);
    });

    testWidgets('default notActivePageBuilder', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: '1', isActive: false);
      await testDefaultPage(
          tester: tester, route: '/not_active', expectedWidget: NotActivePage);
    });

    testWidgets('default donationPageBuilder', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: '1', isActive: true);
      await testDefaultPage(
          tester: tester, route: '/donation', expectedWidget: DonationPage);
    });

    testWidgets('default accountPageBuilder', (tester) async {
      fakeOperatorSession.setState(currentOperatorID: '1', isActive: true);
      await testDefaultPage(
          tester: tester, route: '/account', expectedWidget: AccountPage);
    });

    testWidgets('default operatorsPageBuilder', (tester) async {
      fakeOperatorSession.setState(
          currentOperatorID: '1', isActive: true, isAdmin: true);
      await testDefaultPage(
          tester: tester, route: '/operators', expectedWidget: OperatorsPage);
    });

    testWidgets('default donationDaysPageBuilder', (tester) async {
      fakeOperatorSession.setState(
          currentOperatorID: '1', isActive: true, isAdmin: true);
      await testDefaultPage(
          tester: tester,
          route: '/donations_days',
          expectedWidget: DonationDaysPage);
    });
  });
}
