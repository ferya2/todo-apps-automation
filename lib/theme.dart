import 'package:flutter/material.dart';

/// App-wide theme configuration: Material 3 colors and typography.
class AppTheme {
  const AppTheme._();

  /// The light theme used across the app.
  static ThemeData get light {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
    );

    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
