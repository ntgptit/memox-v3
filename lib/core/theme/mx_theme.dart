import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_shadows.dart';
import 'package:memox/core/theme/mx_typography.dart';

/// Builds the MemoX [ThemeData] for light and dark from the design-system
/// tokens.
///
/// The Material [ColorScheme] is pinned to MemoX tokens (not seed-generated
/// guesses) for every role the app reads; the MemoX-specific tokens that
/// Material cannot express are attached as [ThemeExtension]s ([MxColors],
/// [MxShadows]). Spacing/radius/typography tokens live in their own token
/// classes (`MxSpacing`, `MxRadius`, `MxTypography`).
abstract final class MxTheme {
  const MxTheme._();

  /// Light theme.
  static ThemeData get light =>
      _build(Brightness.light, MxColors.light, MxShadows.light);

  /// Dark theme.
  static ThemeData get dark =>
      _build(Brightness.dark, MxColors.dark, MxShadows.dark);

  static ThemeData _build(Brightness brightness, MxColors c, MxShadows s) {
    final ColorScheme scheme = _scheme(brightness, c);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.surface,
      dividerColor: c.divider,
      fontFamily: MxTypography.fontFamilySans,
      textTheme: MxTypography.textTheme.apply(
        bodyColor: c.text,
        displayColor: c.text,
      ),
      extensions: <ThemeExtension<Object?>>[c, s],
    );
  }

  /// Maps MemoX tokens onto the Material [ColorScheme] roles the app consumes.
  /// Seeds an exhaustive scheme, then overrides every role with a token so no
  /// surface or accent is left to seed-generation.
  static ColorScheme _scheme(Brightness brightness, MxColors c) {
    final ColorScheme base = ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
    );
    return base.copyWith(
      primary: c.accent,
      onPrimary: c.accentContrast,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: c.accent,
      secondary: c.info,
      onSecondary: c.accentContrast,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surfaceMuted,
      surfaceContainerHigh: c.surfaceMuted,
      outline: c.borderStrong,
      outlineVariant: c.border,
      error: c.danger,
      onError: c.accentContrast,
      errorContainer: c.dangerSoft,
      scrim: c.overlay,
    );
  }
}
