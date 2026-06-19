/// MemoX corner-radius tokens (theme-neutral).
///
/// Mirrors the `--memox-radius-*` scale and radius roles in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. Radii do not
/// change between light and dark, so these are plain compile-time constants.
/// Widgets build `BorderRadius.circular(MxRadius.card)` rather than hardcoding
/// raw pixel radii.
abstract final class MxRadius {
  const MxRadius._();

  // ---- Scale (--memox-radius-*) ----
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;

  /// Fully rounded ends (`--memox-radius-pill`); use for pills/chips/buttons.
  static const double pill = 999;

  // ---- Semantic radius roles ----
  /// Default card surface radius (`--memox-radius-card`).
  static const double card = lg;

  /// Pill-shaped buttons (`--memox-radius-button`).
  static const double button = pill;

  /// Floating action button radius (`--memox-radius-fab`).
  static const double fab = 18;
}
