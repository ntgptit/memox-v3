import 'package:flutter/material.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';

/// Trailing-aligned, compact action row for a card.
///
/// `docs/ui-ux/action-hierarchy-contract.md`: card actions are a *dense action
/// surface* — never full-width, never `large`. Pass `cardPrimary` /
/// `cardSecondary` [MxActionButton]s; this lays them out, secondary first.
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
