import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Premium Color Palette ─────────────────────────────────────────
class AppColors {
  // Backgrounds - Premium gradient base
  static const background = Color(0xFFFAFAFA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFF8F8F8);
  static const surfaceContainerHigh = Color(0xFFF0F0F0);
  static const surfaceContainerHighest = Color(0xFFE8E8E8);

  // Sidebar
  static const sidebarBg = Color(0xFFFFFFFF);
  static const sidebarHover = Color(0xFFF5F5F5);

  // Accent — Premium coral/orange gradient
  static const accent = Color(0xFFE8642C);
  static const accentLight = Color(0xFFF07A4A);
  static const accentMuted = Color(0xFFD4551F);
  static const accentSurface = Color(0x14E8642C);

  // Text - High contrast
  static const textPrimary = Color(0xFF0F0F0F);
  static const textSecondary = Color(0xFF525252);
  static const textTertiary = Color(0xFF8A8A8A);

  // Semantic
  static const positive = Color(0xFF16A34A);
  static const positiveLight = Color(0xFFDCFCE7);
  static const negative = Color(0xFFDC2626);
  static const negativeLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF2563EB);
  static const infoLight = Color(0xFFDBEAFE);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFEF3C7);

  // Borders & dividers
  static const border = Color(0xFFE5E5E5);
  static const borderSubtle = Color(0xFFF0F0F0);

  // Category palette — Premium refined colors
  static const categoryColors = <String, Color>{
    // Food & Drink
    'Dining': Color(0xFFE07A6E),
    'Grocery': Color(0xFF6ABB8A),

    // Shopping & General Merchandise
    'Shopping': Color(0xFFBD82D6),
    'Superstore': Color(0xFF6BA3D6),

    // Transportation
    'Transit': Color(0xFFD4A853),
    'Gas': Color(0xFFA68E7A),

    // Home & Living
    'Rent': Color(0xFFB07D62),
    'Utilities': Color(0xFF7A9BAE),

    // Financial
    'Transfer': Color(0xFF8DB580),
    'Fee': Color(0xFF8A8C94),
    'Loan': Color(0xFFB88A6E),

    // Entertainment & Leisure
    'Entertainment': Color(0xFFD680B0),
    'Travel': Color(0xFF5CBAA3),
    'Subscription': Color(0xFF8A8DE0),

    // Health & Personal Care
    'Medical': Color(0xFFE09878),
    'Personal Care': Color(0xFFD8A8C4),

    // Services & Professional
    'Professional Services': Color(0xFF9CA8B8),
    'Education': Color(0xFF88B5D6),

    // Uncategorized
    'Uncategorized': Color(0xFF9B9B9B),
  };
}

// ── Premium Theme Builder ─────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  final textTheme = GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.dmSans(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.dmSans(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.0,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.dmSans(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.dmSans(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
    ),
    labelLarge: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.8,
    ),
    labelSmall: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textTertiary,
      letterSpacing: 1.0,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: textTheme,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentMuted,
      onSecondary: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.negative,
      onError: Colors.white,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(
        fontSize: 14,
        color: AppColors.textTertiary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.accent, width: 2.5),
      ),
      labelStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
  );
}
