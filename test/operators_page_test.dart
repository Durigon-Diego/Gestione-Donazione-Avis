import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avis_donation_management/pages/operators_page.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FakeAccountPage extends StatelessWidget {
  const FakeAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;

    String text = 'New operator';
    if (args != null) {
      Map<String, dynamic>? operatorData =
          (args as Map<String, Map<String, dynamic>>)['operator'];
      if (operatorData == null) {
        text = 'Null operator';
      } else {
        text = 'Operator ID: ${operatorData['id']}';
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          const Text('Account Page'),
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
    late MockSupabaseQueryBuilder queryBuilder;
    late MockRealtimeChannel mockChannel;
    late MockPostgrestFilterBuilder mockFilter;

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
      fakeOperatorSession = FakeOperatorSession(
        initialized: true,
        currentOperatorID: '1',
        isAdmin: true,
      );
      mockClient = MockSupabaseClient();
      queryBuilder = MockSupabaseQueryBuilder();
      mockChannel = MockRealtimeChannel();
      mockFilter = MockPostgrestFilterBuilder();

      Supabase.instance.client = mockClient;

      when(() => mockClient.from(any())).thenAnswer((_) => queryBuilder);
      when(() => queryBuilder.select(any())).thenAnswer((_) => mockFilter);
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
            '/account': (_) => const FakeAccountPage(),
          },
        ),
      );

      await tester.pumpAndSettle();
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.text('Account Page'), findsOneWidget);
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
            'id': 1,
            'first_name': 'Mario',
            'last_name': 'Rossi',
            'nickname': 'mar',
            'auth_user_id': '1',
            'is_admin': true,
            'active': true,
          },
          {
            'id': 2,
            'first_name': 'Luca',
            'last_name': 'Bianchi',
            'nickname': '',
            'auth_user_id': '2',
            'is_admin': false,
            'active': true,
          },
          {
            'id': 3,
            'first_name': 'Anna',
            'last_name': 'Verdi',
            'nickname': '',
            'auth_user_id': '3',
            'is_admin': false,
            'active': false,
          },
          {
            'id': 4,
            'first_name': 'Giulia',
            'last_name': 'Neri',
            'nickname': '',
            'auth_user_id': null,
            'is_admin': false,
            'active': false,
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
            '/account': (_) => const FakeAccountPage(),
          },
        ),
      );

      await tester.pumpAndSettle();
      final operatorTile = find.textContaining('Mario Rossi');
      expect(operatorTile, findsOneWidget);

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
            'id': 1,
            'first_name': 'Mario',
            'last_name': 'Rossi',
            'nickname': 'mar',
            'auth_user_id': '1',
            'is_admin': true,
            'active': true,
          },
          {
            'id': 2,
            'first_name': 'Luca',
            'last_name': 'Bianchi',
            'nickname': '',
            'auth_user_id': '2',
            'is_admin': false,
            'active': true,
          },
          {
            'id': 3,
            'first_name': 'Anna',
            'last_name': 'Verdi',
            'nickname': '',
            'auth_user_id': '3',
            'is_admin': false,
            'active': false,
          },
          {
            'id': 4,
            'first_name': 'Giulia',
            'last_name': 'Neri',
            'nickname': '',
            'auth_user_id': null,
            'is_admin': false,
            'active': false,
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
          'id': 99,
          'first_name': 'Nuovo',
          'last_name': 'Admin',
          'nickname': '',
          'auth_user_id': '5',
          'is_admin': true,
          'active': true
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
          'id': 99,
          'first_name': 'Aggiornato',
          'last_name': 'Operatore',
          'nickname': '',
          'auth_user_id': '5',
          'is_admin': false,
          'active': true
        },
        oldRecord: {
          'id': 99,
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
        oldRecord: {
          'id': 99,
        },
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
            'id': 1,
            'first_name': 'Z',
            'last_name': 'Z',
            'nickname': 'N',
            'auth_user_id': '1',
            'is_admin': true,
            'active': true,
          },
          {
            'id': 2,
            'first_name': 'Z',
            'last_name': 'Z',
            'nickname': '',
            'auth_user_id': '2',
            'is_admin': true,
            'active': true,
          },
          {
            'id': 3,
            'first_name': 'Z',
            'last_name': 'A',
            'nickname': 'N',
            'auth_user_id': '3',
            'is_admin': true,
            'active': true,
          },
          {
            'id': 4,
            'first_name': 'Z',
            'last_name': 'A',
            'nickname': '',
            'auth_user_id': '4',
            'is_admin': true,
            'active': true,
          },
          {
            'id': 5,
            'first_name': 'A',
            'last_name': 'A',
            'nickname': '',
            'auth_user_id': '5',
            'is_admin': true,
            'active': true,
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
