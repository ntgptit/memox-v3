import 'package:flutter/material.dart';

import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/color_tokens.dart';
import 'package:memox/core/theme/tokens/elevation_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Material component themes assembled from tokens.
///
/// Cards are flat with a ghost border (elevation carried by the surface
/// ladder, not shadows); buttons/inputs use 12dp radius at a 48dp touch
/// target; cards/dialogs/sheets use 16dp radius.
abstract final class MxComponentThemes {
  MxComponentThemes._();

  static AppBarTheme appBar(ColorScheme scheme, TextTheme text) => AppBarTheme(
    backgroundColor: scheme.surface,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: ColorTokens.transparent,
    elevation: ElevationTokens.level0,
    scrolledUnderElevation: ElevationTokens.level0,
    centerTitle: false,
    titleSpacing: SpacingTokens.lg,
    actionsPadding: const EdgeInsetsDirectional.only(
      end: SpacingTokens.lg,
    ),
    toolbarHeight: SizeTokens.appbar,
    titleTextStyle: text.titleLarge,
  );

  static CardThemeData card(ColorScheme scheme) => CardThemeData(
    color: scheme.surfaceContainerLowest,
    surfaceTintColor: ColorTokens.transparent,
    elevation: ElevationTokens.level0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: RadiusTokens.brLg,
      side: BorderTokens.ghostSide(scheme.primary),
    ),
  );

  static NavigationBarThemeData navigationBar(
    ColorScheme scheme,
    TextTheme text,
  ) => NavigationBarThemeData(
    height: SizeTokens.bottomNav,
    backgroundColor: scheme.surface,
    surfaceTintColor: ColorTokens.transparent,
    indicatorColor: scheme.primary.withValues(alpha: OpacityTokens.focus),
    labelTextStyle: WidgetStatePropertyAll<TextStyle?>(text.labelMedium),
  );

  static FilledButtonThemeData filledButton(TextTheme text) =>
      FilledButtonThemeData(style: _buttonStyle(text));

  static ElevatedButtonThemeData elevatedButton(TextTheme text) =>
      ElevatedButtonThemeData(
        style: _buttonStyle(text).copyWith(
          elevation: const WidgetStatePropertyAll<double>(
            ElevationTokens.level0,
          ),
        ),
      );

  static OutlinedButtonThemeData outlinedButton(
    ColorScheme scheme,
    TextTheme text,
  ) => OutlinedButtonThemeData(
    style: _buttonStyle(text).copyWith(
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(color: scheme.outlineVariant, width: BorderTokens.width),
      ),
    ),
  );

  static TextButtonThemeData textButton(TextTheme text) =>
      TextButtonThemeData(style: _buttonStyle(text));

  static InputDecorationTheme input(ColorScheme scheme, TextTheme text) =>
      InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        hintStyle: text.bodyLarge?.copyWith(
          color: scheme.onSurfaceVariant.withValues(alpha: OpacityTokens.hint),
        ),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: BorderTokens.focusWidth),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(
          scheme.error,
          width: BorderTokens.focusWidth,
        ),
      );

  static ChipThemeData chip(ColorScheme scheme, TextTheme text) => ChipThemeData(
    backgroundColor: scheme.surfaceContainer,
    labelStyle: text.labelMedium,
    side: BorderSide.none,
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
  );

  static DialogThemeData dialog(ColorScheme scheme) => DialogThemeData(
    backgroundColor: scheme.surfaceContainerLowest,
    surfaceTintColor: ColorTokens.transparent,
    elevation: ElevationTokens.level3,
    shape: const RoundedRectangleBorder(borderRadius: RadiusTokens.brLg),
  );

  static BottomSheetThemeData bottomSheet(ColorScheme scheme) =>
      BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: ColorTokens.transparent,
        elevation: ElevationTokens.level0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(RadiusTokens.lg),
          ),
        ),
      );

  // Primary-filled per the mock (`New folder` pill) — a single prominent CTA
  // that stands out on both light and dark surfaces.
  static FloatingActionButtonThemeData fab(ColorScheme scheme) =>
      FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: ElevationTokens.level2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(RadiusTokens.xxl)),
        ),
      );

  static DividerThemeData divider(ColorScheme scheme) => DividerThemeData(
    color: scheme.outlineVariant.withValues(alpha: OpacityTokens.divider),
    thickness: BorderTokens.width,
    space: SpacingTokens.lg,
  );

  static ButtonStyle _buttonStyle(TextTheme text) => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll<Size>(
      Size.fromHeight(SizeTokens.button),
    ),
    textStyle: WidgetStatePropertyAll<TextStyle?>(text.labelLarge),
    shape: const WidgetStatePropertyAll<OutlinedBorder>(
      RoundedRectangleBorder(borderRadius: RadiusTokens.brMd),
    ),
    padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
      EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
    ),
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = BorderTokens.width}) =>
      OutlineInputBorder(
        borderRadius: RadiusTokens.brMd,
        borderSide: BorderSide(color: color, width: width),
      );
}
