import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Seez-inspired theme with parchment background and warm brown tones
/// Based on the theme from the Seez MCP application
class SeezTheme {
  // Colors
  static const Color parchmentBackground = Color(0xFFFAF5ED);
  static const Color primaryBrown = Color(0xFFBC8B60);
  static const Color darkBrownText = Color(0xFF2C1810);
  static const Color charcoalHeader = Color(0xFF2D3436);
  static const Color mediumBrownBorder = Color(0xFFC8B8A8);
  static const Color lightCreamTile = Color(0xFFF8F1E8);
  static const Color lightBeigeGradient1 = Color(0xFFF1E4D5);
  static const Color lightBeigeGradient2 = Color(0xFFE8DCC8);
  static const Color subtitleBrown = Color(0xFF4A3C28);
  static const Color subtitleBlue = Color(0xFF2ABAC8);

  // Pastel colors for metrics and accent elements
  static const Color pastelBlue = Color(0xFFB8D4E8);
  static const Color pastelGreen = Color(0xFFB8E8D4);
  static const Color pastelOrange = Color(0xFFE8D4B8);
  static const Color pastelPink = Color(0xFFE8B8D4);
  static const Color pastelLime = Color(0xFFD4E8B8);
  static const Color pastelCoral = Color(0xFFE8C4B8);
  static const Color pastelPurple = Color(0xFFD4B8E8);
  static const Color pastelRed = Color(0xFFE8B8B8);

  // Error/Danger colors
  static const Color danger = Color(0xFFCF222E);
  static const Color dangerLight = Color(0xFFFFEBEE);

  // Border radius values
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Spacing values
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing30 = 30.0;
  static const double spacing40 = 40.0;

  // Text Styles - Headers (Old Standard TT via Google Fonts)
  static TextStyle get heroTitle => GoogleFonts.oldStandardTt(
    color: darkBrownText,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle get pageHeaderTitle => GoogleFonts.oldStandardTt(
    color: darkBrownText,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static TextStyle get sectionTitle => GoogleFonts.oldStandardTt(
    color: primaryBrown,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get navBarTitle => GoogleFonts.oldStandardTt(
    color: darkBrownText,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get navBarTitleBold => GoogleFonts.oldStandardTt(
    color: primaryBrown,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get sectorCardTitle => GoogleFonts.oldStandardTt(
    color: darkBrownText,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get metricGridTitle => GoogleFonts.oldStandardTt(
    color: primaryBrown,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get metricValue => GoogleFonts.oldStandardTt(
    color: primaryBrown,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get metricLabel => GoogleFonts.oldStandardTt(
    fontWeight: FontWeight.w600,
    color: darkBrownText,
    fontSize: 12,
  );

  // Body Text Styles (Inter)
  static TextStyle bodyText(bool isSmallScreen) => GoogleFonts.inter(
    color: darkBrownText,
    fontSize: isSmallScreen ? 18.0 : 15.0,
    height: 1.6,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get heroSubtitle => GoogleFonts.inter(
    color: subtitleBrown,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get pageHeaderSubtitle => GoogleFonts.inter(
    color: subtitleBrown,
    fontSize: 17,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    color: parchmentBackground,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Decorations
  static BoxDecoration get gradientHeaderDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [lightBeigeGradient1, lightBeigeGradient2],
    ),
    border: Border(
      bottom: BorderSide(color: mediumBrownBorder, width: 2),
    ),
  );

  static BoxDecoration get navBarDecoration => const BoxDecoration(
    color: lightBeigeGradient2,
    border: Border(
      bottom: BorderSide(color: mediumBrownBorder, width: 1),
    ),
  );

  static BoxDecoration sectorCardDecoration() => BoxDecoration(
    color: lightBeigeGradient1,
    border: Border.all(color: mediumBrownBorder, width: 2),
    borderRadius: BorderRadius.circular(borderRadiusMedium),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration buttonDecoration() => BoxDecoration(
    color: primaryBrown,
    borderRadius: BorderRadius.circular(borderRadiusSmall),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration metricTileDecoration() => BoxDecoration(
    color: lightCreamTile,
    border: Border.all(color: mediumBrownBorder, width: 2),
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get contentSectionBorder => const BoxDecoration(
    border: Border(
      bottom: BorderSide(color: lightBeigeGradient2, width: 1),
    ),
  );

  /// Light theme with parchment background and warm tones
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,

      colorScheme: const ColorScheme.light(
        primary: primaryBrown,
        secondary: subtitleBlue,
        surface: lightCreamTile,
        error: pastelRed,
        onPrimary: parchmentBackground,
        onSecondary: Colors.white,
        onSurface: darkBrownText,
        onError: darkBrownText,
      ),

      scaffoldBackgroundColor: parchmentBackground,

      appBarTheme: AppBarTheme(
        backgroundColor: lightBeigeGradient2,
        foregroundColor: darkBrownText,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryBrown),
        titleTextStyle: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: lightCreamTile,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          side: const BorderSide(color: mediumBrownBorder, width: 2),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: mediumBrownBorder,
        thickness: 1,
        space: 1,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        displaySmall: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
        headlineLarge: GoogleFonts.oldStandardTt(
          color: primaryBrown,
          fontSize: 26,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.oldStandardTt(
          color: primaryBrown,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineSmall: GoogleFonts.oldStandardTt(
          color: primaryBrown,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        titleLarge: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.oldStandardTt(
          color: darkBrownText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.inter(
          color: darkBrownText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: darkBrownText,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          color: subtitleBrown,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCreamTile,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: mediumBrownBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: mediumBrownBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: primaryBrown, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrown,
          foregroundColor: parchmentBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24,
            vertical: spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusSmall),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing8,
        ),
        dense: false,
        selectedColor: primaryBrown,
        selectedTileColor: lightBeigeGradient1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
        ),
      ),

      iconTheme: const IconThemeData(
        color: primaryBrown,
        size: 20,
      ),
    );
  }
}
