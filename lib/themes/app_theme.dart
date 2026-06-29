import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFD4AF37); // Classic DAHUSTLA Luxury Metallic Gold
  static const Color cardBg = Color(0xFF111111);
  static const Color cardBorder = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF888888);

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: primaryGold,
      surface: cardBg,
    ),
  );
}