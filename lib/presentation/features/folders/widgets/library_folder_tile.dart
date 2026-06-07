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
import 'package:memox/presentation/features/folders/widgets/folder_accent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// A Library Overview folder row (`docs/wireframes/02-library.md`).
///
/// Leading accent tile, name + optional topic subtitle, a counts row
/// (decks/subfolders · cards · new), a mastery bar, an optional due badge, and
/// a trailing kebab. Tapping the row opens the folder; the kebab and a
/// long-press are both wired to [onShowActions], which opens the folder action
/// sheet (Rename / Move / Import flashcards / Delete).
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
    final Color tone = folderAccentFor(item.folder.id);
    return _LibraryFolderTileCard(
      item: item,
      tone: tone,
      isSubfolderMode: isSubfolderMode,
      onTap: onTap,
      onShowActions: onShowActions,
      tooltip: l10n.libraryOverflowTooltip,
      subtitle: item.subtitle,
      newCount: item.newCount,
      mastery: (item.mastery ?? _fallbackMastery(item)).clamp(0, 1).toDouble(),
    );
  }
}

class _LibraryFolderTileCard extends StatelessWidget {
  const _LibraryFolderTileCard({
    required this.item,
    required this.tone,
    required this.isSubfolderMode,
    required this.onTap,
    required this.onShowActions,
    required this.tooltip,
    required this.subtitle,
    required this.newCount,
    required this.mastery,
  });

  final FolderWithCount item;
  final Color tone;
  final bool isSubfolderMode;
  final VoidCallback onTap;
  final VoidCallback? onShowActions;
  final String tooltip;
  final String? subtitle;
  final int? newCount;
  final double mastery;

  @override
  Widget build(BuildContext context) => MxCard(
    onTap: onTap,
    onLongPress: onShowActions,
    padding: const EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.lg,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _LeadingTile(color: tone),
        const SizedBox(width: SpacingTokens.lg),
        Expanded(
          child: _FolderTileBody(
            item: item,
            tone: tone,
            subtitle: subtitle,
            newCount: newCount,
            mastery: mastery,
            isSubfolderMode: isSubfolderMode,
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        MxIconButton(
          icon: Icons.more_vert,
          tooltip: tooltip,
          size: MxIconButtonSize.compact,
          onPressed: onShowActions,
        ),
      ],
    ),
  );
}

class _FolderTileBody extends StatelessWidget {
  const _FolderTileBody({
    required this.item,
    required this.tone,
    required this.subtitle,
    required this.newCount,
    required this.mastery,
    required this.isSubfolderMode,
  });

  final FolderWithCount item;
  final Color tone;
  final String? subtitle;
  final int? newCount;
  final double mastery;
  final bool isSubfolderMode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? effectiveSubtitle = subtitle;
    final int? effectiveNewCount = newCount;
    return Column(
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
              _DueCountBadge(label: l10n.libraryFolderDueCount(item.dueCount)),
            ],
          ],
        ),
        if (effectiveSubtitle?.isNotEmpty ?? false) ...<Widget>[
          const SizedBox(height: SpacingTokens.xxs),
          MxText(
            effectiveSubtitle!,
            role: MxTextRole.labelMedium,
            color: context.colorScheme.onSurfaceVariant,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
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
              icon: Icons.copy_outlined,
              label: l10n.libraryFolderCardsCount(item.cardCount),
            ),
            if ((effectiveNewCount ?? 0) > 0) ...<Widget>[
              const SizedBox(width: SpacingTokens.md),
              _NewMetaItem(
                label: l10n.libraryFolderNewCount(effectiveNewCount!),
              ),
            ],
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        MxLinearProgress(value: mastery, color: tone, height: SpacingTokens.xs),
      ],
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

class _LeadingTile extends StatelessWidget {
  const _LeadingTile({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey<String>('library_folder_leading_tile'),
    width: SizeTokens.avatar,
    height: SizeTokens.avatar,
    decoration: BoxDecoration(
      color: color.withValues(alpha: OpacityTokens.hover),
      borderRadius: RadiusTokens.brMd,
    ),
    alignment: Alignment.center,
    child: Icon(Icons.folder_rounded, size: SizeTokens.iconSm, color: color),
  );
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

class _NewMetaItem extends StatelessWidget {
  const _NewMetaItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color tone = context.customColors.masteryHigh;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: SpacingTokens.tight,
          height: SpacingTokens.tight,
          decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
        ),
        const SizedBox(width: SpacingTokens.xxs),
        MxText(label, role: MxTextRole.labelMedium, color: tone),
      ],
    );
  }
}

double _fallbackMastery(FolderWithCount item) {
  final int total = item.cardCount;
  if (total <= 0) {
    return 0;
  }
  return ((total - item.dueCount) / total).clamp(0, 1).toDouble();
}
