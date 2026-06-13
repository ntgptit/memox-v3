import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Non-interactive "Progress reset on {date}" separator placed between the
/// post-reset and pre-reset attempts
/// (`docs/wireframes/09-flashcard-history.md` §Divider row). Wider stroke than
/// the row hairlines so the reset point reads as a section break.
class CardHistoryResetDivider extends StatelessWidget {
  const CardHistoryResetDivider({required this.resetAt, super.key});

  final DateTime resetAt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color color = context.colorScheme.outline;
    final String label = l10n.cardHistoryResetDivider(
      CardHistoryLabels.isoDate(resetAt),
    );

    return Semantics(
      label: label,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        child: Row(
          children: <Widget>[
            Expanded(child: _Rule(color: color)),
            const SizedBox(width: SpacingTokens.sm),
            MxText(label, role: MxTextRole.labelMedium, color: color),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(child: _Rule(color: color)),
          ],
        ),
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(height: BorderTokens.focusWidth, color: color);
}
