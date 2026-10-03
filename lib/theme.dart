import 'package:flutter/material.dart';

/// Token warna aplikasi, satu set untuk light dan satu untuk dark.
class AppColors {
  final Color bg, surface, tint, ink, muted, line;
  final Color hero, heroSub, sky;
  final Color primary, onPrimary;
  final Color pop, onPop;
  final Color active, onActive, headline;

  const AppColors({
    required this.bg,
    required this.surface,
    required this.tint,
    required this.ink,
    required this.muted,
    required this.line,
    required this.hero,
    required this.heroSub,
    required this.sky,
    required this.primary,
    required this.onPrimary,
    required this.pop,
    required this.onPop,
    required this.active,
    required this.onActive,
    required this.headline,
  });

  static const light = AppColors(
    bg: Color(0xFFF2F5FB),
    surface: Color(0xFFFFFFFF),
    tint: Color(0xFFE4EEF9),
    ink: Color(0xFF1B1F5C),
    muted: Color(0xFF4F5A7D),
    line: Color(0xFFDDE4F0),
    hero: Color(0xFF1F2466),
    heroSub: Color(0xFFC9E3F6),
    sky: Color(0xFF8CC4EA),
    primary: Color(0xFF2A68A6),
    onPrimary: Color(0xFFFFFFFF),
    pop: Color(0xFFFFC857),
    onPop: Color(0xFF3A2A00),
    active: Color(0xFF1F2466),
    onActive: Color(0xFFFFFFFF),
    headline: Color(0xFF2A68A6),
  );

  static const dark = AppColors(
    bg: Color(0xFF0E1030),
    surface: Color(0xFF181B45),
    tint: Color(0xFF232766),
    ink: Color(0xFFF1F4FF),
    muted: Color(0xFFA9B4D6),
    line: Color(0xFF2C3070),
    hero: Color(0xFF2B3080),
    heroSub: Color(0xFFC9E3F6),
    sky: Color(0xFF8CC4EA),
    primary: Color(0xFF8CC4EA),
    onPrimary: Color(0xFF10143A),
    pop: Color(0xFFFFC857),
    onPop: Color(0xFF3A2A00),
    active: Color(0xFF8CC4EA),
    onActive: Color(0xFF10143A),
    headline: Color(0xFF8CC4EA),
  );

  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;
}

const Color kNavy = Color(0xFF1F2466);
const Color kInkOnSky = Color(0xFF10143A);

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2A68A6),
    brightness: brightness,
  ).copyWith(
    primary: c.primary,
    onPrimary: c.onPrimary,
    surface: c.surface,
    onSurface: c.ink,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
  );
}
