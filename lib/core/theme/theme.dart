import 'package:flutter/material.dart';

class AppTheme {
  static const brandColor = Color(0xFFBC2626);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.white,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: brandColor,
          brightness: Brightness.light,
        ).copyWith(
          primary: brandColor,
          secondary: const Color(0xFFD55757),
          surface: Colors.white,
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF151A2D),
      elevation: 0,
      centerTitle: true,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: brandColor,
      contentTextStyle: TextStyle(
        color: Colors.white,
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(
        color: Color(0xFF99A1AA),
        fontSize: 14,
        fontFamily: 'Roboto',
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7EAF0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7EAF0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandColor, width: 1.2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandColor,
        foregroundColor: Colors.white,
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
