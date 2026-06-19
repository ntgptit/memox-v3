import 'package:flutter/material.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';

/// Intent-driven button: density and full-width come from the action context.
///
/// Purpose:
/// The preferred button entry point. Resolves size, emphasis (primary vs.
/// secondary), and full-width from an [MxActionIntent] so features express
/// *where* an action lives, not raw size/`fullWidth` numbers (which is what bred
/// oversized card CTAs). See `docs/ui-ux/action-hierarchy-contract.md`.
///
/// Use when:
/// Placing any action; pick the [intent] that matches the surface.
///
/// Do not use when:
/// You need a raw primitive for a one-off (use `MxPrimaryButton` /
/// `MxSecondaryButton` directly with a documented reason).
///
/// Category:
/// button
///
/// Public API:
/// - intent: the action context that resolves density + emphasis + full-width.
/// - label: button text; pass already-localized copy.
/// - onPressed: tap handler; null disables the button.
/// - icon: optional leading glyph.
/// - fullWidth: optional override; honored only where the intent allows it
///   (asserts otherwise in debug).
///
/// Variants:
/// - intent: see [MxActionIntent] for the full context list.
class MxActionButton extends StatelessWidget {
  const MxActionButton({
    required this.intent,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth,
    super.key,
  });

  final MxActionIntent intent;
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool? fullWidth;

  @override
  Widget build(BuildContext context) {
    assert(
      fullWidth != true || intent.allowsFullWidthOverride,
      'fullWidth: true is not allowed for $intent '
      '(see docs/ui-ux/action-hierarchy-contract.md).',
    );
    final bool resolvedFullWidth = fullWidth ?? intent.defaultFullWidth;

    if (intent.isPrimary) {
      return MxPrimaryButton(
        label: label,
        onPressed: onPressed,
        icon: icon,
        size: intent.size,
        fullWidth: resolvedFullWidth,
      );
    }
    return MxSecondaryButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: intent.size,
      variant: intent.secondaryVariant,
      fullWidth: resolvedFullWidth,
    );
  }
}
