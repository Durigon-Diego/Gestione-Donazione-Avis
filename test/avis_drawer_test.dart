import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/components/avis_drawer.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

void main() {
  group('AvisDrawer', () {
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: 'http://localhost',
        anonKey: 'fake-key',
      );
    });

    late FakeConnectionStatus fakeConnectionStatus;

    setUp(() {
      fakeConnectionStatus = FakeConnectionStatus();
    });

    testWidgets('displays base items for active operator', (tester) async {
      final fakeAppInfo = FakeAppInfo();
      final fakeOperatorSession = FakeOperatorSession(
        firstName: 'Mario',
        lastName: 'Rossi',
        isActive: true,
        isAdmin: false,
      );

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
          body: const Text('Home'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Mario Rossi'), findsOneWidget);
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
      final fakeOperatorSession = FakeOperatorSession(
        firstName: 'Admin',
        lastName: 'User',
        isActive: true,
        isAdmin: true,
      );

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
          body: const Text('Home'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Admin User'), findsOneWidget);
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
      final fakeOperatorSession = FakeOperatorSession(
        firstName: 'Giulia',
        lastName: 'Bianchi',
        nickname: 'GB',
        isActive: false,
        isAdmin: false,
      );

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
          body: const Text('Home'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Giulia Bianchi (GB)'), findsOneWidget);
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
      final fakeOperatorSession = FakeOperatorSession(
        firstName: 'Luca',
        lastName: 'Verdi',
        isActive: false,
        isAdmin: true,
      );

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donazione Page'),
              ),
          '/not_active': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Not Active Page'),
              ),
          '/account': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Account Page'),
              ),
          '/operators': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Operators Page'),
              ),
          '/donations_days': (_) => Scaffold(
                appBar: AppBar(),
                drawer: AvisDrawer(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
                body: const Text('Donation Days Page'),
              ),
        },
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
          body: const Text('Home'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Luca Verdi'), findsOneWidget);
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
      final fakeOperatorSession = FakeOperatorSession(
        firstName: 'Mario',
        lastName: 'Rossi',
        isActive: false,
        isAdmin: false,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          appBar: AppBar(),
          drawer: AvisDrawer(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
          body: const Text('Home'),
        ),
      ));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('Operatore'), findsOneWidget);
      expect(find.text('Donazione'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.text('Gestione Operatori'), findsNothing);

      fakeOperatorSession.setState(isActive: true);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);

      fakeOperatorSession.setState(isAdmin: true);
      await tester.pumpAndSettle();
      expect(find.text('Gestione Operatori'), findsOneWidget);

      fakeOperatorSession.setState(
        firstName: 'Luigi',
        lastName: 'Longobardi',
      );
      await tester.pumpAndSettle();
      expect(find.text('Luigi Longobardi'), findsOneWidget);

      fakeOperatorSession.setState(isAdmin: false, isActive: false);
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
            connectionStatus: fakeConnectionStatus,
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
            connectionStatus: fakeConnectionStatus,
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

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('App di Test'), findsNothing);
      expect(find.textContaining('Descrizione di test'), findsNothing);
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
            connectionStatus: fakeConnectionStatus,
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

    testWidgets(
      'reacts to dynamic session changes and handles connectivity loss',
      (tester) async {
        final fakeAppInfo = FakeAppInfo();
        final fakeOperatorSession = FakeOperatorSession(
          firstName: 'Mario',
          lastName: 'Rossi',
          isActive: false,
          isAdmin: false,
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            appBar: AppBar(),
            drawer: AvisDrawer(
              appInfo: fakeAppInfo,
              connectionStatus: fakeConnectionStatus,
              operatorSession: fakeOperatorSession,
            ),
            body: const Text('Home'),
          ),
        ));

        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();

        expect(find.text('Mario Rossi'), findsOneWidget);
        expect(find.text('Operatore'), findsOneWidget);
        expect(find.text('Donazione'), findsOneWidget);
        expect(find.byIcon(Icons.lock), findsOneWidget);
        expect(find.text('Gestione Operatori'), findsNothing);

        fakeOperatorSession.setState(isActive: true);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.lock), findsNothing);
        expect(find.byIcon(Icons.water_drop), findsOneWidget);

        fakeOperatorSession.setState(isAdmin: true);
        await tester.pumpAndSettle();
        expect(find.text('Gestione Operatori'), findsOneWidget);

        fakeOperatorSession.setState(
          firstName: 'Luigi',
          lastName: 'Longobardi',
        );
        await tester.pumpAndSettle();
        expect(find.text('Luigi Longobardi'), findsOneWidget);

        fakeOperatorSession.setState(isAdmin: false, isActive: false);
        await tester.pumpAndSettle();
        expect(find.text('Gestione Operatori'), findsNothing);
        expect(find.byIcon(Icons.lock), findsOneWidget);

        // Now simulate connectivity changes

        final connectionTileFinder = find.byWidgetPredicate((widget) {
          return widget is ListTile &&
              widget.title is Text &&
              (widget.title as Text).data != null &&
              ((widget.title as Text).data!.contains('Online') ||
                  (widget.title as Text).data!.contains('Utente inattivo') ||
                  (widget.title as Text)
                      .data!
                      .contains('Server non raggiungibile') ||
                  (widget.title as Text).data!.contains('Nessuna connessione'));
        });

        Text getConnectionText() {
          final listTile = tester.widget<ListTile>(connectionTileFinder);
          return listTile.title as Text;
        }

        // Should initially show "Utente inattivo" because operator is inactive
        expect(
          getConnectionText().data,
          'Utente inattivo',
        );

        // Simulate connection lost (disconnected)
        fakeConnectionStatus.setState(ServerStatus.disconnected);
        await tester.pumpAndSettle();
        expect(
          getConnectionText().data,
          'Nessuna connessione',
        );

        // Simulate Supabase unreachable (supabaseOffline)
        fakeConnectionStatus.setState(ServerStatus.supabaseOffline);
        await tester.pumpAndSettle();
        expect(
          getConnectionText().data,
          'Server non raggiungibile',
        );

        // Simulate connection restored and operator now active
        fakeOperatorSession.setState(isActive: true);
        fakeConnectionStatus.setState(ServerStatus.connected);
        await tester.pumpAndSettle();
        expect(
          getConnectionText().data,
          'Online',
        );
      },
    );
  });
}
