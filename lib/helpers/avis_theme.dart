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
      border: OutlineInputBorder(),
      labelStyle: TextStyle(color: AvisColors.blue),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black87),
    ),
  );
}
