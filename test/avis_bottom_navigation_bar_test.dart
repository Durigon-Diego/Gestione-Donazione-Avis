import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/components/avis_bottom_navigation_bar.dart';

void main() {
  group('AvisBottomNavigationBarData', () {
    test('should correctly assign all provided values', () {
      final items = [
        const BottomNavigationBarItemData(icon: Icons.home, label: 'Home'),
        const BottomNavigationBarItemData(
            icon: Icons.settings, label: 'Settings'),
      ];

      int tappedIndex = -1;
      void onTap(int index) => tappedIndex = index;

      final data = AvisBottomNavigationBarData(
        items: items,
        currentIndex: 1,
        onTap: onTap,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.shifting,
      );

      expect(data.items, equals(items));
      expect(data.currentIndex, equals(1));
      expect(data.showUnselectedLabels, isFalse);
      expect(data.type, equals(BottomNavigationBarType.shifting));

      data.onTap(0);
      expect(tappedIndex, equals(0));
    });

    test('should use default values for optional parameters', () {
      final items = [
        const BottomNavigationBarItemData(icon: Icons.search, label: 'Search'),
      ];

      void onTap(int index) {}

      final data = AvisBottomNavigationBarData(
        items: items,
        currentIndex: 0,
        onTap: onTap,
      );

      expect(data.showUnselectedLabels, isTrue);
      expect(data.type, equals(BottomNavigationBarType.fixed));
    });
  });

  group('AvisBottomNavigationBar', () {
    testWidgets(
        'should build BottomNavigationBar with correct items and properties',
        (WidgetTester tester) async {
      final items = [
        const BottomNavigationBarItemData(icon: Icons.home, label: 'Home'),
        const BottomNavigationBarItemData(
            icon: Icons.settings, label: 'Settings'),
      ];

      int tappedIndex = -1;
      void onTap(int index) => tappedIndex = index;

      final data = AvisBottomNavigationBarData(
        items: items,
        currentIndex: 0,
        onTap: onTap,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AvisBottomNavigationBar(data: data),
          ),
        ),
      );

      // Verify that the BottomNavigationBar has the correct number of items
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      // Tap on the second item and verify onTap is called
      await tester.tap(find.byIcon(Icons.settings));
      expect(tappedIndex, equals(1));
    });
  });
}
