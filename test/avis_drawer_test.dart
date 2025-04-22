import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avis_donor_app/helpers/avis_drawer.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_operator_session.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost',
      anonKey: 'fake-key',
    );
  });

  group('AvisDrawer', () {
    testWidgets('displays base items for active operator', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession =
          FakeOperatorSession(name: 'Mario', isActive: true, isAdmin: false);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
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

      await tester.tap(find.text('Gestione Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Donazione'));
      await tester.pumpAndSettle();
      expect(find.text('Donazione Page'), findsOneWidget);
    });

    testWidgets('displays all items for active admin', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession =
          FakeOperatorSession(name: 'Admin', isActive: true, isAdmin: true);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
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
      expect(find.text('Gestione Account'), findsOneWidget);
      expect(find.text('Donazione'), findsOneWidget);
      expect(find.text('Gestione Operatori'), findsOneWidget);
      expect(find.text('Gestione Giornate Donazioni'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);

      await tester.tap(find.text('Gestione Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Donazione'));
      await tester.pumpAndSettle();
      expect(find.text('Donazione Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gestione Operatori'));
      await tester.pumpAndSettle();
      expect(find.text('Operators Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gestione Giornate Donazioni'));
      await tester.pumpAndSettle();
      expect(find.text('Donation Days Page'), findsOneWidget);
    });

    testWidgets('displays limited items for inactive operator', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession =
          FakeOperatorSession(name: 'Giulia', isActive: false, isAdmin: false);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
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
      expect(find.text('Gestione Account'), findsOneWidget);
      expect(find.text('Donazione'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Gestione Operatori'), findsNothing);
      expect(find.text('Gestione Giornate Donazioni'), findsNothing);

      await tester.tap(find.text('Gestione Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Donazione'));
      await tester.pumpAndSettle();
      expect(find.text('Not Active Page'), findsOneWidget);
    });

    testWidgets('displays extra items for inactive admin', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession =
          FakeOperatorSession(name: 'Luca', isActive: false, isAdmin: true);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
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
      expect(find.text('Gestione Account'), findsOneWidget);
      expect(find.text('Donazione'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Gestione Operatori'), findsOneWidget);
      expect(find.text('Gestione Giornate Donazioni'), findsOneWidget);

      await tester.tap(find.text('Gestione Account'));
      await tester.pumpAndSettle();
      expect(find.text('Account Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Donazione'));
      await tester.pumpAndSettle();
      expect(find.text('Not Active Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gestione Operatori'));
      await tester.pumpAndSettle();
      expect(find.text('Operators Page'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gestione Giornate Donazioni'));
      await tester.pumpAndSettle();
      expect(find.text('Donation Days Page'), findsOneWidget);
    });

    testWidgets('reacts to dynamic session changes', (tester) async {
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

    testWidgets('opens and closes Contatti dialog', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession = FakeOperatorSession();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            operatorSession: fakeOperatorSession,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Contatti'));
      await tester.pumpAndSettle();

      expect(find.textContaining('supporto@test.com'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.textContaining('supporto@test.com'), findsNothing);
    });

    testWidgets('opens and closes Info dialog', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession = FakeOperatorSession();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            operatorSession: fakeOperatorSession,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();

      expect(find.text('App di Test'), findsWidgets);
      expect(find.textContaining('Descrizione di test'), findsOneWidget);
    });

    testWidgets('invokes logout callback', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      bool logoutCalled = false;

      final fakeOperatorSession = FakeOperatorSession();
      fakeOperatorSession.onLogout = ([BuildContext? context]) {
        logoutCalled = true;
      };

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            operatorSession: fakeOperatorSession,
          ),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(logoutCalled, isTrue);
    });
  });
}
