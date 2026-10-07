import 'package:flutter/material.dart';

/// Palet MEIRA: sage yang tenang di atas putih hangat, dengan sedikit pastel sebagai aksen.
class C {
  static const bg = Color(0xFFF7F6F2); // latar utama, putih hangat
  static const surface = Color(0xFFFFFFFF);
  static const grouped = Color(0xFFF0EFEA); // latar daftar berkelompok, kolom input
  static const label = Color(0xFF1D1F1C);
  static const secondary = Color(0xFF6E736C);
  static const tertiary = Color(0xFFA6AAA2);
  static const separator = Color(0xFFE5E3DC);

  static const sage = Color(0xFF7C9A7E);
  static const sageDeep = Color(0xFF4F6B53);
  static const sageTint = Color(0xFFE8EEE6);

  // pastel, dipakai hemat
  static const butter = Color(0xFFF3E7B8);
  static const blush = Color(0xFFF2DED6);
  static const clay = Color(0xFFB8664F); // peringatan lembut
}

TextStyle inter(double size, {FontWeight weight = FontWeight.w400, Color color = C.label, double? height, double? spacing}) => TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      fontVariations: [FontVariation('wght', weight.value.toDouble())],
      color: color,
      height: height,
      letterSpacing: spacing,
    );

TextStyle poppins(double size, {FontWeight weight = FontWeight.w600, Color color = C.label, double? height, double? spacing}) =>
    TextStyle(fontFamily: 'Poppins', fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

/// Skala tipografi bergaya iOS.
class T {
  static TextStyle largeTitle = poppins(30, weight: FontWeight.w600, height: 1.15, spacing: -.4);
  static TextStyle title = poppins(21, weight: FontWeight.w600, height: 1.2, spacing: -.2);
  static TextStyle headline = inter(16.5, weight: FontWeight.w600, height: 1.3);
  static TextStyle body = inter(16, height: 1.45);
  static TextStyle callout = inter(15, height: 1.4);
  static TextStyle subhead = inter(14, color: C.secondary, height: 1.35);
  static TextStyle footnote = inter(13, color: C.secondary, height: 1.3);
  static TextStyle caption = inter(12, color: C.secondary);
  static TextStyle sectionHeader = inter(12.5, weight: FontWeight.w600, color: C.secondary, spacing: .3);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: C.sage, primary: C.sageDeep, surface: C.surface, onSurface: C.label, error: C.clay);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'Inter', splashFactory: NoSplash.splashFactory);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    dividerColor: C.separator,
    dividerTheme: const DividerThemeData(color: C.separator, thickness: .6, space: .6),
    highlightColor: C.sageTint.withValues(alpha: .5),
    appBarTheme: AppBarTheme(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: C.label,
      titleTextStyle: T.headline,
      centerTitle: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: C.sageDeep,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        textStyle: inter(16, weight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: C.sageDeep, textStyle: inter(16, weight: FontWeight.w500)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.grouped,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      hintStyle: inter(16, color: C.tertiary),
      labelStyle: inter(14, color: C.secondary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.sage : C.separator),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: C.label,
      contentTextStyle: inter(15, color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: C.separator,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: C.sage, linearTrackColor: C.separator),
  );
}

/// Kartu putih dengan sudut lembut dan bayangan nyaris tak terlihat.
BoxDecoration card({double radius = 18}) => BoxDecoration(
      color: C.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 2))],
    );
