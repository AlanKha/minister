import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color Palette ─────────────────────────────────────────
class AppColors {
  // Backgrounds -  gradient base
  static const background = Color(0xFFF8F9FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFF3F4F6);
  static const surfaceContainerHigh = Color(0xFFE8EAED);
  static const surfaceContainerHighest = Color(0xFFDDE1E5);

  // Sidebar
  static const sidebarBg = Color(0xFFFFFFFF);
  static const sidebarHover = Color(0xFFF5F7FA);

  // Accent —  coral/orange gradient (enhanced)
  static const accent = Color(0xFFE85D3A);
  static const accentLight = Color(0xFFF06B4A);
  static const accentMuted = Color(0xFFD64F28);
  static const accentSurface = Color(0x12E85D3A);
  static const accentGlow = Color(0x08E85D3A);

  // Text - High contrast
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF4A4A5A);
  static const textTertiary = Color(0xFF8E8E9A);

  // Semantic
  static const positive = Color(0xFF10B981);
  static const positiveLight = Color(0xFFD1FAE5);
  static const negative = Color(0xFFEF4444);
  static const negativeLight = Color(0xFFFEE2E2);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);

  // Borders & dividers
  static const border = Color(0xFFE5E7EB);
  static const borderSubtle = Color(0xFFF0F2F5);

  // Shadows
  static const shadowColor = Color(0x0A000000);
  static const shadowColorStrong = Color(0x14000000);

  // Category palette —  refined colors
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

// ── Theme Builder ────────────────────────────────────────────────
ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);

  final textTheme = GoogleFonts.soraTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.sora(
      fontSize: 48,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -2.0,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.sora(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -1.5,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.sora(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -1.0,
    ),
    headlineLarge: GoogleFonts.sora(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.8,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
    ),
    headlineSmall: GoogleFonts.sora(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
    titleMedium: GoogleFonts.sora(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.sora(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    ),
    bodyLarge: GoogleFonts.sora(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    bodySmall: GoogleFonts.sora(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textTertiary,
    ),
    labelLarge: GoogleFonts.sora(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.3,
    ),
    labelMedium: GoogleFonts.sora(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.sora(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.textTertiary,
      letterSpacing: 0.8,
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
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.surfaceContainer,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.sora(
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
        side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
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
      side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      labelStyle: GoogleFonts.sora(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      hintStyle: GoogleFonts.sora(fontSize: 13, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.textTertiary,
      indicatorColor: AppColors.accent,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      labelStyle: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.sora(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceContainerHighest,
      contentTextStyle: GoogleFonts.sora(
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 20),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: GoogleFonts.sora(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.surfaceContainer),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
