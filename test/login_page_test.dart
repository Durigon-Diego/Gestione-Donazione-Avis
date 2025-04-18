import 'package:flutter/material.dart'; import 'package:flutter_test/flutter_test.dart'; import 'package:mocktail/mocktail.dart'; import 'package:supabase_flutter/supabase_flutter.dart'; import 'package:avis_donor_app/pages/login_page.dart'; import 'package:avis_donor_app/helpers/operator_session.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {} class MockAuth extends Mock implements GoTrueClient {} class MockSession extends Mock implements Session {} class MockUser extends Mock implements User {} class FakeAuthException extends Fake implements AuthException { @override final String message; @override final String statusCode; FakeAuthException(this.message, this.statusCode); }

void main() { late MockSupabaseClient mockClient; late MockAuth mockAuth; late MockSession mockSession; late MockUser mockUser;

setUp(() { registerFallbackValue(FakeAuthException('Fallback', '400')); mockClient = MockSupabaseClient(); mockAuth = MockAuth(); mockSession = MockSession(); mockUser = MockUser();

// Override Supabase instance with mock
Supabase.instance.client = mockClient;

});

testWidgets('renders LoginPage and finds Accedi button', (tester) async { await tester.pumpWidget(const MaterialApp(home: LoginPage())); expect(find.text('Accedi'), findsOneWidget); });

Future<void> testLoginWithRoles( WidgetTester tester, { required bool isActive, required bool isAdmin, required String expectedRedirect, }) async { when(() => mockClient.auth).thenReturn(mockAuth); when(() => mockAuth.signInWithPassword( email: any(named: 'email'), password: any(named: 'password'), )).thenAnswer((_) async => AuthResponse(session: mockSession, user: mockUser));

OperatorSession.name = 'Test User';
OperatorSession.isActive = isActive;
OperatorSession.isAdmin = isAdmin;
OperatorSession.currentUserId = '123';

await tester.pumpWidget(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => const LoginPage(),
    '/donation': (_) => const Scaffold(body: Text('Donazione')),
    '/not_active': (_) => const Scaffold(body: Text('Non Attivo')),
  },
));

await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
await tester.enterText(find.byType(TextField).at(1), 'password');
await tester.tap(find.text('Accedi'));
await tester.pumpAndSettle();

expect(find.text(expectedRedirect), findsOneWidget);

}

testWidgets('login: attivo + admin', (tester) async { await testLoginWithRoles(tester, isActive: true, isAdmin: true, expectedRedirect: 'Donazione'); });

testWidgets('login: attivo + non admin', (tester) async { await testLoginWithRoles(tester, isActive: true, isAdmin: false, expectedRedirect: 'Donazione'); });

testWidgets('login: non attivo + admin', (tester) async { await testLoginWithRoles(tester, isActive: false, isAdmin: true, expectedRedirect: 'Non Attivo'); });

testWidgets('login: non attivo + non admin', (tester) async { await testLoginWithRoles(tester, isActive: false, isAdmin: false, expectedRedirect: 'Non Attivo'); });

testWidgets('login fallito mostra messaggio di errore 400', (tester) async { when(() => mockClient.auth).thenReturn(mockAuth); when(() => mockAuth.signInWithPassword( email: any(named: 'email'), password: any(named: 'password'), )).thenThrow(FakeAuthException('Invalid login credentials', '400'));

await tester.pumpWidget(const MaterialApp(home: LoginPage()));

await tester.enterText(find.byType(TextField).at(0), 'wrong@example.com');
await tester.enterText(find.byType(TextField).at(1), 'wrongpass');
await tester.tap(find.text('Accedi'));
await tester.pumpAndSettle();

expect(find.text('Credenziali errate. Riprova.'), findsOneWidget);

});

testWidgets('login fallito mostra errore per troppi tentativi (429)', (tester) async { when(() => mockClient.auth).thenReturn(mockAuth); when(() => mockAuth.signInWithPassword( email: any(named: 'email'), password: any(named: 'password'), )).thenThrow(FakeAuthException('Too many attempts', '429'));

await tester.pumpWidget(const MaterialApp(home: LoginPage()));

await tester.enterText(find.byType(TextField).at(0), 'spam@example.com');
await tester.enterText(find.byType(TextField).at(1), 'spam123');
await tester.tap(find.text('Accedi'));
await tester.pumpAndSettle();

expect(find.text('Troppi tentativi. Riprova tra qualche minuto.'), findsOneWidget);

});

testWidgets('login fallito mostra errore generico', (tester) async { when(() => mockClient.auth).thenReturn(mockAuth); when(() => mockAuth.signInWithPassword( email: any(named: 'email'), password: any(named: 'password'), )).thenThrow(Exception('Something went wrong'));

await tester.pumpWidget(const MaterialApp(home: LoginPage()));

await tester.enterText(find.byType(TextField).at(0), 'oops@example.com');
await tester.enterText(find.byType(TextField).at(1), 'error');
await tester.tap(find.text('Accedi'));
await tester.pumpAndSettle();

expect(
  find.text('Errore di autenticazione sconosciuto. Contatta un amministratore.'),
  findsOneWidget,
);

}); }

