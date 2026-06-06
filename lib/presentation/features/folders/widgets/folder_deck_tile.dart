import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A deck row inside a `decks`-mode folder (`docs/wireframes/05-folder-detail.md`
/// §Deck row): leading icon-tile, name + card count, optional due badge, kebab.
///
/// The kebab + long-press use [onShowActions] (the deck action sheet); when
/// null the affordance is disabled — no unsupported action is exposed (the
/// deck/flashcard mutations are not built yet).
class FolderDeckTile extends StatelessWidget {
  const FolderDeckTile({
    required this.item,
    required this.onTap,
    this.onShowActions,
    super.key,
  });

  final DeckWithCount item;
  final VoidCallback onTap;
  final VoidCallback? onShowActions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color tone = context.colorScheme.onSurfaceVariant;

    return MxCard(
      onTap: onTap,
      onLongPress: onShowActions,
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.layers_rounded),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  item.deck.name,
                  role: MxTextRole.titleSmall,
                  fontWeight: TypographyTokens.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: SpacingTokens.xs),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.style_outlined,
                      size: SizeTokens.iconXs,
                      color: tone,
                    ),
                    const SizedBox(width: SpacingTokens.xxs),
                    MxText(
                      l10n.libraryFolderCardsCount(item.cardCount),
                      role: MxTextRole.labelMedium,
                      color: tone,
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
