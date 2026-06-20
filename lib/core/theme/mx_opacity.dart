/// MemoX interaction/tint opacity tokens (theme-neutral).
///
/// Mirrors the `--memox-op-*` scale in
/// `docs/system-design/MemoX Design System/colors_and_type.css`. These are the
/// canonical alpha values for derived tints — e.g. the soft background behind a
/// tinted icon tile is the base color at [hover] alpha, exactly as the kit's
/// `.icon-tile` derives it via `color-mix(tile, op-hover)`.
///
/// Use these instead of hand-picked alpha values so a tint never drifts from
/// the design system (guard `flutter.no_magic_opacity`).
abstract final class MxOpacity {
  const MxOpacity._();

  /// Hover / soft-tint alpha (`--memox-op-hover: 0.08`). Used for the soft
  /// background of a tinted icon tile.
  static const double hover = 0.08;

  /// Selected-state alpha (`--memox-op-selected: 0.12`).
  static const double selected = 0.12;

  /// Disabled-content alpha (`--memox-op-disabled: 0.38`).
  static const double disabled = 0.38;
}
