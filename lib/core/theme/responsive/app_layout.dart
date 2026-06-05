import 'package:flutter/widgets.dart';

import 'package:memox/core/theme/responsive/breakpoints.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Layout conventions derived from the active form factor.
///
/// Centralizes responsive padding and the readable max content width
/// (`maxBodyWidth`, block S of the token reference) so screens don't stretch
/// text too wide on tablet/desktop. See `docs/ui-ux/ui-ux-contract.md`
/// §Responsive rule.
abstract final class AppLayout {
  AppLayout._();

  static const double maxContentWidth = Breakpoints.maxBodyWidth;

  /// Horizontal screen edge padding per form factor.
  static double horizontalPadding(FormFactor formFactor) =>
      switch (formFactor) {
        FormFactor.mobile => SpacingTokens.screenPadding,
        FormFactor.tablet => SpacingTokens.xxl,
        FormFactor.desktop => SpacingTokens.xxxl,
      };

  /// Picks the value matching the form factor, falling back to narrower tiers.
  static T value<T>(
    FormFactor formFactor, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) => switch (formFactor) {
    FormFactor.mobile => mobile,
    FormFactor.tablet => tablet ?? mobile,
    FormFactor.desktop => desktop ?? tablet ?? mobile,
  };
}

/// `context.contentPadding` / `context.maxContentWidth` helpers.
extension AppLayoutContext on BuildContext {
  EdgeInsets get horizontalContentPadding => EdgeInsets.symmetric(
    horizontal: AppLayout.horizontalPadding(formFactor),
  );

  double get maxContentWidth => AppLayout.maxContentWidth;
}
