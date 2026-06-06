import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// A deck row inside a `decks`-mode folder (`docs/wireframes/05-folder-detail.md`
/// §Deck row): leading icon-tile, name + due badge, card count + last studied,
/// progress bar, and a chevron.
///
/// The long-press use [onShowActions] (the deck action sheet); when null the
/// affordance is disabled — no unsupported action is exposed (the
/// deck/flashcard mutations are not built yet).
class FolderDeckTile extends StatelessWidget {
  const FolderDeckTile({
    required this.item,
    required this.onTap,
    this.onShowActions,
    this.referenceNow,
    super.key,
  });

  final DeckWithCount item;
  final VoidCallback onTap;
  final VoidCallback? onShowActions;
  final DateTime? referenceNow;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color tone = context.colorScheme.onSurfaceVariant;
    final DateTime now = referenceNow ?? DateTime.now();
    final double progress = item.cardCount == 0
        ? 0
        : ((item.cardCount - item.dueCount) / item.cardCount)
              .clamp(0, 1)
              .toDouble();
    final String? lastStudiedLabel = item.lastStudiedAt == null
        ? null
        : _formatRelativeTimeAgo(
            l10n: l10n,
            relativeTime: RelativeTime.between(item.lastStudiedAt!, now),
          );

    return MxCard(
      onTap: onTap,
      onLongPress: onShowActions,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md + SpacingTokens.xxs,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const _DeckIconTile(),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: MxText(
                        item.deck.name,
                        role: MxTextRole.titleSmall,
                        fontWeight: TypographyTokens.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.dueCount > 0) ...<Widget>[
                      const SizedBox(width: SpacingTokens.sm),
                      _DueCountBadge(
                        label: l10n.libraryFolderDueCount(item.dueCount),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: SpacingTokens.xs),
                MxText(
                  lastStudiedLabel == null
                      ? l10n.libraryFolderCardsCount(item.cardCount)
                      : l10n.folderDetailDeckMeta(
                          item.cardCount,
                          lastStudiedLabel,
                        ),
                  role: MxTextRole.labelMedium,
                  color: tone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.sm - SpacingTokens.xxs),
                MxLinearProgress(
                  value: progress,
                  color: context.customColors.masteryHigh,
                  height: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Icon(Icons.chevron_right, size: 18, color: tone),
        ],
      ),
    );
  }
}

String _formatRelativeTimeAgo({
  required AppLocalizations l10n,
  required RelativeTime relativeTime,
}) => l10n.relativeTimeAgo(relativeTime.unit.name, relativeTime.count);

class _DeckIconTile extends StatelessWidget {
  const _DeckIconTile();

  @override
  Widget build(BuildContext context) {
    final Color tint = context.colorScheme.primary;
    return Container(
      key: const ValueKey<String>('folder_deck_leading_tile'),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: OpacityTokens.hover),
        borderRadius: RadiusTokens.brSm,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.layers_rounded, size: 17, color: tint),
    );
  }
}

class _DueCountBadge extends StatelessWidget {
  const _DueCountBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return SizedBox(
      height: 18,
      child: Container(
        key: const ValueKey<String>('folder_deck_due_badge'),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: OpacityTokens.focus),
          borderRadius: RadiusTokens.brFull,
        ),
        child: Center(
          child: MxText(
            label,
            role: MxTextRole.labelMedium,
            color: scheme.primary,
            fontWeight: TypographyTokens.bold,
          ),
        ),
      ),
    );
  }
}
