import 'package:memox/core/theme/tokens/size_tokens.dart';

/// Visual heights for the button primitives.
///
/// Section B of the shared-widget handoff. The visual box can be compact
/// (40dp) while the *touch* target stays ≥ 48dp via
/// `MaterialTapTargetSize.padded`. Frozen mobile density per
/// `docs/ui-ux/action-hierarchy-contract.md`: card/study actions are
/// [compact], form/dialog/bottom actions are [medium], onboarding hero is
/// [large].
enum MxButtonSize {
  /// Toolbar text actions.
  xsmall(SizeTokens.chip),

  /// Inline link-style actions.
  small(SizeTokens.buttonSm),

  /// Card / study actions — the everyday density.
  compact(SizeTokens.controlMd),

  /// Form, dialog, and bottom-bar actions.
  medium(SizeTokens.button),

  /// Onboarding / hero CTA.
  large(SizeTokens.buttonLg);

  const MxButtonSize(this.height);

  /// Visual height in logical pixels.
  final double height;
}
