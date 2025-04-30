import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donor_app/helpers/avis_scaffold.dart';
import 'package:avis_donor_app/helpers/avis_bottom_navigation_bar.dart';

import 'fake_components/fake_app_info.dart';
import 'fake_components/fake_connection_status_controller.dart';
import 'fake_components/fake_operator_session.dart';

void main() {
  group('AvisScaffold', () {
    late FakeAppInfo appInfo;
    late FakeConnectionStatus connectionStatus;
    late FakeOperatorSession operatorSession;

    setUp(() {
      appInfo = FakeAppInfo();
      connectionStatus = FakeConnectionStatus();
      operatorSession = FakeOperatorSession();
    });

    testWidgets('renders correctly with required parameters and no bottomNav',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AvisScaffold(
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession,
            title: 'Titolo Test',
            body: const Text('Contenuto corpo'),
          ),
        ),
      );

      expect(find.text('Titolo Test'), findsOneWidget);
      expect(find.text('Contenuto corpo'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('renders correctly with bottom navigation bar', (tester) async {
      final bottomNavData = AvisBottomNavigationBarData(
        items: const [
          BottomNavigationBarItemData(
            icon: Icons.home,
            label: 'Home',
          ),
          BottomNavigationBarItemData(
            icon: Icons.settings,
            label: 'Impostazioni',
          ),
        ],
        currentIndex: 0,
        onTap: (_) {},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AvisScaffold(
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession,
            title: 'Con Nav',
            body: const Text('Body test'),
            bottomNavData: bottomNavData,
          ),
        ),
      );

      expect(find.text('Con Nav'), findsOneWidget);
      expect(find.text('Body test'), findsOneWidget);

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Impostazioni'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('drawer opens and contains user name and role', (tester) async {
      operatorSession.setState(name: 'Mario Rossi', admin: true, active: true);

      await tester.pumpWidget(
        MaterialApp(
          home: AvisScaffold(
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession,
            title: 'Drawer Test',
            body: const SizedBox(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('Amministratore'), findsOneWidget);
    });
  });
}
