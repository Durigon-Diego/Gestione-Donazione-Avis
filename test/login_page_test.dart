import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donor_app/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fake_components/fake_operator_session.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuth extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

class FakeAuthException extends Fake implements AuthException {
  @override
  final String message;
  @override
  final String statusCode;
  FakeAuthException(this.message, this.statusCode);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences before Supabase init
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    registerFallbackValue(FakeRoute());
    // Minimal Supabase init to avoid crash in tests
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test_anon_key',
    );
  });

  late MockSupabaseClient mockClient;
  late MockAuth mockAuth;
  late MockSession mockSession;
  late MockUser mockUser;

  setUp(() {
    registerFallbackValue(FakeAuthException('Fallback', '400'));
    mockClient = MockSupabaseClient();
    mockAuth = MockAuth();
    mockSession = MockSession();
    mockUser = MockUser();

    Supabase.instance.client = mockClient;
  });

  testWidgets('renders LoginPage and finds Accedi button', (tester) async {
    final fakeSession = FakeOperatorSession();
    fakeSession.setState(active: false, admin: false, userId: null);
    when(() => mockClient.auth).thenReturn(mockAuth);

    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(operatorSession: fakeSession),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();
    expect(find.text('Accedi'), findsOneWidget);
  });

  Future<void> testLoginWithRoles(
    WidgetTester tester, {
    required bool isActive,
    required bool isAdmin,
    required String expectedRedirect,
  }) async {
    final mockObserver = MockNavigatorObserver();
    final fakeSession = FakeOperatorSession();

    when(() => mockClient.auth).thenReturn(mockAuth);
    Supabase.instance.client = mockClient;
    when(() => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
      when(() => mockUser.id).thenReturn('123');
      fakeSession.setState(admin: isAdmin, active: isActive, userId: '123');
      when(() => mockAuth.currentSession).thenReturn(mockSession);
      return AuthResponse(session: mockSession, user: mockUser);
    });

    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [mockObserver],
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(operatorSession: fakeSession),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
    expect(find.text(expectedRedirect), findsOneWidget);
  }

  testWidgets('login: attivo + admin', (tester) async {
    await testLoginWithRoles(tester,
        isActive: true, isAdmin: true, expectedRedirect: 'Donazione');
  });

  testWidgets('login: attivo + non admin', (tester) async {
    await testLoginWithRoles(tester,
        isActive: true, isAdmin: false, expectedRedirect: 'Donazione');
  });

  testWidgets('login: non attivo + admin', (tester) async {
    await testLoginWithRoles(tester,
        isActive: false, isAdmin: true, expectedRedirect: 'Non Attivo');
  });

  testWidgets('login: non attivo + non admin', (tester) async {
    await testLoginWithRoles(tester,
        isActive: false, isAdmin: false, expectedRedirect: 'Non Attivo');
  });

  testWidgets('login fallito mostra messaggio di errore 400', (tester) async {
    final fakeSession = FakeOperatorSession();
    fakeSession.setState(active: false, admin: false, userId: null);

    when(() => mockClient.auth).thenReturn(mockAuth);
    Supabase.instance.client = mockClient;
    when(() => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FakeAuthException('Invalid login credentials', '400'));

    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(
              operatorSession: fakeSession,
            ),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Credenziali errate. Riprova.'), findsOneWidget);
  });

  testWidgets('login fallito mostra errore per troppi tentativi (429)',
      (tester) async {
    final fakeSession = FakeOperatorSession();
    fakeSession.setState(active: false, admin: false, userId: null);

    when(() => mockClient.auth).thenReturn(mockAuth);
    Supabase.instance.client = mockClient;
    when(() => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FakeAuthException('Too many attempts', '429'));

    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(
              operatorSession: fakeSession,
            ),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'spam@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'spam123');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(find.text('Troppi tentativi. Riprova tra qualche minuto.'),
        findsOneWidget);
  });

  testWidgets('login fallito mostra errore generico', (tester) async {
    final fakeSession = FakeOperatorSession();
    fakeSession.setState(active: false, admin: false, userId: null);

    when(() => mockClient.auth).thenReturn(mockAuth);
    Supabase.instance.client = mockClient;
    when(() => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(Exception('Something went wrong'));

    await tester.pumpWidget(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(
              operatorSession: fakeSession,
            ),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'oops@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'error');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    expect(
      find.text(
          'Errore di autenticazione sconosciuto. Contatta un amministratore.'),
      findsOneWidget,
    );
  });

  testWidgets('login automatico se sessione esistente', (tester) async {
    final fakeSession = FakeOperatorSession();
    fakeSession.setState(admin: true, active: true, userId: '123');

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentSession).thenReturn(mockSession);
    Supabase.instance.client = mockClient;

    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(operatorSession: fakeSession),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();

    expect(find.text('Donazione'), findsOneWidget);
  });

  testWidgets('salva ultima email usata dopo il login', (tester) async {
    final fakeSession = FakeOperatorSession();
    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenAnswer((_) async {
      when(() => mockUser.id).thenReturn('xyz');
      fakeSession.setState(admin: true, active: true, userId: 'xyz');
      when(() => mockAuth.currentSession).thenReturn(mockSession);
      return AuthResponse(session: mockSession, user: mockUser);
    });
    Supabase.instance.client = mockClient;

    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(operatorSession: fakeSession),
        '/donation': (_) => const Scaffold(body: Text('Donazione')),
        '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
      },
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'demo@email.com');
    await tester.enterText(find.byType(TextField).at(1), 'secret');
    await tester.tap(find.text('Accedi'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('last_email'), 'demo@email.com');
  });
}
