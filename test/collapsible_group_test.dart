import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/components/collapsible_group.dart';

Widget fakeBuilder(String text) {
  return ListTile(
    title: Text(text),
  );
}

void main() {
  group('CollapsibleGroup', () {
    testWidgets('renders nothing when visible is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup<String>(
              title: 'This should not be visible',
              data: [],
              elementBuilder: fakeBuilder,
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
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup<String>(
              title: 'This should be visible',
              data: [],
              elementBuilder: fakeBuilder,
            ),
          ),
        ),
      );

      expect(find.text('This should be visible'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('can collapse and expand when tapping header',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup<String>(
              title: 'List',
              data: [
                'Element 1',
                'Element 2',
                'Element 3',
              ],
              elementBuilder: fakeBuilder,
            ),
          ),
        ),
      );

      expect(find.text('Element 1'), findsOneWidget);
      expect(find.text('Element 2'), findsOneWidget);
      expect(find.text('Element 3'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      expect(find.text('Element 1'), findsNothing);
      expect(find.text('Element 2'), findsNothing);
      expect(find.text('Element 3'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      expect(find.text('Element 1'), findsOneWidget);
      expect(find.text('Element 2'), findsOneWidget);
      expect(find.text('Element 3'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });

    testWidgets('respects initialExpanded = false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleGroup<String>(
              title: 'List',
              data: [
                'Element 1',
                'Element 2',
                'Element 3',
              ],
              elementBuilder: fakeBuilder,
              initialExpanded: false,
            ),
          ),
        ),
      );

      expect(find.text('Element 1'), findsNothing);
      expect(find.text('Element 2'), findsNothing);
      expect(find.text('Element 3'), findsNothing);
      expect(find.byIcon(Icons.expand_more), findsOneWidget);

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();

      expect(find.text('Element 1'), findsOneWidget);
      expect(find.text('Element 2'), findsOneWidget);
      expect(find.text('Element 3'), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
    });
  });
}
