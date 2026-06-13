import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Card History header: front/back preview with the current-box chip, plus the
/// reset sub-label when the card was reset
/// (`docs/wireframes/09-flashcard-history.md` §Header card).
class CardHistoryHeaderCard extends StatelessWidget {
  const CardHistoryHeaderCard({required this.header, super.key});

  final CardHistoryHeader header;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color muted = context.colorScheme.onSurfaceVariant;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MxText(
                      header.front,
                      role: MxTextRole.titleLarge,
                      fontWeight: TypographyTokens.bold,
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
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              _BoxChip(
                label: CardHistoryLabels.boxChip(l10n, header.boxNumber),
              ),
            ],
          ),
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

class _BoxChip extends StatelessWidget {
  const _BoxChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.bolt,
            size: SizeTokens.iconXs,
            color: scheme.onPrimaryContainer,
          ),
          const SizedBox(width: SpacingTokens.xxs),
          MxText(
            label,
            role: MxTextRole.labelMedium,
            fontWeight: TypographyTokens.bold,
            color: scheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }
}
