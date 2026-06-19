import 'package:flutter/material.dart';

/// MemoX typography tokens.
///
/// Mirrors the font families, sizes, weights, line-heights and tracking in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. The sans
/// family is applied once at [ThemeData.fontFamily] level (see `MxTheme`), so
/// the [textTheme] entries below carry only size/weight/height/tracking and
/// inherit color from the active [ColorScheme]. Feature code reads
/// `Theme.of(context).textTheme.*` — never a raw [TextStyle].
abstract final class MxTypography {
  const MxTypography._();

  // ---- Font families (--memox-font-*) ----
  /// Primary UI typeface (bundled in `pubspec.yaml`).
  static const String fontFamilySans = 'Plus Jakarta Sans';

  /// Serif accent for reading content. Not bundled yet — falls back to the
  /// platform serif until the asset is added.
  static const String fontFamilySerif = 'Lora';

  /// Monospace for code-like content. Not bundled yet — falls back to the
  /// platform monospace until the asset is added.
  static const String fontFamilyMono = 'JetBrains Mono';

  // ---- Weights (--memox-weight-*) ----
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extrabold = FontWeight.w800;

  // ---- Line heights (--memox-leading-*) ----
  static const double leadingTight = 1.15;
  static const double leadingSnug = 1.35;
  static const double leadingNormal = 1.5;

  // ---- Tracking (--memox-tracking-*) ----
  /// Tight tracking for large display text (`-0.02em`).
  static const double trackingTight = -0.5;

  /// Section-overline tracking (`--memox-ls-section: 0.08em`).
  static const double trackingSection = 1.0;

  /// MemoX text scale mapped onto Material's [TextTheme] slots. Colors are left
  /// null so [ThemeData] applies the brightness-appropriate default.
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: extrabold,
      height: leadingTight,
      letterSpacing: trackingTight,
    ),
    displayMedium: TextStyle(
      fontSize: 26,
      fontWeight: bold,
      height: leadingTight,
      letterSpacing: trackingTight,
    ),
    displaySmall: TextStyle(
      fontSize: 22,
      fontWeight: bold,
      height: leadingSnug,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: bold,
      height: leadingSnug,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: regular,
      height: leadingNormal,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: regular,
      height: leadingNormal,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: regular,
      height: leadingNormal,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: semibold,
      height: leadingSnug,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: semibold,
      height: leadingSnug,
    ),
  );
}
