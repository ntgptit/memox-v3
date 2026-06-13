import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Non-interactive "Progress reset on {date}" separator placed between the
/// post-reset and pre-reset attempts
/// (`docs/wireframes/09-flashcard-history.md` §Divider row). The label sits over
/// a full-width rule (a Stack, so a long date never overflows a Row).
class CardHistoryResetDivider extends StatelessWidget {
  const CardHistoryResetDivider({required this.resetAt, super.key});

  final DateTime resetAt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final String label = l10n.cardHistoryResetDivider(
      CardHistoryLabels.isoDate(resetAt),
    );

    return Semantics(
      label: label,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              height: BorderTokens.focusWidth,
              width: double.infinity,
              color: scheme.outline,
            ),
            ColoredBox(
              color: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                ),
                child: MxText(
                  label,
                  role: MxTextRole.labelMedium,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
