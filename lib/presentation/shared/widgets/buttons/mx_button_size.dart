/// Density sizes for MemoX buttons.
///
/// Visual heights only — the themed `MaterialTapTargetSize.padded` keeps the
/// actual touch target ≥ 48dp even for the compact sizes (see
/// `docs/ui-ux/action-hierarchy-contract.md`).
enum MxButtonSize {
  /// Hero CTA — onboarding only.
  large,

  /// Screen primary, form, dialog, and bottom-action default.
  medium,

  /// Card / study primary default — dense everyday actions.
  compact,

  /// Inline actions.
  small,

  /// Toolbar actions.
  xsmall;

  /// Visual height in logical pixels.
  double get height => switch (this) {
    MxButtonSize.large => 52,
    MxButtonSize.medium => 48,
    MxButtonSize.compact => 40,
    MxButtonSize.small => 36,
    MxButtonSize.xsmall => 32,
  };
}
