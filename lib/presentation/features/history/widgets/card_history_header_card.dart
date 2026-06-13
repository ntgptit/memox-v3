import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Card History header: front/back preview, current SRS state, and cumulative
/// lifetime stats (`docs/wireframes/09-flashcard-history.md` §Header card).
class CardHistoryHeaderCard extends StatelessWidget {
  const CardHistoryHeaderCard({
    required this.header,
    required this.now,
    super.key,
  });

  final CardHistoryHeader header;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color muted = context.colorScheme.onSurfaceVariant;
    final int? accuracyPercent = header.accuracy == null
        ? null
        : (header.accuracy! * 100).round();

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxText(
            header.front,
            role: MxTextRole.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.xxs),
          MxText(
            header.back,
            role: MxTextRole.bodyMedium,
            color: muted,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: SpacingTokens.md),
          MxText(
            CardHistoryLabels.stateLine(l10n, header, now),
            role: MxTextRole.labelLarge,
          ),
          const SizedBox(height: SpacingTokens.sm),
          if (!header.hasReviews)
            MxText(
              l10n.cardHistoryNoReviews,
              role: MxTextRole.bodyMedium,
              color: muted,
            )
          else ...<Widget>[
            MxText(
              l10n.cardHistoryReviewForgotStat(
                header.reviewCount,
                header.lapseCount,
              ),
              role: MxTextRole.bodyMedium,
              color: muted,
            ),
            if (accuracyPercent != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.xxs),
              MxText(
                l10n.cardHistoryAccuracyStat(accuracyPercent),
                role: MxTextRole.bodyMedium,
                color: muted,
              ),
            ],
          ],
          if (header.lastResetAt != null) ...<Widget>[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info_outline, size: SizeTokens.iconXs, color: muted),
                const SizedBox(width: SpacingTokens.xs),
                Expanded(
                  child: MxText(
                    l10n.cardHistoryResetSubLabel(
                      CardHistoryLabels.isoDate(header.lastResetAt!),
                    ),
                    role: MxTextRole.bodySmall,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
