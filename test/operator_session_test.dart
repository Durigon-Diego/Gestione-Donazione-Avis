import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/helpers/operator_session.dart';
import 'fake_components/fake_operator_session.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockAuthClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

class MockUser extends Mock implements User {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRealtimeChannel extends Mock implements RealtimeChannel {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {}

class FakeRoute extends Fake implements Route<dynamic> {}

void main() {
  group('OperatorSessionController', () {
    test('isConnected returns true if currentOperatorID is not null', () {
      final controller = FakeOperatorSession(
        data: OperatorData(
          id: 'ID_M',
          authUserId: 'auth_user_id_M',
          isAdmin: false,
          isActive: true,
          firstName: 'Mario',
          lastName: 'Rossi',
        ),
      );
      expect(controller.isConnected, isTrue);
    });

    test('isConnected returns false if currentOperatorID is null', () {
      final controller = FakeOperatorSession();
      expect(controller.isConnected, isFalse);
    });

    test('name composed as "first_name last_name" if nickname is null', () {
      final controller = FakeOperatorSession(
        data: OperatorData(
          id: 'ID_M',
          authUserId: 'auth_user_id_M',
          isAdmin: false,
          isActive: true,
          firstName: 'Mario',
          lastName: 'Rossi',
        ),
      );
      expect(controller.name, 'Mario Rossi');
    });

    test(
        'name composed as "first_name last_name (nickname)" if nickname is not null',
        () {
      final controller = FakeOperatorSession(
        data: OperatorData(
          id: 'ID_M',
          authUserId: 'auth_user_id_M',
          isAdmin: false,
          isActive: true,
          firstName: 'Mario',
          lastName: 'Rossi',
          nickname: 'SuperMario',
        ),
      );
      expect(controller.name, 'Mario Rossi (SuperMario)');
    });
  });

  group('OperatorSession full lifecycle', () {
    late MockSupabaseClient mockClient;
    late MockAuthClient mockAuth;
    late StreamController<AuthState> authStreamController;
    late MockSession mockSession;
    late MockUser mockUser;
    late MockRealtimeChannel mockChannel;

    late OperatorSession operatorSession;

    bool notified = false;
    void Function(PostgresChangePayload)? onChangeCallback;

    void notifiedCallback() => notified = true;

    setUpAll(() async {
      registerFallbackValue(FakeRoute());

      mockClient = MockSupabaseClient();
      mockAuth = MockAuthClient();
      mockSession = MockSession();
      mockUser = MockUser();
      mockChannel = MockRealtimeChannel();
      authStreamController = StreamController<AuthState>.broadcast();

      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(
        url: 'http://localhost:54321',
        anonKey: 'test_anon_key',
      );

      Supabase.instance.client = mockClient;

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockAuth.onAuthStateChange)
          .thenAnswer((_) => authStreamController.stream);
      when(() => mockClient.channel(any())).thenReturn(mockChannel);
      when(() => mockChannel.unsubscribe()).thenAnswer((_) async => 'Ok');
      when(() => mockChannel.subscribe()).thenReturn(mockChannel);
      when(() => mockSession.user).thenReturn(mockUser);

      operatorSession = OperatorSession();
      operatorSession.addListener(notifiedCallback);
    });

    tearDownAll(() => operatorSession.removeListener(notifiedCallback));

    setUp(() => notified = false);
    tearDown(() => notified = false);

    void mockRPC({
      String operatorID = 'operatorID',
      String authID = 'uid',
      String firstName = 'Test',
      String lastName = 'User',
      String? nickname,
      bool isAdmin = false,
      bool active = false,
      String? createdAt,
      String? updatedAt,
    }) {
      final mockFilter = MockPostgrestFilterBuilder();
      final mockTransform = MockPostgrestTransformBuilder();

      when(() => mockClient.rpc('get_my_operator_profile'))
          .thenAnswer((_) => mockFilter);
      when(() => mockFilter.single()).thenAnswer((_) => mockTransform);
      when(() => mockTransform.then<dynamic>(any(),
          onError: any(named: 'onError'))).thenAnswer((invocation) {
        final cb = invocation.positionalArguments.first as dynamic Function(
            Map<String, dynamic>);
        return Future.value(cb({
          'id': operatorID,
          'auth_user_id': authID,
          'first_name': firstName,
          'last_name': lastName,
          'nickname': nickname,
          'is_admin': isAdmin,
          'active': active,
          'created_at': createdAt ?? DateTime.now().toIso8601String(),
          'updated_at': updatedAt ?? DateTime.now().toIso8601String(),
        }));
      });

      when(() => mockAuth.currentSession).thenReturn(mockSession);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn(authID);

      when(() => mockChannel.onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: any(named: 'schema'),
            table: any(named: 'table'),
            filter: any(named: 'filter'),
            callback: any(named: 'callback'),
          )).thenAnswer((invocation) {
        onChangeCallback = invocation.namedArguments[const Symbol('callback')];
        return mockChannel;
      });
    }

    testWidgets('Init without user logged', (tester) async {
      expect(operatorSession.initialized, isFalse);

      operatorSession.init();

      expect(notified, isTrue);
      expect(operatorSession.initialized, isTrue);
      expect(operatorSession.data, isNull);
      expect(operatorSession.name, isNull);
      expect(operatorSession.isAdmin, isFalse);
      expect(operatorSession.isActive, isFalse);
      expect(operatorSession.isConnected, isFalse);
    });

    testWidgets('OperatorSession reacts to all auth cases and realtime updates',
        (tester) async {
      mockRPC();

      await operatorSession.init();
      expect(notified, isTrue);
      expect(operatorSession.initialized, isTrue);
      expect(operatorSession.data, isNotNull);
      expect(operatorSession.data!.id, 'operatorID');
      expect(operatorSession.data!.authUserId, 'uid');
      expect(operatorSession.data!.firstName, 'Test');
      expect(operatorSession.data!.lastName, 'User');
      expect(operatorSession.data!.nickname, isNull);
      expect(operatorSession.name, 'Test User');
      expect(operatorSession.isAdmin, isFalse);
      expect(operatorSession.isActive, isFalse);
      expect(operatorSession.isConnected, isTrue);

      notified = false;
      authStreamController
          .add(const AuthState(AuthChangeEvent.signedOut, null));
      await tester.pump();

      expect(notified, isTrue);
      expect(operatorSession.data, isNull);
      expect(operatorSession.name, isNull);
      expect(operatorSession.isAdmin, isFalse);
      expect(operatorSession.isActive, isFalse);
      expect(operatorSession.isConnected, isFalse);

      notified = false;
      mockRPC(
        operatorID: 'operatorID2',
        authID: 'uid2',
        firstName: 'Second',
        lastName: 'Collaborator',
        nickname: 'SC',
        isAdmin: true,
        active: true,
      );
      authStreamController
          .add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await tester.pump();

      expect(notified, isTrue);
      expect(operatorSession.data, isNotNull);
      expect(operatorSession.data!.id, 'operatorID2');
      expect(operatorSession.data!.authUserId, 'uid2');
      expect(operatorSession.data!.firstName, 'Second');
      expect(operatorSession.data!.lastName, 'Collaborator');
      expect(operatorSession.data!.nickname, 'SC');
      expect(operatorSession.name, 'Second Collaborator (SC)');
      expect(operatorSession.isAdmin, isTrue);
      expect(operatorSession.isActive, isTrue);
      expect(operatorSession.isConnected, isTrue);

      notified = false;
      mockRPC(operatorID: 'other_user', authID: 'other_auth');
      authStreamController
          .add(AuthState(AuthChangeEvent.tokenRefreshed, mockSession));
      await tester.pump();

      expect(notified, isTrue);
      expect(operatorSession.data, isNotNull);
      expect(operatorSession.data!.id, 'other_user');
      expect(operatorSession.data!.authUserId, 'other_auth');
      expect(operatorSession.data!.firstName, 'Test');
      expect(operatorSession.data!.lastName, 'User');
      expect(operatorSession.data!.nickname, isNull);
      expect(operatorSession.name, 'Test User');
      expect(operatorSession.isAdmin, isFalse);
      expect(operatorSession.isActive, isFalse);
      expect(operatorSession.isConnected, isTrue);

      notified = false;
      onChangeCallback!.call(PostgresChangePayload(
        schema: 'public',
        table: 'operators',
        commitTimestamp: DateTime.now(),
        eventType: PostgresChangeEvent.update,
        newRecord: {
          'id': 'other_user',
          'auth_user_id': 'other_auth',
          'first_name': 'Updated',
          'last_name': 'User',
          'nickname': null,
          'is_admin': true,
          'active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        oldRecord: {
          'first_name': 'Test',
          'last_name': 'User',
          'nickname': null,
        },
        errors: null,
      ));

      expect(notified, isTrue);
      expect(operatorSession.data, isNotNull);
      expect(operatorSession.data!.id, 'other_user');
      expect(operatorSession.data!.authUserId, 'other_auth');
      expect(operatorSession.data!.firstName, 'Updated');
      expect(operatorSession.data!.lastName, 'User');
      expect(operatorSession.data!.nickname, isNull);
      expect(operatorSession.name, 'Updated User');
      expect(operatorSession.isAdmin, isTrue);
      expect(operatorSession.isActive, isTrue);
      expect(operatorSession.isConnected, isTrue);

      // Force RPC failure
      final mockFilterError = MockPostgrestFilterBuilder();
      when(() => mockClient.rpc('get_my_operator_profile'))
          .thenAnswer((_) => mockFilterError);
      when(() => mockFilterError.single()).thenThrow(Exception('rpc error'));

      notified = false;
      authStreamController
          .add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await tester.pump();

      expect(notified, isTrue);
      expect(operatorSession.data, isNull);
      expect(operatorSession.name, isNull);
      expect(operatorSession.isAdmin, isFalse);
      expect(operatorSession.isActive, isFalse);
      expect(operatorSession.isConnected, isFalse);
    });

    testWidgets('logout() calls navigator pushNamedAndRemoveUntil',
        (tester) async {
      final mockObserver = MockNavigatorObserver();

      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [mockObserver],
        routes: {'/login': (context) => const Text('Login')},
        home: Builder(
          builder: (context) {
            operatorSession.logout(context);
            return const Text('Home');
          },
        ),
      ));

      await tester.pumpAndSettle();

      verify(() => mockObserver.didPush(any(), any())).called(greaterThan(0));
    });

    testWidgets('logout() without context uses navigatorKey', (tester) async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      final navObserver = MockNavigatorObserver();

      final app = MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [navObserver],
        routes: {
          '/': (context) => const Text('Start'),
          '/login': (context) => const Text('Login'),
        },
      );

      await tester.pumpWidget(app);
      await tester.pump();

      navigatorKey.currentState?.pushNamed('/');
      await tester.pumpAndSettle();

      await operatorSession.logout();
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
