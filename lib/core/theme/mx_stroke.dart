/// MemoX stroke-width tokens (theme-neutral).
///
/// The named line weights for hairlines and borders, mirroring the `1px`
/// borders / `.hr` hairline in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. Feature and
/// shared widgets must size a divider/border from these tokens rather than a
/// raw number (guards `memox.design_token.require_border_token` /
/// `require_visual_box_size_token`).
abstract final class MxStroke {
  const MxStroke._();

  /// Standard 1px hairline / border weight.
  static const double hairline = 1;

  /// Emphasized 2px border (e.g. a selected control outline).
  static const double emphasis = 2;
}
