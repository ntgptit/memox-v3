import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/core/theme/extensions/custom_text_styles.dart';

/// Terse theme accessors for widgets.
///
/// `context.colorScheme`, `context.textTheme`, `context.customColors`,
/// `context.customTextStyles` — avoids repeating `Theme.of(context)...`.
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  CustomColors get customColors => Theme.of(this).extension<CustomColors>()!;

  CustomTextStyles get customTextStyles =>
      Theme.of(this).extension<CustomTextStyles>()!;
}
