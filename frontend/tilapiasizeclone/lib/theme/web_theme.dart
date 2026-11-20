import 'package:flutter/material.dart';

import 'web_colors.dart';

abstract final class WebTheme {
  static final data = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: WebColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WebColors.accent,
      primary: WebColors.accent,
      secondary: WebColors.card,
      surface: WebColors.surface,
      brightness: Brightness.dark,
    ),
  );
}
