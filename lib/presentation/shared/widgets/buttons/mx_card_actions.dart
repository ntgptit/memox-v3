import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_spacing.dart';

/// Trailing-aligned action row for a card: a primary with an optional secondary.
///
/// Purpose:
/// The standard dense card action layout, so card actions stay compact and
/// trailing-aligned (never a full-width hero block) without each card
/// re-inventing the row. See `docs/ui-ux/action-hierarchy-contract.md`.
///
/// Use when:
/// A card needs one primary action, optionally paired with a lighter secondary.
///
/// Do not use when:
/// The action belongs in a bottom bar / form footer (use a full-width
/// `MxActionButton(intent: bottomAction)` there instead).
///
/// Category:
/// layout
///
/// Public API:
/// - primary: the dominant card action (e.g. an `MxActionButton(cardPrimary)`).
/// - secondary: optional lighter action shown before the primary.
class MxCardActions extends StatelessWidget {
  const MxCardActions({required this.primary, this.secondary, super.key});

  final Widget primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    final Widget? secondary = this.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        if (secondary != null) ...<Widget>[
          secondary,
          const SizedBox(width: MxSpacing.space2),
        ],
        primary,
      ],
    );
  }
}
