import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/components/collapsible_group.dart';

void main() {
  group('CollapsibleGroup', () {
    testWidgets('renders nothing when visible is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup(
              title: 'Admin',
              operators: const [],
              onTap: (_) {},
              visible: false,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('renders title and expands by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup(
              title: 'Operatori',
              operators: const [],
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Operatori'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('can collapse and expand when tapping header',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup(
              title: 'Operatori',
              operators: const [
                {'id': 1, 'first_name': 'Test', 'last_name': 'Guy'}
              ],
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Guy'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);

      await tester.tap(find.text('Operatori'));
      await tester.pumpAndSettle();

      expect(find.text('Test Guy'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.text('Operatori'));
      await tester.pumpAndSettle();

      expect(find.text('Test Guy'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('renders operator tiles and triggers onTap',
        (WidgetTester tester) async {
      Map<String, dynamic>? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup(
              title: 'Group',
              operators: const [
                {'id': 1, 'first_name': 'Mario', 'last_name': 'Rossi'},
                {'id': 2, 'first_name': 'Luca', 'last_name': 'Bianchi'},
              ],
              onTap: (op) => tapped = op,
            ),
          ),
        ),
      );

      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('Luca Bianchi'), findsOneWidget);

      await tester.tap(find.text('Mario Rossi'));
      await tester.pump();

      expect(tapped, isNotNull);
      expect(tapped!['first_name'], equals('Mario'));
    });

    testWidgets('respects initialExpanded = false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup(
              title: 'Group',
              operators: const [
                {'id': 1, 'first_name': 'Franco', 'last_name': 'Verdi'},
              ],
              onTap: (_) {},
              initialExpanded: false,
            ),
          ),
        ),
      );

      expect(find.text('Franco Verdi'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });
  });
}
