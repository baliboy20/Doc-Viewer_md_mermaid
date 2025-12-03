import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Florence application theme inspired by GitHub Desktop
/// Color palette extracted from GitHub Desktop UI
class AppTheme {
  // Primary colors from GitHub Desktop
  static const Color primaryBlue = Color(0xFF0969DA); // GitHub blue
  static const Color primaryBlueHover = Color(0xFF0860CA);
  static const Color darkBackground = Color(0xFF22272E); // Dark sidebar
  static const Color darkerBackground = Color(0xFF1C2128); // Darker areas
  static const Color lightBackground = Color(0xFFFFFFFF); // Light content area
  static const Color lighterBackground = Color(0xFFF6F8FA); // Lighter sections

  // Text colors
  static const Color textPrimary = Color(0xFF24292F); // Dark text
  static const Color textSecondary = Color(0xFF57606A); // Gray text
  static const Color textOnDark = Color(0xFFADBACB); // Text on dark bg
  static const Color textMuted = Color(0xFF656D76);

  // Border and divider colors
  static const Color border = Color(0xFFD0D7DE);
  static const Color borderDark = Color(0xFF373E47);
  static const Color divider = Color(0xFFE1E4E8);

  // Accent colors
  static const Color success = Color(0xFF1A7F37); // Green
  static const Color successLight = Color(0xFFDCFFE4);
  static const Color warning = Color(0xFFBF8700); // Yellow
  static const Color danger = Color(0xFFCF222E); // Red
  static const Color dangerLight = Color(0xFFFFEBEE);

  // Selection and hover colors
  static const Color selectedItem = Color(0xFFEBF0F4);
  static const Color hoverItem = Color(0xFFF3F4F6);
  static const Color focusBorder = Color(0xFF0969DA);

  /// Light theme matching GitHub Desktop's light mode
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: lightBackground,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: lighterBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: textSecondary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      cardTheme: CardThemeData(
        color: lightBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w400),
        titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w400),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w400),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lighterBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: focusBorder, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        dense: true,
        selectedColor: primaryBlue,
        selectedTileColor: selectedItem,
      ),

      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 16,
      ),
    );
  }

  /// Dark theme matching GitHub Desktop's dark mode
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: primaryBlue,
        surface: darkBackground,
        error: danger,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textOnDark,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: darkerBackground,

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: textOnDark,
        elevation: 0,
        iconTheme: IconThemeData(color: textOnDark),
      ),

      cardTheme: CardThemeData(
        color: darkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: borderDark, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
      ),

      iconTheme: const IconThemeData(
        color: textOnDark,
        size: 16,
      ),
    );
  }
}
