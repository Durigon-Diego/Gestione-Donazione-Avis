import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donor_app/helpers/operator_session_controller.dart';
import 'package:avis_donor_app/helpers/operator_session.dart';
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
    test('isConnected returns true if currentUserId is not null', () {
      final controller = FakeOperatorSession(currentUserId: '123');
      expect(controller.isConnected, isTrue);
    });

    test('isConnected returns false if currentUserId is null', () {
      final controller = FakeOperatorSession();
      expect(controller.isConnected, isFalse);
    });
  });

  group('OperatorSession full lifecycle', () {
    late MockSupabaseClient mockClient;
    late MockAuthClient mockAuth;
    late StreamController<AuthState> authStreamController;
    late MockSession mockSession;
    late MockUser mockUser;
    late MockRealtimeChannel mockChannel;

    late OperatorSession session;

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

      session = OperatorSession();
      session.addListener(notifiedCallback);
    });

    tearDownAll(() => session.removeListener(notifiedCallback));

    setUp(() => notified = false);
    tearDown(() => notified = false);

    void mockRPC({
      String uid = 'uid',
      String name = 'Test',
      bool isAdmin = false,
      bool active = false,
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
          'name': name,
          'is_admin': isAdmin,
          'active': active,
        }));
      });

      when(() => mockAuth.currentSession).thenReturn(mockSession);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn(uid);

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
      session.init();

      expect(notified, true);
      expect(session.name, isNull);
      expect(session.isAdmin, isFalse);
      expect(session.isActive, isFalse);
      expect(session.currentUserId, isNull);
    });

    testWidgets('OperatorSession reacts to all auth cases and realtime updates',
        (tester) async {
      mockRPC();

      await session.init();
      expect(notified, true);
      expect(session.name, 'Test');
      expect(session.isAdmin, isFalse);
      expect(session.isActive, isFalse);
      expect(session.currentUserId, 'uid');

      notified = false;
      authStreamController
          .add(const AuthState(AuthChangeEvent.signedOut, null));
      await tester.pump();

      expect(notified, true);
      expect(session.name, isNull);
      expect(session.isAdmin, isFalse);
      expect(session.isActive, isFalse);
      expect(session.currentUserId, isNull);

      notified = false;
      mockRPC(uid: 'uid2', name: 'Second', isAdmin: true, active: true);
      authStreamController
          .add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await tester.pump();

      expect(notified, true);
      expect(session.name, 'Second');
      expect(session.isAdmin, true);
      expect(session.isActive, true);
      expect(session.currentUserId, 'uid2');

      notified = false;
      mockRPC(uid: 'other_user');
      authStreamController
          .add(AuthState(AuthChangeEvent.tokenRefreshed, mockSession));
      await tester.pump();

      expect(notified, true);
      expect(session.name, 'Test');
      expect(session.isAdmin, isFalse);
      expect(session.isActive, isFalse);
      expect(session.currentUserId, 'other_user');

      notified = false;
      onChangeCallback!.call(PostgresChangePayload(
          schema: 'public',
          table: 'operators',
          commitTimestamp: DateTime.now(),
          eventType: PostgresChangeEvent.update,
          newRecord: {'name': 'Updated', 'is_admin': true, 'active': true},
          oldRecord: {'name': 'Second'},
          errors: null));

      expect(notified, true);
      expect(session.name, 'Updated');
      expect(session.isAdmin, true);
      expect(session.isActive, true);
      expect(session.currentUserId, 'other_user');

      // Force RPC failure
      final mockFilterError = MockPostgrestFilterBuilder();
      when(() => mockClient.rpc('get_my_operator_profile'))
          .thenAnswer((_) => mockFilterError);
      when(() => mockFilterError.single()).thenThrow(Exception('rpc error'));

      notified = false;
      authStreamController
          .add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await tester.pump();

      expect(notified, true);
      expect(session.name, isNull);
      expect(session.isAdmin, isFalse);
      expect(session.isActive, isFalse);
      expect(session.currentUserId, isNull);
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
            session.logout(context);
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

      await session.logout();
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
