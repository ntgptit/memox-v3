import 'package:flutter/material.dart';

/// Typography tokens — block J of the design-token reference.
///
/// One family: Plus Jakarta Sans (400/500/600/700/800). Collapsed size scale
/// 48 / 32 / 24 / 20 / 16 / 14 / 12 — never a size in between. [buildTextTheme]
/// produces the M3 `TextTheme`; the bespoke `statDisplay` (48) lives in
/// `CustomTextStyles` since M3 has no slot for it.
abstract final class TypographyTokens {
  TypographyTokens._();

  /// Self-hosted family declared in `pubspec.yaml`.
  static const String fontFamily = 'Plus Jakarta Sans';

  // Weights.
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // Letter spacing (logical px, per the kit).
  static const double tightSpacing = -0.64;
  static const double wideSpacing = 0.72;
  static const double widerSpacing = 1.2;

  /// ALL-CAPS overline/section-label spacing.
  static const double sectionSpacing = widerSpacing;

  /// Builds the M3 text theme for a given foreground [onSurface] color.
  static TextTheme buildTextTheme(Color onSurface) {
    TextStyle s(
      double size,
      FontWeight weight,
      double height,
      double letterSpacing,
    ) => TextStyle(
      fontFamily: fontFamily,
      color: onSurface,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );

    return TextTheme(
      displayLarge: s(32, bold, 1.2, tightSpacing),
      displayMedium: s(32, bold, 1.2, tightSpacing),
      displaySmall: s(24, bold, 1.2, tightSpacing),
      headlineLarge: s(24, semiBold, 1.2, tightSpacing),
      headlineMedium: s(20, semiBold, 1.2, 0),
      headlineSmall: s(20, semiBold, 1.2, 0),
      titleLarge: s(24, semiBold, 1.2, tightSpacing),
      titleMedium: s(16, medium, 1.5, 0),
      titleSmall: s(14, medium, 1.5, 0),
      bodyLarge: s(16, regular, 1.5, 0),
      bodyMedium: s(14, regular, 1.5, 0),
      bodySmall: s(14, regular, 1.5, 0),
      labelLarge: s(14, medium, 1.5, wideSpacing),
      labelMedium: s(12, medium, 1.4, wideSpacing),
      labelSmall: s(12, medium, 1.4, wideSpacing),
    );
  }
}
