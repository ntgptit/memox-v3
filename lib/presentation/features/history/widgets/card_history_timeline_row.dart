import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// One read-only attempt row: timestamp, result, box transition, optional mode
/// (`docs/wireframes/09-flashcard-history.md` §Timeline row shape).
class CardHistoryTimelineRow extends StatelessWidget {
  const CardHistoryTimelineRow({required this.attempt, super.key});

  final CardHistoryAttempt attempt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final (IconData icon, Color color) = _resultVisual(attempt.result, scheme);

    return Semantics(
      label: _semanticsLabel(l10n),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MxText(
              CardHistoryLabels.attemptTimestamp(attempt.attemptedAt),
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: SpacingTokens.xxs),
            Row(
              children: <Widget>[
                Icon(icon, size: SizeTokens.iconXs, color: color),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: MxText(
                    CardHistoryLabels.resultLabel(l10n, attempt.result),
                    role: MxTextRole.bodyLarge,
                  ),
                ),
                MxText(
                  CardHistoryLabels.boxTransition(l10n, attempt),
                  role: MxTextRole.labelLarge,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              l10n.cardHistoryModeLabel(attempt.studyMode.name),
              role: MxTextRole.labelSmall,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _semanticsLabel(AppLocalizations l10n) =>
      '${CardHistoryLabels.attemptTimestamp(attempt.attemptedAt)}, '
      '${CardHistoryLabels.resultLabel(l10n, attempt.result)}, '
      '${CardHistoryLabels.boxTransition(l10n, attempt)}';

  static (IconData, Color) _resultVisual(
    AttemptResult result,
    ColorScheme scheme,
  ) => switch (result) {
    AttemptResult.perfect ||
    AttemptResult.initialPassed => (Icons.check_circle_outline, scheme.primary),
    AttemptResult.recovered => (Icons.error_outline, scheme.tertiary),
    AttemptResult.forgot => (Icons.cancel_outlined, scheme.error),
  };
}
