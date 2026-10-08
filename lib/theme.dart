import 'package:flutter/material.dart';

/// Palet MEIRA: putih kebiruan yang sejuk, hijau tosca sebagai warna utama, ungu dan biru sebagai aksen.
/// Tanpa oranye dan tanpa hitam; teks memakai biru tua agar tetap mudah dibaca.
class C {
  static const bg = Color(0xFFF5F8FB); // latar utama
  static const surface = Color(0xFFFFFFFF);
  static const grouped = Color(0xFFEEF3F8); // kolom input dan latar berkelompok
  static const label = Color(0xFF1F2A44); // biru tua untuk teks
  static const secondary = Color(0xFF66748C);
  static const tertiary = Color(0xFFA7B1C2);
  static const separator = Color(0xFFE3E9F1);

  static const accent = Color(0xFF1FA58E); // hijau tosca: tombol utama, penanda
  static const accentDeep = Color(0xFF13806D); // teks beraksen di atas latar terang
  static const accentTint = Color(0xFFE2F5F1);
  static const violet = Color(0xFF7C6CF2); // aksen kedua: pesan pengguna, sorotan
  static const violetTint = Color(0xFFEEEBFF);
  static const blue = Color(0xFF3D8BFD);
  static const herb = Color(0xFF3BAA6E); // hijau daun: bahan tersedia, langkah selesai
  static const herbTint = Color(0xFFE6F5EC);
  static const ink = Color(0xFF1F2A44); // dipertahankan untuk kompatibilitas; sama dengan warna teks

  static const butter = Color(0xFFFFF1C2);
  static const clay = Color(0xFFD64560); // peringatan, merah muda tua
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
  final scheme = ColorScheme.fromSeed(seedColor: C.accent, primary: C.accent, surface: C.surface, onSurface: C.label, error: C.clay);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme, fontFamily: 'Inter', splashFactory: NoSplash.splashFactory);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    // perpindahan halaman: halaman baru masuk dari kanan sambil memudar, halaman lama bergeser sedikit
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder(), TargetPlatform.linux: FadeForwardsPageTransitionsBuilder()},
    ),
    dividerColor: C.separator,
    dividerTheme: const DividerThemeData(color: C.separator, thickness: .6, space: .6),
    highlightColor: C.accentTint.withValues(alpha: .5),
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
        backgroundColor: C.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 54),
        textStyle: inter(16, weight: FontWeight.w600),
        shape: const StadiumBorder(),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: C.accentDeep,
        textStyle: inter(16, weight: FontWeight.w500),
      ),
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
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accent : C.separator),
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
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: C.accent, linearTrackColor: C.separator),
  );
}

/// Kartu putih dengan sudut lembut dan bayangan tipis.
BoxDecoration card({double radius = 22}) => BoxDecoration(
  color: C.surface,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [BoxShadow(color: Color(0x141F2A44), blurRadius: 18, offset: Offset(0, 6))],
);
