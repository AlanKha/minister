import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Palette ──────────────────────────────────────────────
class AppColors {
  // Backgrounds
  static const surface = Color(0xFF0F1117);
  static const surfaceContainer = Color(0xFF181A20);
  static const surfaceContainerHigh = Color(0xFF1F2128);
  static const surfaceContainerHighest = Color(0xFF262830);

  // Accent — warm amber/gold
  static const accent = Color(0xFFE2A84B);
  static const accentMuted = Color(0xFFBF8A3A);
  static const accentSurface = Color(0x1AE2A84B); // 10% opacity

  // Text
  static const textPrimary = Color(0xFFF0EDE6);
  static const textSecondary = Color(0xFF9B9DA5);
  static const textTertiary = Color(0xFF636571);

  // Semantic
  static const positive = Color(0xFF5CB88A);
  static const negative = Color(0xFFE56B6F);
  static const info = Color(0xFF6BA3D6);

  // Borders & dividers
  static const border = Color(0xFF2A2C34);
  static const borderSubtle = Color(0xFF22242A);

  // Category palette — refined, desaturated tones
  static const categoryColors = <String, Color>{
    'Rent': Color(0xFFB07D62),
    'Travel': Color(0xFF5CBAA3),
    'Dining': Color(0xFFE07A6E),
    'Subscription': Color(0xFF8A8DE0),
    'Superstore': Color(0xFF6BA3D6),
    'Transit': Color(0xFFD4A853),
    'Entertainment': Color(0xFFD680B0),
    'Utilities': Color(0xFF7A9BAE),
    'Transfer': Color(0xFF8DB580),
    'Shopping': Color(0xFFBD82D6),
    'Gas': Color(0xFFA68E7A),
    'Health': Color(0xFFE09878),
    'Grocery': Color(0xFF6ABB8A),
    'Fee': Color(0xFF8A8C94),
    'N/A': Color(0xFF636571),
  };
}

// ── Theme Builder ──────────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.dmSans(
      fontSize: 44,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.dmSans(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.0,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.dmSans(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.dmSans(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
    ),
    labelLarge: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.8,
    ),
    labelSmall: GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textTertiary,
      letterSpacing: 1.0,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.surface,
    textTheme: textTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.surface,
      secondary: AppColors.accentMuted,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surfaceContainer,
      onSurface: AppColors.textPrimary,
      error: AppColors.negative,
      onError: AppColors.textPrimary,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainer,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceContainerHigh,
      selectedColor: AppColors.accentSurface,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 13,
        color: AppColors.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceContainerHighest,
      contentTextStyle: GoogleFonts.dmSans(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
  );
}
