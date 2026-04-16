import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

extension AppThemeExtension on BuildContext {
  AppThemeData get theme => AppTheme.themeOf(this);
}

class AppThemeData {
  final bool isDark;
  const AppThemeData(this.isDark);

  Color get background => isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
  Color get surface => isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get surfaceLight => isDark ? AppTheme.darkSurfaceLight : AppTheme.lightSurfaceLight;
  Color get surfaceLighter => isDark ? AppTheme.darkSurfaceLighter : AppTheme.lightSurfaceLighter;
  Color get border => isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
  Color get textPrimary => isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
  Color get textSecondary => isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
  Color get textMuted => isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted;

  Color get accent => AppTheme.accent;
  Color get accentLight => AppTheme.accentLight;
  Color get accentDark => AppTheme.accentDark;
  Color get success => AppTheme.success;
  Color get warning => AppTheme.warning;
  Color get error => AppTheme.error;
  Color get info => AppTheme.info;
}

class AppTheme {
  // ── Dark palette ──────────────────────────────────────────────────────────
  static const Color darkBackground   = Color(0xFF0A0D14);
  static const Color darkSurface      = Color(0xFF111827);
  static const Color darkSurfaceLight = Color(0xFF1A2236);
  static const Color darkSurfaceLighter = Color(0xFF243044);
  static const Color darkBorder       = Color(0xFF1E2D40);
  static const Color darkTextPrimary  = Color(0xFFF1F5F9);
  static const Color darkTextSecondary= Color(0xFF94A3B8);
  static const Color darkTextMuted    = Color(0xFF475569);

  // ── Light palette ─────────────────────────────────────────────────────────
  static const Color lightBackground   = Color(0xFFF8F9FC);
  static const Color lightSurface      = Color(0xFFFFFFFF);
  static const Color lightSurfaceLight = Color(0xFFF1F5F9);
  static const Color lightSurfaceLighter = Color(0xFFE2E8F0);
  static const Color lightBorder       = Color(0xFFE2E8F0);
  static const Color lightTextPrimary  = Color(0xFF0F172A);
  static const Color lightTextSecondary= Color(0xFF475569);
  static const Color lightTextMuted    = Color(0xFF94A3B8);

  // ── Shared accent / semantic ───────────────────────────────────────────────
  static const Color accent      = Color(0xFFE8A045);
  static const Color accentLight = Color(0xFFFFBF6B);
  static const Color accentDark  = Color(0xFFB8732A);
  static const Color success     = Color(0xFF22C55E);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color error       = Color(0xFFEF4444);
  static const Color info        = Color(0xFF3B82F6);

  static AppThemeData themeOf(BuildContext context) {
    return AppThemeData(Theme.of(context).brightness == Brightness.dark);
  }

  // ── Theme builders ────────────────────────────────────────────────────────
  static ThemeData get darkTheme  => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg   = isDark ? darkBackground : lightBackground;
    final surf = isDark ? darkSurface : lightSurface;
    final brd  = isDark ? darkBorder : lightBorder;
    final sfl  = isDark ? darkSurfaceLight : lightSurfaceLight;
    final tp   = isDark ? darkTextPrimary : lightTextPrimary;
    final ts   = isDark ? darkTextSecondary : lightTextSecondary;
    final tm   = isDark ? darkTextMuted : lightTextMuted;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        secondary: accentLight,
        surface: surf,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: tp,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge:  GoogleFonts.inter(color: tp,  fontSize: 32, fontWeight: FontWeight.w700),
        displayMedium: GoogleFonts.inter(color: tp,  fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge:    GoogleFonts.inter(color: tp,  fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium:   GoogleFonts.inter(color: tp,  fontSize: 16, fontWeight: FontWeight.w500),
        bodyLarge:     GoogleFonts.inter(color: ts,  fontSize: 14),
        bodyMedium:    GoogleFonts.inter(color: ts,  fontSize: 13),
        bodySmall:     GoogleFonts.inter(color: tm,  fontSize: 12),
      ),
      cardTheme: CardThemeData(
        color: surf,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: brd, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: sfl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: brd),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: brd),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: ts, fontSize: 13),
        hintStyle:  GoogleFonts.inter(color: tm, fontSize: 13),
      ),
      dividerColor: brd,
    );
  }
}
