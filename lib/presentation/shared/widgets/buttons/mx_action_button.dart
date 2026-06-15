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
///
/// Purpose:
/// Provides a reusable MemoX button widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared button surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - intent: public property.
/// - label: public content.
/// - onPressed: callback.
/// - icon: public content.
/// - fullWidth: public property.
/// Category:
/// button
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
    final bool expand = spec.allowFullWidthOverride
        ? (fullWidth ?? spec.fullWidthDefault)
        : false;

    if (MxActionSpec.isSecondary(intent)) {
      final MxSecondaryVariant variant = switch (intent) {
        MxActionIntent.cardSecondary => MxSecondaryVariant.outlined,
        _ => MxSecondaryVariant.text,
      };
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
