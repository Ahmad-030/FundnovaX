import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF3ECFCF);
  static const Color accent = Color(0xFFFF6584);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);

  // Category colors
  static const Color food = Color(0xFFFF6584);
  static const Color transport = Color(0xFF6C63FF);
  static const Color shopping = Color(0xFF3ECFCF);
  static const Color bills = Color(0xFFFF9800);
  static const Color other = Color(0xFF9C27B0);
  static const Color income = Color(0xFF4CAF50);

  static const List<Color> gradientPrimary = [Color(0xFF6C63FF), Color(0xFF3ECFCF)];
  static const List<Color> gradientDark = [Color(0xFF1A1A2E), Color(0xFF16213E)];
  static const List<Color> gradientAccent = [Color(0xFFFF6584), Color(0xFFFF9800)];
  static const List<Color> gradientGreen = [Color(0xFF4CAF50), Color(0xFF3ECFCF)];

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: const Color(0xFFF8F7FF),
        background: const Color(0xFFF0EFFF),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: primary.withOpacity(0.1),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary, foregroundColor: Colors.white, elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF0EFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFFB0B0C8),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: const Color(0xFF16213E),
        background: const Color(0xFF0F0F1A),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color(0xFF1A1A2E),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary, foregroundColor: Colors.white, elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF16213E),
        selectedItemColor: secondary,
        unselectedItemColor: Color(0xFF555577),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
