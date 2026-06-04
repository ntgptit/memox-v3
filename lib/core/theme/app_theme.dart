import 'package:flutter/material.dart';

/// Base application theme.
///
/// This is a minimal Material 3 seed-based theme so the app boots with a
/// coherent palette. It is intentionally a foundation only — the full MemoX
/// Design System (tokens, schemes, component themes under
/// `lib/core/theme/{tokens,schemes,component_themes}`) replaces this as those
/// layers are implemented. Seed matches `--memox-primary` (#5265F5) from
/// `docs/system-design/MemoX Design System/colors_and_type.css`.
abstract final class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF5265F5);
  static const String _fontFamily = 'Plus Jakarta Sans';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}
