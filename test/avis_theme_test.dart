import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donor_app/helpers/avis_theme.dart';

void main() {
  group('AvisTheme', () {
    test('AvisColors values are correct', () {
      expect(AvisColors.green, const Color(0xFF007A33));
      expect(AvisColors.blue, const Color(0xFF002A5C));
      expect(AvisColors.red, const Color(0xFFE10600));
      expect(AvisColors.white, Colors.white);
      expect(AvisColors.grey, const Color(0xFFEEEEEE));
      expect(AvisColors.darkGrey, const Color(0xFF555555));
      expect(AvisColors.warmGrey, const Color(0xFF888066));
      expect(AvisColors.amber, Colors.amber);
      expect(AvisColors.text, Colors.black);
      expect(AvisColors.smallText, Colors.black87);
      expect(AvisColors.overlay, Colors.black45);
      expect(AvisColors.hoverBackground, const Color(0xFFF5F5F5));
    });

    test('AvisTheme.smallTextStyle is correct', () {
      expect(AvisTheme.smallTextStyle.fontSize, 12);
    });

    test('AvisTheme.errorTextStyle is correct', () {
      expect(AvisTheme.errorTextStyle.color, AvisColors.red);
      expect(AvisTheme.errorTextStyle.fontWeight, FontWeight.bold);
    });

    test('AvisTheme.light ThemeData has correct properties', () {
      final theme = AvisTheme.light;

      expect(theme.primaryColor, AvisColors.blue);
      expect(theme.scaffoldBackgroundColor, AvisColors.white);

      // AppBarTheme
      expect(theme.appBarTheme.backgroundColor, AvisColors.blue);
      expect(theme.appBarTheme.foregroundColor, AvisColors.white);

      // ElevatedButtonTheme
      final elevatedButtonStyle = theme.elevatedButtonTheme.style;
      expect(elevatedButtonStyle, isNotNull);

      final backgroundColor = elevatedButtonStyle!.backgroundColor?.resolve({});
      final foregroundColor = elevatedButtonStyle.foregroundColor?.resolve({});
      final textStyle = elevatedButtonStyle.textStyle?.resolve({});

      expect(backgroundColor, AvisColors.red);
      expect(foregroundColor, AvisColors.white);
      expect(textStyle?.fontWeight, FontWeight.bold);

      // CardTheme
      expect(theme.cardTheme.color, AvisColors.white);
      expect(theme.cardTheme.elevation, 4);
      expect(theme.cardTheme.margin, const EdgeInsets.all(16));
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      expect(shape.side.color, AvisColors.blue);
      expect(shape.side.width, 2);
      expect(shape.borderRadius, BorderRadius.circular(12.0));

      // InputDecorationTheme
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
      expect(
          theme.inputDecorationTheme.focusedBorder, isA<OutlineInputBorder>());
      expect(
        (theme.inputDecorationTheme.focusedBorder as OutlineInputBorder)
            .borderSide
            .color,
        AvisColors.blue,
      );
      expect(theme.inputDecorationTheme.labelStyle?.color, AvisColors.blue);
      expect(theme.inputDecorationTheme.floatingLabelStyle?.color,
          AvisColors.blue);

      // TextTheme
      expect(theme.textTheme.bodyMedium?.color, AvisColors.text);
      expect(theme.textTheme.bodySmall?.color, AvisColors.smallText);

      // ListTileTheme
      expect(theme.listTileTheme.selectedColor, AvisColors.green);
      expect(theme.listTileTheme.selectedTileColor, AvisColors.grey);
      expect(
        theme.listTileTheme.contentPadding,
        const EdgeInsets.symmetric(horizontal: 16.0),
      );

      // ProgressIndicatorTheme
      expect(theme.progressIndicatorTheme.color, AvisColors.blue);

      // SnackBarTheme
      expect(theme.snackBarTheme.backgroundColor, AvisColors.darkGrey);
      expect(theme.snackBarTheme.contentTextStyle?.color, AvisColors.white);

      // DialogTheme
      expect(theme.dialogTheme.shape, isA<RoundedRectangleBorder>());
      expect(theme.dialogTheme.titleTextStyle?.color, AvisColors.blue);
      expect(theme.dialogTheme.contentTextStyle?.color, AvisColors.smallText);

      // TabBarTheme
      expect(theme.tabBarTheme.labelColor, AvisColors.red);
      expect(theme.tabBarTheme.unselectedLabelColor, AvisColors.darkGrey);
      expect(theme.tabBarTheme.indicator, isA<UnderlineTabIndicator>());

      // DividerTheme
      expect(theme.dividerTheme.color, AvisColors.grey);
      expect(theme.dividerTheme.thickness, 1);
    });
  });
}
