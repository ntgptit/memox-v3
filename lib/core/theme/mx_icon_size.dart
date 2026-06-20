/// MemoX icon-size tokens (theme-neutral).
///
/// Mirrors the `--memox-icon-*` scale in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. Feature and
/// shared widgets must size an `Icon` from these named tokens rather than a raw
/// number (guard `memox.design_token.require_icon_size_token`).
abstract final class MxIconSize {
  const MxIconSize._();

  /// `--memox-icon-sm: 16px` — inline / dense glyphs.
  static const double sm = 16;

  /// `--memox-icon-md: 20px` — the standard tile / list glyph.
  static const double md = 20;

  /// `--memox-icon-lg: 24px` — emphasized glyphs (Material default).
  static const double lg = 24;
}
