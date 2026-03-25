import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';
import 'package:avis_donation_management/pages/operators_page.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FakeOperatorDetailsPage extends StatelessWidget {
  const FakeOperatorDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    String text = 'Current operator';
    if (args != null) {
      OperatorData? operatorData =
          (args as Map<String, OperatorData?>)['operator'];
      if (operatorData == null) {
        text = 'New operator';
      } else {
        text = 'Operator ID: ${operatorData.id}';
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          const Text('Operator Details Page'),
          Text(text),
        ],
      ),
    );
  }
}

void main() {
  group('OperatorsPage UI logic tests', () {
    late FakeAppInfo fakeAppInfo;
    late FakeConnectionStatus fakeConnectionStatus;
    late FakeOperatorSession fakeOperatorSession;
    late MockSupabaseClient mockClient;
    late MockPostgrestFilterBuilder<List<Map<String, dynamic>>> mockFilter;
    late MockRealtimeChannel mockChannel;

    void Function(PostgresChangePayload)? onChangeCallback;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: 'http://localhost:54321',
        anonKey: 'test_anon_key',
      );
    });

    setUp(() {
      fakeAppInfo = FakeAppInfo();
      fakeConnectionStatus = FakeConnectionStatus(initialized: true);
      OperatorData operatorData = OperatorData(
        id: 'ID_M',
        authUserId: 'auth_user_id_M',
        isAdmin: true,
        isActive: true,
        firstName: 'Mario',
        lastName: 'Rossi',
      );
      fakeOperatorSession = FakeOperatorSession(
        initialized: true,
        data: operatorData,
      );
      mockClient = MockSupabaseClient();
      mockFilter = MockPostgrestFilterBuilder();
      mockChannel = MockRealtimeChannel();

      Supabase.instance.client = mockClient;

      when(() => mockClient.rpc<List<Map<String, dynamic>>>(any()))
          .thenAnswer((_) => mockFilter);
      when(() => mockFilter.then<dynamic>(
            any(),
            onError: any(named: 'onError'),
          )).thenAnswer((invocation) {
        final cb = invocation.positionalArguments.first as dynamic Function(
            List<Map<String, dynamic>>);
        return Future.value(cb([]));
      });

      when(() => mockClient.channel(any())).thenAnswer((_) => mockChannel);
      when(() => mockChannel.onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: any(named: 'schema'),
            table: any(named: 'table'),
            filter: any(named: 'filter'),
            callback: any(named: 'callback'),
          )).thenAnswer((invocation) {
        onChangeCallback = invocation.namedArguments[const Symbol('callback')];
        return mockChannel;
      });
      when(() => mockChannel.subscribe()).thenReturn(mockChannel);
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'Ok');
    });

    testWidgets('FloatingActionButton opens new operator creation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (_) => OperatorsPage(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
            '/operator_details': (_) => const FakeOperatorDetailsPage(),
          },
        ),
      );

      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Operator Details Page'), findsOneWidget);
      expect(find.text('New operator'), findsOneWidget);
    });

    testWidgets('Tapping operator navigates with correct ID',
        (WidgetTester tester) async {
      when(() => mockFilter.then<dynamic>(
            any(),
            onError: any(named: 'onError'),
          )).thenAnswer((invocation) {
        final cb = invocation.positionalArguments.first as dynamic Function(
            List<Map<String, dynamic>>);
        return Future.value(cb([
          {
            'id': '1',
            'first_name': 'Mario',
            'last_name': 'Rossi',
            'nickname': 'mar',
            'auth_user_id': '1',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '2',
            'first_name': 'Luca',
            'last_name': 'Bianchi',
            'nickname': '',
            'auth_user_id': '2',
            'is_admin': false,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '3',
            'first_name': 'Anna',
            'last_name': 'Verdi',
            'nickname': '',
            'auth_user_id': '3',
            'is_admin': false,
            'active': false,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '4',
            'first_name': 'Giulia',
            'last_name': 'Neri',
            'nickname': '',
            'auth_user_id': null,
            'is_admin': false,
            'active': false,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '5',
            'first_name': 'Vecchio',
            'last_name': 'Admin',
            'nickname': '',
            'auth_user_id': null,
            'is_admin': true,
            'active': false,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
        ]));
      });

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (_) => OperatorsPage(
                  appInfo: fakeAppInfo,
                  connectionStatus: fakeConnectionStatus,
                  operatorSession: fakeOperatorSession,
                ),
            '/operator_details': (_) => const FakeOperatorDetailsPage(),
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Amministratori'), findsOneWidget);
      expect(find.textContaining('Operatori Attivi'), findsOneWidget);
      expect(find.textContaining('Operatori Disattivati'), findsOneWidget);
      final deletedOperators = find.textContaining('Operatori Eliminati');
      expect(deletedOperators, findsOneWidget);
      expect(find.textContaining('Mario Rossi'), findsOneWidget);
      expect(find.textContaining('Luca Bianchi'), findsOneWidget);
      expect(find.textContaining('Anna Verdi'), findsNothing);
      expect(find.textContaining('Giulia Neri'), findsNothing);
      expect(find.textContaining('Vecchio Admin'), findsNothing);

      await tester.tap(deletedOperators);
      await tester.pumpAndSettle();

      expect(find.textContaining('Amministratori'), findsOneWidget);
      expect(find.textContaining('Operatori Attivi'), findsOneWidget);
      expect(find.textContaining('Operatori Disattivati'), findsOneWidget);
      expect(find.textContaining('Operatori Eliminati'), findsOneWidget);
      final operatorTile = find.textContaining('Mario Rossi');
      expect(operatorTile, findsOneWidget);
      expect(find.textContaining('Luca Bianchi'), findsOneWidget);
      expect(find.textContaining('Anna Verdi'), findsNothing);
      expect(find.textContaining('Giulia Neri'), findsOneWidget);
      expect(find.textContaining('Vecchio Admin'), findsOneWidget);

      await tester.tap(operatorTile);
      await tester.pumpAndSettle();

      expect(find.textContaining('Operator ID: 1'), findsOneWidget);
    });

    testWidgets('Realtime insert updates the UI', (tester) async {
      when(() => mockFilter.then<dynamic>(
            any(),
            onError: any(named: 'onError'),
          )).thenAnswer((invocation) {
        final cb = invocation.positionalArguments.first as dynamic Function(
            List<Map<String, dynamic>>);
        return Future.value(cb([
          {
            'id': '1',
            'first_name': 'Mario',
            'last_name': 'Rossi',
            'nickname': 'mar',
            'auth_user_id': '1',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '2',
            'first_name': 'Luca',
            'last_name': 'Bianchi',
            'nickname': '',
            'auth_user_id': '2',
            'is_admin': false,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '3',
            'first_name': 'Anna',
            'last_name': 'Verdi',
            'nickname': '',
            'auth_user_id': '3',
            'is_admin': false,
            'active': false,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '4',
            'first_name': 'Giulia',
            'last_name': 'Neri',
            'nickname': '',
            'auth_user_id': null,
            'is_admin': false,
            'active': false,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
        ]));
      });

      await tester.pumpWidget(
        MaterialApp(
          home: OperatorsPage(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.textContaining('Nuovo Admin'), findsNothing);

      onChangeCallback?.call(PostgresChangePayload(
        schema: 'public',
        table: 'operators',
        commitTimestamp: DateTime.now(),
        eventType: PostgresChangeEvent.insert,
        newRecord: {
          'id': '99',
          'first_name': 'Nuovo',
          'last_name': 'Admin',
          'nickname': '',
          'auth_user_id': '5',
          'is_admin': true,
          'active': true,
          'created_at': '2023-10-01T12:00:00Z',
          'created_by': '1',
          'updated_at': '2023-10-01T12:00:00Z',
        },
        oldRecord: {},
        errors: null,
      ));

      await tester.pumpAndSettle();
      expect(find.textContaining('Nuovo Admin'), findsOneWidget);

      onChangeCallback?.call(PostgresChangePayload(
        schema: 'public',
        table: 'operators',
        commitTimestamp: DateTime.now(),
        eventType: PostgresChangeEvent.update,
        newRecord: {
          'id': '99',
          'first_name': 'Aggiornato',
          'last_name': 'Operatore',
          'nickname': '',
          'auth_user_id': '5',
          'is_admin': false,
          'active': true,
          'created_at': '2023-10-01T12:00:00Z',
          'created_by': '1',
          'updated_at': '2023-10-01T12:00:00Z',
          'updated_by': '2',
        },
        oldRecord: {
          'id': '99',
        },
        errors: null,
      ));

      await tester.pumpAndSettle();
      expect(find.textContaining('Nuovo Admin'), findsNothing);
      expect(find.textContaining('Aggiornato Operatore'), findsOneWidget);

      onChangeCallback?.call(PostgresChangePayload(
        schema: 'public',
        table: 'operators',
        commitTimestamp: DateTime.now(),
        eventType: PostgresChangeEvent.delete,
        newRecord: {},
        oldRecord: {'id': '99'},
        errors: null,
      ));

      await tester.pumpAndSettle();
      expect(find.textContaining('Aggiornato Operatore'), findsNothing);
    });

    testWidgets('sortOperators orders by priority then by name',
        (tester) async {
      when(() => mockFilter.then<dynamic>(
            any(),
            onError: any(named: 'onError'),
          )).thenAnswer((invocation) {
        final cb = invocation.positionalArguments.first as dynamic Function(
            List<Map<String, dynamic>>);
        return Future.value(cb([
          {
            'id': '1',
            'first_name': 'Z',
            'last_name': 'Z',
            'nickname': 'N',
            'auth_user_id': '1',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '2',
            'first_name': 'Z',
            'last_name': 'Z',
            'nickname': '',
            'auth_user_id': '2',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '3',
            'first_name': 'Z',
            'last_name': 'A',
            'nickname': 'N',
            'auth_user_id': '3',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '4',
            'first_name': 'Z',
            'last_name': 'A',
            'nickname': '',
            'auth_user_id': '4',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
          {
            'id': '5',
            'first_name': 'A',
            'last_name': 'A',
            'nickname': '',
            'auth_user_id': '5',
            'is_admin': true,
            'active': true,
            'created_at': '2023-10-01T12:00:00Z',
            'updated_at': '2023-10-01T12:00:00Z',
          },
        ]));
      });

      await tester.pumpWidget(
        MaterialApp(
          home: OperatorsPage(
            appInfo: fakeAppInfo,
            connectionStatus: fakeConnectionStatus,
            operatorSession: fakeOperatorSession,
          ),
        ),
      );

      await tester.pumpAndSettle();

      List<String> expected = [
        'Amministratori',
        'A A',
        'Z A',
        'Z A (N)',
        'Z Z',
        'Z Z (N)',
      ];

      Iterable<ListTile> widgets =
          tester.widgetList<ListTile>(find.byType(ListTile));

      expect(widgets.length, equals(expected.length));

      for (var i = 0; i < widgets.length; i++) {
        expect((widgets.elementAt(i).title as Text).data, equals(expected[i]));
      }
    });
  });
}
