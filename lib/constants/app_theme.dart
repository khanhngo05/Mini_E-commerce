import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryOrange = Color(0xFFE53935);
  static const Color primaryRed = primaryOrange;
  static const Color badgeRed = Color(0xFFD50000);
  static const Color lightBackground = Color(0xFFF5F5F5);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: lightBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryOrange,
        secondary: const Color(0xFFFF6B6B),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF222222),
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
