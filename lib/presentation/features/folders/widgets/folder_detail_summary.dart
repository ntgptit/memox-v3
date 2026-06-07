import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// Folder-scope summary cards above the children list
/// (`docs/wireframes/05-folder-detail.md` §Layout). Counts are derived from the
/// loaded children — no mastery ring, "{n} new", or Start-study CTA, which need
/// study-layer data the read model does not carry yet (Future).

/// Decks-mode summary: total decks · cards plus a folder-scope due line.
class FolderDecksSummary extends StatelessWidget {
  const FolderDecksSummary({required this.decks, super.key});

  final List<DeckWithCount> decks;

  int get _cardTotal =>
      decks.fold<int>(0, (int sum, DeckWithCount d) => sum + d.cardCount);

  int get _dueTotal =>
      decks.fold<int>(0, (int sum, DeckWithCount d) => sum + d.dueCount);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final int dueTotal = _dueTotal;
    final String countsLine =
        '${l10n.libraryFolderDecksCount(decks.length)} · '
        '${l10n.libraryFolderCardsCount(_cardTotal)}';

    return MxCard(
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
                  countsLine,
                  role: MxTextRole.titleSmall,
                  fontWeight: TypographyTokens.bold,
                ),
                const SizedBox(height: SpacingTokens.xxs),
                MxText(
                  dueTotal > 0
                      ? l10n.libraryFolderDueCount(dueTotal)
                      : l10n.folderSummaryAllCaughtUp,
                  role: MxTextRole.labelMedium,
                  color: dueTotal > 0 ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: dueTotal > 0
                      ? TypographyTokens.bold
                      : TypographyTokens.regular,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subfolders-mode summary: a three-stat strip (subfolders · cards · due total)
/// over the folder's direct children. No folder-level study CTA here.
class FolderSubfoldersSummary extends StatelessWidget {
  const FolderSubfoldersSummary({required this.subfolders, super.key});

  final List<FolderWithCount> subfolders;

  int get _cardTotal =>
      subfolders.fold<int>(0, (int sum, FolderWithCount f) => sum + f.cardCount);

  int get _dueTotal =>
      subfolders.fold<int>(0, (int sum, FolderWithCount f) => sum + f.dueCount);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int dueTotal = _dueTotal;

    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FolderStatItem(
            value: subfolders.length,
            label: l10n.folderSummarySubfoldersStat,
          ),
          const _FolderStatDivider(),
          _FolderStatItem(value: _cardTotal, label: l10n.folderSummaryCardsStat),
          const _FolderStatDivider(),
          _FolderStatItem(
            value: dueTotal,
            label: l10n.folderSummaryDueStat,
            highlight: dueTotal > 0,
          ),
        ],
      ),
    );
  }
}

class _FolderStatItem extends StatelessWidget {
  const _FolderStatItem({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  final int value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText(
            '$value',
            role: MxTextRole.titleMedium,
            fontWeight: TypographyTokens.bold,
            color: highlight ? scheme.primary : scheme.onSurface,
          ),
          const SizedBox(height: SpacingTokens.xxs),
          MxText(
            label,
            role: MxTextRole.labelMedium,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Hairline separator between stats — a tokenized 1px [ColoredBox] (no raw
/// `VerticalDivider`).
class _FolderStatDivider extends StatelessWidget {
  const _FolderStatDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
    child: ColoredBox(
      color: context.colorScheme.outlineVariant,
      child: const SizedBox(
        width: SpacingTokens.xxs / 2,
        height: SizeTokens.iconLg,
      ),
    ),
  );
}
