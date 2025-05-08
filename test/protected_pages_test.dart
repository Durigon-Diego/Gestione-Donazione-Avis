// Unit tests for protected_pages.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/components/protected_pages.dart';
import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

void main() {
  group('ProtectedPages Access Control', () {
    late FakeAppInfo appInfo;
    late FakeConnectionStatus connectionStatus;
    late FakeOperatorSession operatorSession;

    setUp(() {
      appInfo = FakeAppInfo();
      connectionStatus = FakeConnectionStatus();
      operatorSession = FakeOperatorSession();
    });

    testWidgets('shows content when access is granted', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: _TestPage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('VISIBLE'), findsOneWidget);
    });

    testWidgets('hides content when checkAccess returns false', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: _TestPage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
          overrideAccess: false,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('VISIBLE'), findsNothing);
    });

    testWidgets('LoggedCheck redirects when not connected', (tester) async {
      operatorSession.setState(currentOperatorID: null);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/login': (context) => const Text('LOGIN'),
        },
        home: _LoggedPage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('LOGIN'), findsOneWidget);
    });

    testWidgets('ActiveCheck redirects when not active', (tester) async {
      operatorSession.setState(currentOperatorID: 'x', isActive: false);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/not_active': (context) => const Text('NOT_ACTIVE'),
        },
        home: _ActivePage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('NOT_ACTIVE'), findsOneWidget);
    });

    testWidgets('AdminCheck redirects when not admin', (tester) async {
      operatorSession.setState(
          currentOperatorID: 'x', isActive: true, isAdmin: false);

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/donation': (context) => const Text('DONATION'),
        },
        home: _AdminPage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('DONATION'), findsOneWidget);
    });

    testWidgets('ActiveCheck defers to super when user is active',
        (tester) async {
      operatorSession.setState(currentOperatorID: 'x', isActive: true);

      await tester.pumpWidget(MaterialApp(
        home: _ActivePage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('SHOULD NOT SEE'), findsOneWidget);
    });

    testWidgets('AdminCheck defers to super when user is admin',
        (tester) async {
      operatorSession.setState(
          currentOperatorID: 'x', isActive: true, isAdmin: true);

      await tester.pumpWidget(MaterialApp(
        home: _AdminPage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('SHOULD NOT SEE'), findsOneWidget);
    });

    testWidgets('ProtectedAvisScaffoldedPage renders correctly',
        (tester) async {
      operatorSession.setState(currentOperatorID: 'x');

      await tester.pumpWidget(MaterialApp(
        home: _ScaffoldedPage(
          appInfo: appInfo,
          connectionStatus: connectionStatus,
          operatorSession: operatorSession,
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('Scaffold title'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });
  });
}

class _TestPage extends ProtectedPage {
  final bool overrideAccess;

  const _TestPage({
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
    this.overrideAccess = true,
  });

  @override
  Widget buildContent(BuildContext context) {
    return const Center(child: Text('VISIBLE'));
  }

  @override
  bool checkAccess(BuildContext context, NavigatorState? nav) => overrideAccess;
}

class _LoggedPage extends ProtectedPage with LoggedCheck {
  const _LoggedPage({
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  });

  @override
  Widget buildContent(BuildContext context) {
    return const Text('SHOULD NOT SEE');
  }
}

class _ActivePage extends ProtectedPage with LoggedCheck, ActiveCheck {
  const _ActivePage({
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  });

  @override
  Widget buildContent(BuildContext context) {
    return const Text('SHOULD NOT SEE');
  }
}

class _AdminPage extends ProtectedPage
    with LoggedCheck, ActiveCheck, AdminCheck {
  const _AdminPage({
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  });

  @override
  Widget buildContent(BuildContext context) {
    return const Text('SHOULD NOT SEE');
  }
}

class _ScaffoldedPage extends ProtectedAvisScaffoldedPage with LoggedCheck {
  const _ScaffoldedPage({
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Scaffold title',
          body: const Text('Body content'),
        );
}
