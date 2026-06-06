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
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A Library Overview folder row (`docs/wireframes/02-library.md`).
///
/// Leading icon-tile, name + an icon metadata row (subfolders/decks · cards),
/// an optional due badge, and a trailing kebab. Tapping the row opens the
/// folder; the kebab and a long-press are both wired to [onShowActions], which
/// opens the folder action sheet (Rename / Move / Import flashcards / Delete).
class LibraryFolderTile extends StatelessWidget {
  const LibraryFolderTile({
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
    final bool isSubfolderMode =
        item.folder.contentMode == ContentMode.subfolders;

    return MxCard(
      onTap: onTap,
      onLongPress: onShowActions,
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.folder_rounded),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  item.folder.name,
                  role: MxTextRole.titleSmall,
                  fontWeight: TypographyTokens.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Row(
                  children: <Widget>[
                    _FolderMetaItem(
                      icon: isSubfolderMode
                          ? Icons.folder_copy_outlined
                          : Icons.layers_outlined,
                      label: isSubfolderMode
                          ? l10n.libraryFolderSubfoldersCount(item.subfolderCount)
                          : l10n.libraryFolderDecksCount(item.deckCount),
                    ),
                    const SizedBox(width: SpacingTokens.md),
                    _FolderMetaItem(
                      icon: Icons.style_outlined,
                      label: l10n.libraryFolderCardsCount(item.cardCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (item.dueCount > 0) ...<Widget>[
            const SizedBox(width: SpacingTokens.sm),
            _DueCountBadge(label: l10n.libraryFolderDueCount(item.dueCount)),
          ],
          const SizedBox(width: SpacingTokens.xxs),
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.libraryOverflowTooltip,
            size: MxIconButtonSize.compact,
            onPressed: onShowActions,
          ),
        ],
      ),
    );
  }
}

/// A small icon + count pair in the folder metadata row.
class _FolderMetaItem extends StatelessWidget {
  const _FolderMetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color tone = context.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: SizeTokens.iconXs, color: tone),
        const SizedBox(width: SpacingTokens.xxs),
        MxText(label, role: MxTextRole.labelMedium, color: tone),
      ],
    );
  }
}

/// Right-aligned due badge, shown only when a folder subtree has due cards.
class _DueCountBadge extends StatelessWidget {
  const _DueCountBadge({required this.label});

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
