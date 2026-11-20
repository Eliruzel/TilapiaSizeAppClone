import 'package:flutter/material.dart';

import 'mobile_colors.dart';

abstract final class MobileTheme {
  static final data = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: MobileColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: MobileColors.accent,
      primary: MobileColors.accent,
      secondary: MobileColors.card,
      surface: MobileColors.surface,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: MobileColors.background,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: .10),
      hintStyle: const TextStyle(color: MobileColors.muted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0x29FFFFFF)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: MobileColors.accent, width: 1.5),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MobileColors.accent,
    ),
  );
}
