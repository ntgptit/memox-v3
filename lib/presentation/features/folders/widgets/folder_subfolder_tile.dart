import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_accent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Folder-detail subfolder row (`docs/wireframes/05-folder-detail.md`).
///
/// The mock uses a denser list card than Library Overview: a compact folder
/// tile, name + due badge, text-only deck/cards metadata, a compact progress
/// bar, and a trailing chevron. It does not surface the Library Overview kebab.
class FolderSubfolderTile extends StatelessWidget {
  const FolderSubfolderTile({
    required this.item,
    required this.onTap,
    this.onShowActions,
    super.key,
  });

  final FolderWithCount item;
  final VoidCallback onTap;
  final VoidCallback? onShowActions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color tone = folderAccentFor(item.folder.id);
    final double progress = item.cardCount == 0
        ? 0
        : ((item.cardCount - item.dueCount) / item.cardCount)
              .clamp(0, 1)
              .toDouble();

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
          _LeadingTile(color: tone),
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
                        item.folder.name,
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
                  '${l10n.libraryFolderDecksCount(item.deckCount)} · '
                  '${l10n.libraryFolderCardsCount(item.cardCount)}',
                  role: MxTextRole.labelMedium,
                  color: context.colorScheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.sm - SpacingTokens.xxs),
                MxLinearProgress(value: progress, color: tone, height: 4),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Icon(
            Icons.chevron_right,
            size: 18,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _LeadingTile extends StatelessWidget {
  const _LeadingTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey<String>('folder_subfolder_leading_tile'),
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: color.withValues(alpha: OpacityTokens.hover),
      borderRadius: RadiusTokens.brSm,
    ),
    alignment: Alignment.center,
    child: Icon(Icons.folder_outlined, size: 17, color: color),
  );
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
        key: const ValueKey<String>('folder_subfolder_due_badge'),
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
