/// MemoX spacing tokens (theme-neutral).
///
/// Mirrors the `--memox-space-*` scale and spacing roles in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. Spacing does
/// not change between light and dark, so these are plain compile-time constants
/// rather than a [ThemeExtension]. Feature and shared widgets must read these
/// instead of hardcoding raw pixel gaps.
abstract final class MxSpacing {
  const MxSpacing._();

  // ---- 4px base scale (--memox-space-N) ----
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;

  // ---- Semantic spacing roles ----
  /// Horizontal padding for screen bodies (`--memox-space-screen`).
  static const double screen = 20;

  /// Inner padding for cards (`--memox-space-card`).
  static const double card = 16;

  /// Vertical rhythm between stacked sections inside a scroll body
  /// (`--memox-gap-section`).
  static const double gapSection = 16;

  /// Minimum interactive touch target (`--memox-hit`); WCAG / a11y floor.
  static const double minTouchTarget = 48;
}
