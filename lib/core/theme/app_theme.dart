import 'package:flutter/material.dart';
import 'package:memox/core/theme/component_themes/component_themes.dart';
import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/core/theme/extensions/custom_text_styles.dart';
import 'package:memox/core/theme/schemes/app_color_scheme.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

/// Assembles the MemoX `ThemeData` from tokens, schemes, and extensions.
///
/// Foundations mirror the design-token reference
/// (`docs/system-design/MemoX Design System/ui_kits/mobile/index.html`):
/// Tokyo Pure (light) / Tokyo Nebula (dark), Plus Jakarta Sans, the
/// surface-container ladder for elevation, and ghost-border cards.
abstract final class AppTheme {
  AppTheme._();

  static ThemeData light({Color seed = MxColorScheme.defaultSeed}) =>
      _build(MxColorScheme.light(seed: seed), CustomColors.light);

  static ThemeData dark({Color seed = MxColorScheme.defaultSeed}) =>
      _build(MxColorScheme.dark(seed: seed), CustomColors.dark);

  static ThemeData _build(ColorScheme scheme, CustomColors customColors) {
    final textTheme = TypographyTokens.buildTextTheme(scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: TypographyTokens.fontFamily,
      textTheme: textTheme,
      appBarTheme: MxComponentThemes.appBar(scheme, textTheme),
      cardTheme: MxComponentThemes.card(scheme),
      navigationBarTheme: MxComponentThemes.navigationBar(scheme, textTheme),
      filledButtonTheme: MxComponentThemes.filledButton(textTheme),
      elevatedButtonTheme: MxComponentThemes.elevatedButton(textTheme),
      outlinedButtonTheme: MxComponentThemes.outlinedButton(scheme, textTheme),
      textButtonTheme: MxComponentThemes.textButton(textTheme),
      inputDecorationTheme: MxComponentThemes.input(scheme, textTheme),
      chipTheme: MxComponentThemes.chip(scheme, textTheme),
      dialogTheme: MxComponentThemes.dialog(scheme),
      bottomSheetTheme: MxComponentThemes.bottomSheet(scheme),
      floatingActionButtonTheme: MxComponentThemes.fab(scheme),
      dividerTheme: MxComponentThemes.divider(scheme),
      extensions: [
        customColors,
        CustomTextStyles.fromOnSurface(scheme.onSurface),
      ],
    );
  }
}
