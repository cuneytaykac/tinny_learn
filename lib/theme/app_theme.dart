import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFB74D), // Orange
      brightness: Brightness.light,
      surface: const Color(0xFFFFF8E1), // Light Yellow background
    ),
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    textTheme:
        GoogleFonts.quicksandTextTheme(), // Rounded font with great Turkish support
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5D4037), // Dark Brown
      ),
      iconTheme: const IconThemeData(color: Color(0xFF5D4037)),
    ),
  );

  static const Color primaryTextColor = Color(0xFF5D4037);
  static const Color accentColor = Color(0xFFFF7043); // Deep Orange
}
