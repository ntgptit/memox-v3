import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

/// Semantic action contexts mapped to density + full-width defaults.
///
/// Density becomes a property of *where* an action lives, not a number a feature
/// picks. See the resolution table in `docs/ui-ux/action-hierarchy-contract.md`
/// (consumed by `MxActionButton`).
enum MxActionIntent {
  /// One dominant action for the whole screen.
  screenPrimary,

  /// Dominant action inside a card.
  cardPrimary,

  /// Lighter companion action inside a card.
  cardSecondary,

  /// Low-emphasis inline action.
  inline,

  /// Toolbar / app-bar action.
  toolbar,

  /// Primary action inside a dialog.
  dialogPrimary,

  /// Full-width action pinned to a bottom bar.
  bottomAction,

  /// Primary CTA on a full-screen empty state.
  emptyState,

  /// Full-width hero CTA for onboarding.
  onboardingHero,

  /// Primary action inside a study session.
  studyPrimary,
}

/// Resolves an [MxActionIntent] into concrete button properties.
extension MxActionIntentSpec on MxActionIntent {
  /// Density for this context.
  MxButtonSize get size => switch (this) {
    MxActionIntent.onboardingHero => MxButtonSize.large,
    MxActionIntent.screenPrimary ||
    MxActionIntent.dialogPrimary ||
    MxActionIntent.bottomAction ||
    MxActionIntent.emptyState => MxButtonSize.medium,
    MxActionIntent.cardPrimary ||
    MxActionIntent.cardSecondary ||
    MxActionIntent.studyPrimary => MxButtonSize.compact,
    MxActionIntent.inline => MxButtonSize.small,
    MxActionIntent.toolbar => MxButtonSize.xsmall,
  };

  /// Whether this context renders the high-emphasis primary button.
  bool get isPrimary => switch (this) {
    MxActionIntent.cardSecondary ||
    MxActionIntent.inline ||
    MxActionIntent.toolbar => false,
    _ => true,
  };

  /// Secondary emphasis style for non-primary contexts.
  MxSecondaryVariant get secondaryVariant => switch (this) {
    MxActionIntent.inline || MxActionIntent.toolbar => MxSecondaryVariant.text,
    _ => MxSecondaryVariant.tonal,
  };

  /// Full-width default for this context.
  bool get defaultFullWidth => switch (this) {
    MxActionIntent.bottomAction || MxActionIntent.onboardingHero => true,
    _ => false,
  };

  /// Whether an explicit `fullWidth:` override is honored (vs. asserted away).
  bool get allowsFullWidthOverride => switch (this) {
    MxActionIntent.screenPrimary ||
    MxActionIntent.emptyState ||
    MxActionIntent.studyPrimary ||
    MxActionIntent.bottomAction ||
    MxActionIntent.onboardingHero => true,
    _ => false,
  };
}
