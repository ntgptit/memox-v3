/// Opacity / state-layer scale.
///
/// Block O of the design-token reference. Hover/focus/press tints, disabled,
/// scrim, and the 84% glass chrome.
abstract final class OpacityTokens {
  OpacityTokens._();

  static const double softTint = 0.05;
  static const double hover = 0.08;

  /// Focus and press share the same state-layer opacity.
  static const double focus = 0.12;
  static const double press = 0.12;
  static const double drag = 0.16;
  static const double selected = 0.18;
  static const double disabled = 0.38;
  static const double hint = 0.50;
  static const double divider = 0.12;
  static const double outline = 0.08;
  static const double borderSubtle = 0.15;
  static const double scrim = 0.32;

  /// Chrome glass (app bar / nav) page-surface opacity.
  static const double surfaceGlass = 0.84;

  /// Wrong-answer fade-out.
  static const double fadeOut = 0.40;
}
