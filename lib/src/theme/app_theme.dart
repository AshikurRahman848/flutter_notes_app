import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(centerTitle: true),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: const TextStyle(color: Colors.black87),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    // Use a softer dark palette (not pitch black) so UI surfaces look less harsh.
    final seed = Colors.blue;
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      // Slightly lighter scaffold background than pure black for comfortable reading
      scaffoldBackgroundColor: const Color(0xFF121213),
      // Cards a bit lighter than scaffold to create subtle surface contrast
      cardColor: const Color(0xFF1E1F21),
      // AppBar use surfaceVariant so it blends with the dark scheme
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surfaceVariant,
        foregroundColor: scheme.onSurfaceVariant,
        elevation: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceVariant,
        contentTextStyle: TextStyle(color: scheme.onSurfaceVariant),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      dialogBackgroundColor: scheme.surface,
      dividerColor: scheme.onSurface.withOpacity(0.12),
    );
  }
}
