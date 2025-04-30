import 'package:flutter/material.dart';

/// AVIS color palette
class AvisColors {
  static const Color green = Color(0xFF007A33);
  static const Color blue = Color(0xFF002A5C);
  static const Color red = Color(0xFFE10600);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFFEEEEEE);
  static const Color darkGrey = Color(0xFF555555);
  static const Color warmGrey = Color(0xFF888066);
  static const Color amber = Colors.amber;
  static const Color text = Colors.black;
  static const Color smallText = Colors.black87;
  static const Color overlay = Colors.black45;
  static const Color hoverBackground = Color(0xFFF5F5F5); // hover grigio chiaro
}

/// AVIS Theme definition
class AvisTheme {
  static const TextStyle smallTextStyle = TextStyle(fontSize: 12);
  static const TextStyle errorTextStyle = TextStyle(
    color: AvisColors.red,
    fontWeight: FontWeight.bold,
  );
  static final ThemeData light = ThemeData(
    fontFamily: 'Helvetica',
    primaryColor: AvisColors.blue,
    scaffoldBackgroundColor: AvisColors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AvisColors.blue,
      foregroundColor: AvisColors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AvisColors.red,
        foregroundColor: AvisColors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: CardTheme(
      color: AvisColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AvisColors.blue, width: 2),
      ),
      elevation: 4,
      margin: const EdgeInsets.all(16),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AvisColors.blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AvisColors.blue, width: 2.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AvisColors.blue),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AvisColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AvisColors.red, width: 2.0),
      ),
      labelStyle: TextStyle(color: AvisColors.blue),
      floatingLabelStyle: TextStyle(color: AvisColors.blue),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AvisColors.text),
      bodySmall: TextStyle(color: AvisColors.smallText),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AvisColors.blue,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AvisColors.darkGrey,
      contentTextStyle: TextStyle(color: AvisColors.white),
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AvisColors.blue,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: AvisColors.smallText,
      ),
    ),
    tabBarTheme: const TabBarTheme(
      labelColor: AvisColors.red,
      unselectedLabelColor: AvisColors.darkGrey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AvisColors.red, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AvisColors.grey,
      thickness: 1,
    ),
    listTileTheme: const ListTileThemeData(
      selectedColor: AvisColors.green,
      selectedTileColor: AvisColors.grey,
      tileColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
    ),
  );
}
