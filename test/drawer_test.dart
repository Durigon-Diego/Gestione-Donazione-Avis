import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avis_donor_app/helpers/avis_drawer.dart';
import 'fake_app_info.dart';
import 'fake_operator_session.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'fake-key',
    );
  });

  testWidgets('drawer mostra elementi base per operatore attivo',
      (tester) async {
    final fakeAppInfo = FakeAppInfo();
    final fakeOperatorSession =
        FakeOperatorSession(name: 'Mario', isActive: true, isAdmin: false);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: AvisDrawer(
            appInfo: fakeAppInfo, operatorSession: fakeOperatorSession),
        body: const Text('Home'),
      ),
    ));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Mario'), findsOneWidget);
    expect(find.text('Operatore'), findsOneWidget);
    expect(find.text('Gestione Account'), findsOneWidget);
    expect(find.text('Donazione'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsOneWidget);
    expect(find.text('Gestione Operatori'), findsNothing);
    expect(find.text('Gestione Giornate Donazioni'), findsNothing);
  });

  testWidgets('drawer mostra gli elementi per admin attivo', (tester) async {
    final fakeAppInfo = FakeAppInfo();
    final fakeOperatorSession =
        FakeOperatorSession(name: 'Admin', isActive: true, isAdmin: true);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: AvisDrawer(
            appInfo: fakeAppInfo, operatorSession: fakeOperatorSession),
        body: const Text('Home'),
      ),
    ));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Amministratore'), findsOneWidget);
    expect(find.text('Gestione Operatori'), findsOneWidget);
    expect(find.text('Gestione Giornate Donazioni'), findsOneWidget);
    expect(find.byIcon(Icons.water_drop), findsOneWidget);
  });

  testWidgets('drawer mostra elementi per operatore non attivo',
      (tester) async {
    final fakeAppInfo = FakeAppInfo();
    final fakeOperatorSession =
        FakeOperatorSession(name: 'Giulia', isActive: false, isAdmin: false);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: AvisDrawer(
          appInfo: fakeAppInfo,
          operatorSession: fakeOperatorSession,
        ),
        body: const Text('Home'),
      ),
    ));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Giulia'), findsOneWidget);
    expect(find.text('Operatore'), findsOneWidget);
    expect(find.text('Donazione'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('drawer mostra elementi per admin non attivo', (tester) async {
    final fakeAppInfo = FakeAppInfo();
    final fakeOperatorSession =
        FakeOperatorSession(name: 'Luca', isActive: false, isAdmin: true);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: AvisDrawer(
          appInfo: fakeAppInfo,
          operatorSession: fakeOperatorSession,
        ),
        body: const Text('Home'),
      ),
    ));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Luca'), findsOneWidget);
    expect(find.text('Amministratore'), findsOneWidget);
    expect(find.text('Gestione Operatori'), findsOneWidget);
    expect(find.text('Gestione Giornate Donazioni'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('drawer reagisce ai cambiamenti dinamici della sessione',
      (tester) async {
    final fakeAppInfo = FakeAppInfo();
    final fakeOperatorSession =
        FakeOperatorSession(name: 'Mario', isActive: false, isAdmin: false);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        drawer: AvisDrawer(
          appInfo: fakeAppInfo,
          operatorSession: fakeOperatorSession,
        ),
        body: const Text('Home'),
      ),
    ));

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Mario'), findsOneWidget);
    expect(find.text('Operatore'), findsOneWidget);
    expect(find.text('Donazione'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('Gestione Operatori'), findsNothing);

    fakeOperatorSession.setState(active: true);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lock), findsNothing);
    expect(find.byIcon(Icons.water_drop), findsOneWidget);

    fakeOperatorSession.setState(admin: true);
    await tester.pumpAndSettle();
    expect(find.text('Gestione Operatori'), findsOneWidget);

    fakeOperatorSession.setState(name: 'Luigi');
    await tester.pumpAndSettle();
    expect(find.text('Luigi'), findsOneWidget);

    fakeOperatorSession.setState(admin: false, active: false);
    await tester.pumpAndSettle();
    expect(find.text('Gestione Operatori'), findsNothing);
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}
