import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/components/avis_theme.dart';
import 'package:avis_donation_management/pages/login_page.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class FakeRoute extends Fake implements Route<dynamic> {}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginPage', () {
    late MockSupabaseClient mockClient;
    late MockAuth mockAuth;
    late MockSession mockSession;
    late MockUser mockUser;
    late FakeConnectionStatus fakeConnectionStatus;

    setUpAll(() async {
      registerFallbackValue(FakeRoute());
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: 'http://localhost:54321',
        anonKey: 'test_anon_key',
      );
    });

    setUp(() {
      fakeConnectionStatus = FakeConnectionStatus();
      mockClient = MockSupabaseClient();
      mockAuth = MockAuth();
      mockSession = MockSession();
      mockUser = MockUser();

      Supabase.instance.client = mockClient;
    });

    Future<void> pumpLoginPage(WidgetTester tester, FakeOperatorSession session,
        {bool settle = true}) async {
      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(
                connectionStatus: fakeConnectionStatus,
                operatorSession: session,
              ),
          '/donation': (_) => const Scaffold(body: Text('Donazione')),
          '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
        },
      ));
      settle ? await tester.pumpAndSettle() : await tester.pump();
    }

    Future<void> mockSuccessfulLogin(FakeOperatorSession session,
        {required bool active}) async {
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
        session.setState(currentOperatorID: '123', isActive: active);
        when(() => mockUser.id).thenReturn('123');
        when(() => mockAuth.currentSession).thenReturn(mockSession);
        return AuthResponse(session: mockSession, user: mockUser);
      });
    }

    testWidgets('renders login page with Accedi button', (tester) async {
      final session = FakeOperatorSession();
      await pumpLoginPage(tester, session);
      expect(find.text('Accedi'), findsOneWidget);
    });

    testWidgets('successful login redirects to /donation if active',
        (tester) async {
      final session = FakeOperatorSession();
      await mockSuccessfulLogin(session, active: true);
      await pumpLoginPage(tester, session);

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Donazione'), findsOneWidget);
    });

    testWidgets('successful login redirects to /not_active if not active',
        (tester) async {
      final session = FakeOperatorSession();
      await mockSuccessfulLogin(session, active: false);
      await pumpLoginPage(tester, session);

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Non Attivo'), findsOneWidget);
    });

    testWidgets('login shows credential error (400)', (tester) async {
      final session = FakeOperatorSession();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const AuthException('Invalid', statusCode: '400'));

      await pumpLoginPage(tester, session);
      await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Credenziali errate. Riprova.'), findsOneWidget);
    });

    testWidgets('login shows too many attempts error (429)', (tester) async {
      final session = FakeOperatorSession();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.signInWithPassword(
                email: any(named: 'email'),
                password: any(named: 'password'),
              ))
          .thenThrow(
              const AuthException('Too many attempts', statusCode: '429'));

      await pumpLoginPage(tester, session);
      await tester.enterText(find.byType(TextField).at(0), 'spam@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'spam');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Troppi tentativi. Riprova tra qualche minuto.'),
          findsOneWidget);
    });

    testWidgets('login shows generic error for unknown exceptions',
        (tester) async {
      final session = FakeOperatorSession();
      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('Unknown error'));

      await pumpLoginPage(tester, session);
      await tester.enterText(find.byType(TextField).at(0), 'oops@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'oops');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(
          find.text(
              'Errore di autenticazione sconosciuto. Contatta un amministratore.'),
          findsOneWidget);
    });

    testWidgets('loads last saved email on startup', (tester) async {
      SharedPreferences.setMockInitialValues({'last_email': 'saved@email.com'});
      final session = FakeOperatorSession();
      await pumpLoginPage(tester, session);

      expect(find.widgetWithText(TextField, 'saved@email.com'), findsOneWidget);
    });

    testWidgets('user already connected redirects to donation if active',
        (tester) async {
      final session = FakeOperatorSession();
      session.setState(currentOperatorID: 'abc', isActive: true);
      await pumpLoginPage(tester, session);

      expect(find.text('Donazione'), findsOneWidget);
    });

    testWidgets('user already connected redirects to not_active if not active',
        (tester) async {
      final session = FakeOperatorSession();
      session.setState(currentOperatorID: 'abc', isActive: false);
      await pumpLoginPage(tester, session);

      expect(find.text('Non Attivo'), findsOneWidget);
    });

    testWidgets('login fails if user id is null after auth', (tester) async {
      final session = FakeOperatorSession();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => AuthResponse(session: null, user: null));

      await pumpLoginPage(tester, session);
      await tester.enterText(find.byType(TextField).at(0), 'null@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.tap(find.text('Accedi'));
      await tester.pumpAndSettle();

      expect(find.text('Autenticazione fallita.'), findsOneWidget);
    });

    testWidgets('login by pressing enter on email field', (tester) async {
      final session = FakeOperatorSession();
      await mockSuccessfulLogin(session, active: true);
      await pumpLoginPage(tester, session);

      await tester.enterText(find.byType(TextField).at(0), 'email@example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Donazione'), findsOneWidget);
    });

    testWidgets('login by pressing enter on password field', (tester) async {
      final session = FakeOperatorSession();
      await mockSuccessfulLogin(session, active: true);
      await pumpLoginPage(tester, session);

      await tester.enterText(find.byType(TextField).at(1), 'password123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Donazione'), findsOneWidget);
    });

    testWidgets('all elements change enabled state with connection status',
        (tester) async {
      final session = FakeOperatorSession();
      fakeConnectionStatus.setState(ServerStatus.disconnected);

      await pumpLoginPage(tester, session, settle: false);

      Future<void> verifyState({
        required bool enabled,
        required Color expectedColor,
        required String expectedText,
      }) async {
        final emailField =
            tester.widget<TextField>(find.byType(TextField).at(0));
        final passwordField =
            tester.widget<TextField>(find.byType(TextField).at(1));
        final accediButton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final icon = tester.widget<Icon>(find.byType(Icon).first);
        final textWidget = tester.widget<Text>(
          find
              .descendant(
                of: find.byType(Row),
                matching: find.byType(Text),
              )
              .last,
        );

        expect(emailField.enabled, enabled);
        expect(passwordField.enabled, enabled);
        if (enabled) {
          expect(accediButton.onPressed, isNotNull);
        } else {
          expect(accediButton.onPressed, isNull);
        }

        expect(icon.color, expectedColor);
        expect(textWidget.data, expectedText);
        expect(textWidget.style?.color, expectedColor);
      }

      // Disconnected: fields disabled, red icon, "Nessuna connessione"
      await verifyState(
        enabled: false,
        expectedColor: AvisColors.red,
        expectedText: 'Nessuna connessione',
      );

      // Change to supabaseOffline
      fakeConnectionStatus.setState(ServerStatus.supabaseOffline);
      await tester.pump();
      await verifyState(
        enabled: false,
        expectedColor: AvisColors.amber,
        expectedText: 'Server non raggiungibile',
      );

      // Change to connected
      fakeConnectionStatus.setState(ServerStatus.connected);
      await tester.pump();
      await verifyState(
        enabled: true,
        expectedColor: AvisColors.green,
        expectedText: 'Connesso',
      );

      // Return to disconnected
      fakeConnectionStatus.setState(ServerStatus.disconnected);
      await tester.pump();
      await verifyState(
        enabled: false,
        expectedColor: AvisColors.red,
        expectedText: 'Nessuna connessione',
      );
    });
  });
}
