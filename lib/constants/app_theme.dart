import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryOrange = Color(0xFFEE4D2D);
  static const Color lightBackground = Color(0xFFF5F5F5);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: lightBackground,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryOrange,
        secondary: const Color(0xFFFE635E),
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
