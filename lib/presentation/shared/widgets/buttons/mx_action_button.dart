import 'package:flutter/material.dart';

import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

/// Semantic, intent-driven action button — the preferred way to add an action.
///
/// Resolves size + full-width from [intent] via [MxActionSpec]
/// (`docs/ui-ux/action-hierarchy-contract.md`). Passing `fullWidth: true` to an
/// intent that forbids it trips a debug assert. Secondary intents
/// (cardSecondary / inline / toolbar) render as the lighter
/// `MxSecondaryButton`.
class MxActionButton extends StatelessWidget {
  const MxActionButton({
    required this.intent,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth,
    super.key,
  });

  final MxActionIntent intent;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Override the intent's full-width default. Honored only where the intent
  /// allows it; asserts otherwise in debug builds.
  final bool? fullWidth;

  @override
  Widget build(BuildContext context) {
    final MxActionSpec spec = MxActionSpec.of(intent);
    assert(
      fullWidth != true || spec.allowFullWidthOverride,
      'Intent $intent forbids full-width actions '
      '(docs/ui-ux/action-hierarchy-contract.md).',
    );
    final bool expand =
        spec.allowFullWidthOverride ? (fullWidth ?? spec.fullWidthDefault) : false;

    if (MxActionSpec.isSecondary(intent)) {
      final MxSecondaryVariant variant = intent == MxActionIntent.cardSecondary
          ? MxSecondaryVariant.tonal
          : MxSecondaryVariant.text;
      return MxSecondaryButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        variant: variant,
        size: spec.size,
        fullWidth: expand,
      );
    }

    return MxPrimaryButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: spec.size,
      fullWidth: expand,
    );
  }
}
