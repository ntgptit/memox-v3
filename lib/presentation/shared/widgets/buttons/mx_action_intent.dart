import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';

/// Where an action lives — the semantic source of its density.
///
/// `docs/ui-ux/action-hierarchy-contract.md`: density is a property of the
/// *context* an action sits in, not a number a feature picks. Each intent
/// resolves to a [MxButtonSize] and a full-width default via [MxActionSpec].
enum MxActionIntent {
  screenPrimary,
  cardPrimary,
  cardSecondary,
  inline,
  toolbar,
  dialogPrimary,
  bottomAction,
  emptyState,
  onboardingHero,
  studyPrimary,
}

/// Resolved size + full-width policy for an [MxActionIntent].
///
/// `fullWidthDefault` is the default; `allowFullWidthOverride` says whether a
/// caller may flip it. Intents that forbid full-width trip a debug assert in
/// `MxActionButton` if a caller passes `fullWidth: true`.
class MxActionSpec {
  const MxActionSpec({
    required this.size,
    required this.fullWidthDefault,
    required this.allowFullWidthOverride,
  });

  final MxButtonSize size;
  final bool fullWidthDefault;
  final bool allowFullWidthOverride;

  /// The contract's action-context table, encoded.
  static MxActionSpec of(MxActionIntent intent) => switch (intent) {
    MxActionIntent.screenPrimary => const MxActionSpec(
      size: MxButtonSize.medium,
      fullWidthDefault: false,
      allowFullWidthOverride: true,
    ),
    MxActionIntent.cardPrimary => const MxActionSpec(
      size: MxButtonSize.compact,
      fullWidthDefault: false,
      allowFullWidthOverride: false,
    ),
    MxActionIntent.cardSecondary => const MxActionSpec(
      size: MxButtonSize.compact,
      fullWidthDefault: false,
      allowFullWidthOverride: false,
    ),
    MxActionIntent.inline => const MxActionSpec(
      size: MxButtonSize.small,
      fullWidthDefault: false,
      allowFullWidthOverride: false,
    ),
    MxActionIntent.toolbar => const MxActionSpec(
      size: MxButtonSize.xsmall,
      fullWidthDefault: false,
      allowFullWidthOverride: false,
    ),
    MxActionIntent.dialogPrimary => const MxActionSpec(
      size: MxButtonSize.medium,
      fullWidthDefault: false,
      allowFullWidthOverride: false,
    ),
    MxActionIntent.bottomAction => const MxActionSpec(
      size: MxButtonSize.medium,
      fullWidthDefault: true,
      allowFullWidthOverride: true,
    ),
    MxActionIntent.emptyState => const MxActionSpec(
      size: MxButtonSize.medium,
      fullWidthDefault: false,
      allowFullWidthOverride: true,
    ),
    MxActionIntent.onboardingHero => const MxActionSpec(
      size: MxButtonSize.large,
      fullWidthDefault: true,
      allowFullWidthOverride: true,
    ),
    MxActionIntent.studyPrimary => const MxActionSpec(
      size: MxButtonSize.compact,
      fullWidthDefault: false,
      allowFullWidthOverride: true,
    ),
  };

  /// True when this intent renders as a low-emphasis (secondary) action.
  static bool isSecondary(MxActionIntent intent) =>
      intent == MxActionIntent.cardSecondary ||
      intent == MxActionIntent.inline ||
      intent == MxActionIntent.toolbar;
}
