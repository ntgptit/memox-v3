/// Spacing scale — 4dp grid.
///
/// Block K of the design-token reference
/// (`docs/system-design/MemoX Design System/ui_kits/mobile/index.html`).
/// Resolve every gap/padding through these; no raw `SizedBox(width: 16)`.
abstract final class SpacingTokens {
  SpacingTokens._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Semantic aliases.
  static const double cardPadding = 16;
  static const double screenPadding = 24;
  static const double sectionGap = 32;
}
