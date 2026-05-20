import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ─── Brand / Primary ───
  static const Color brand = Color(0xFF0F9D8A);       // Teal Green
  static const Color brandLight = Color(0xFF14B8A6);   // Cyan Teal
  static const Color brandDark = Color(0xFF0D8A79);    // Dark Teal

  // ─── Accent ───
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color rose = Color(0xFFEF4444);
  static const Color sky = Color(0xFF0EA5E9);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color orange = Color(0xFFF97316);

  // ─── Light Theme ───
  static const Color lightBg = Color(0xFFF4F7F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF8FAFB);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSub = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightShadow = Color(0x0A000000);

  // ─── Dark Theme ───
  static const Color darkBg = Color(0xFF0C1222);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkSurface2 = Color(0xFF1A2540);
  static const Color darkSurface3 = Color(0xFF213050);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextSub = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF1E2D45);
  static const Color darkBorderBright = Color(0xFF2D4060);
  static const Color darkShadow = Color(0x40000000);

  // ─── AMOLED ───
  static const Color blackBg = Color(0xFF000000);
  static const Color blackSurface = Color(0xFF0A0A0A);
  static const Color blackSurface2 = Color(0xFF111111);
  static const Color blackBorder = Color(0xFF1A1A1A);
}

class AppTheme {
  // Legacy color aliases (kept for backward compat)
  static const Color primaryTeal = AppColors.brand;
  static const Color primaryEmerald = AppColors.emerald;
  static const Color accentAmber = AppColors.amber;
  static const Color accentRed = AppColors.rose;
  static const Color accentIndigo = AppColors.brand;
  static const Color accentBlue = AppColors.sky;

  // ─── Typography ────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color text, Color sub) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 36, fontWeight: FontWeight.w800, color: text, letterSpacing: -1.0, height: 1.1),
      displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 30, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.8, height: 1.15),
      displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 24, fontWeight: FontWeight.w700, color: text, letterSpacing: -0.5, height: 1.2),
      headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 20, fontWeight: FontWeight.w600, color: text, letterSpacing: -0.3),
      headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w600, color: text, letterSpacing: -0.2),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: text),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: text),
      titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: text),
      bodyLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.normal, color: text, height: 1.6),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.normal, color: text, height: 1.5),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.normal, color: sub, height: 1.5),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: text),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: text),
      labelSmall: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500, color: sub, letterSpacing: 0.3),
    );
  }

  // ─── LIGHT THEME ──────────────────────────────────────────
  static ThemeData lightTheme() {
    const primary = AppColors.brand;
    const bg = AppColors.lightBg;
    const surface = AppColors.lightSurface;
    const text = AppColors.lightText;
    const sub = AppColors.lightTextSub;
    const border = AppColors.lightBorder;

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      dividerColor: border,
      textTheme: _buildTextTheme(text, sub),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: AppColors.emerald,
        tertiary: AppColors.sky,
        surface: surface,
        error: AppColors.rose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text,
        outline: border,
        primaryContainer: Color(0xFFE6F7F5),
        onPrimaryContainer: primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: AppColors.lightShadow,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: text, size: 22),
        titleTextStyle: GoogleFonts.spaceGrotesk(
            color: text, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.rose)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.rose, width: 2)),
        hintStyle: GoogleFonts.inter(color: sub, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: sub, fontSize: 14),
        prefixIconColor: sub,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE6F7F5),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: sub,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: primary, width: 2.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        shadowColor: AppColors.lightShadow,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? primary : sub);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
              color: states.contains(WidgetState.selected) ? primary : sub, size: 22);
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surface,
        titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18, fontWeight: FontWeight.w600, color: text),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        backgroundColor: surface,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : border),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }

  // ─── DARK THEME ───────────────────────────────────────────
  static ThemeData darkTheme() {
    const primary = AppColors.brandLight;
    const bg = AppColors.darkBg;
    const surface = AppColors.darkSurface;
    const surface2 = AppColors.darkSurface2;
    const text = AppColors.darkText;
    const sub = AppColors.darkTextSub;
    const border = AppColors.darkBorder;

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      dividerColor: border,
      textTheme: _buildTextTheme(text, sub),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: AppColors.emerald,
        tertiary: AppColors.sky,
        surface: surface,
        error: AppColors.rose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: text,
        outline: border,
        primaryContainer: Color(0xFF0A3D36),
        onPrimaryContainer: AppColors.brandLight,
        surfaceContainerHighest: surface2,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: text, size: 22),
        titleTextStyle: GoogleFonts.spaceGrotesk(
            color: text, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        toolbarHeight: 64,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.rose)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.rose, width: 2)),
        hintStyle: GoogleFonts.inter(color: sub, fontSize: 14),
        labelStyle: GoogleFonts.inter(color: sub, fontSize: 14),
        prefixIconColor: sub,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: AppColors.darkBorderBright),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: StadiumBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withOpacity(0.12),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: primary),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: sub,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? primary : sub);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
              color: states.contains(WidgetState.selected) ? primary : sub, size: 22);
        }),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: surface,
        titleTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 18, fontWeight: FontWeight.w600, color: text),
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        backgroundColor: surface,
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface2,
        contentTextStyle: GoogleFonts.inter(color: text, fontSize: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.darkBorderBright)),
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: sub,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : surface2),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primary),
    );
  }

  // ─── AMOLED BLACK THEME ───────────────────────────────────
  static ThemeData blackTheme() {
    final base = darkTheme();
    const primary = AppColors.brandLight;
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.blackBg,
      cardColor: AppColors.blackSurface,
      dividerColor: AppColors.blackBorder,
      appBarTheme: base.appBarTheme.copyWith(backgroundColor: AppColors.blackBg),
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.blackSurface,
        surfaceContainerHighest: AppColors.blackSurface2,
        outline: AppColors.blackBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.blackSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.blackBorder, width: 1),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: AppColors.blackSurface2,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blackBorder)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blackBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2)),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: AppColors.blackSurface,
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: AppColors.blackSurface,
      ),
    );
  }
}
