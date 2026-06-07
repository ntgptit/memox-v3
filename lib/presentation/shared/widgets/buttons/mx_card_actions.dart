import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';

/// Trailing-aligned, compact action row for a card.
///
/// `docs/ui-ux/action-hierarchy-contract.md`: card actions are a *dense action
/// surface* — never full-width, never `large`. Pass `cardPrimary` /
/// `cardSecondary` [MxActionButton]s; this lays them out, secondary first.
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
/// - primary: public property.
/// - secondary: public property.
/// - alignment: public property.
/// Category:
/// button
class MxCardActions extends StatelessWidget {
  const MxCardActions({
    required this.primary,
    this.secondary,
    this.alignment = MainAxisAlignment.end,
    super.key,
  });

  final MxActionButton primary;
  final MxActionButton? secondary;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: alignment,
    children: <Widget>[
      if (secondary != null) ...<Widget>[
        secondary!,
        const SizedBox(width: SpacingTokens.sm),
      ],
      primary,
    ],
  );
}
