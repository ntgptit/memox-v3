import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A Library Overview folder row: leading icon-tile, name + recursive-count
/// subtitle, optional due badge, chevron (`docs/wireframes/02-library.md`).
class LibraryFolderTile extends StatelessWidget {
  const LibraryFolderTile({required this.item, required this.onTap, super.key});

  final FolderWithCount item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;

    final String primary = item.folder.contentMode == ContentMode.subfolders
        ? l10n.libraryFolderSubfoldersCount(item.subfolderCount)
        : l10n.libraryFolderDecksCount(item.deckCount);
    final String subtitle =
        '$primary  ·  ${l10n.libraryFolderCardsCount(item.cardCount)}';

    return MxCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.folder_outlined),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  item.folder.name,
                  role: MxTextRole.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  subtitle,
                  role: MxTextRole.labelMedium,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (item.dueCount > 0) ...<Widget>[
            const SizedBox(width: SpacingTokens.sm),
            _DueBadge(label: l10n.libraryFolderDueCount(item.dueCount)),
          ],
          const SizedBox(width: SpacingTokens.xs),
          Icon(
            Icons.chevron_right,
            size: SizeTokens.iconSm,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: OpacityTokens.focus),
        borderRadius: RadiusTokens.brFull,
      ),
      child: MxText(
        label,
        role: MxTextRole.labelMedium,
        color: scheme.primary,
        fontWeight: TypographyTokens.bold,
      ),
    );
  }
}
