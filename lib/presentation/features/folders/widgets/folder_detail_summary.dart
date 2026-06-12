import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// Folder-scope summary cards above the children list.
///
/// The canonical Folder Detail mock shows a mastery summary card in the decks
/// state, plus the direct-children stat strip in subfolders state. The current
/// read model does not expose folder-scoped study data, so this summary uses a
/// non-numeric "mastery unavailable" shell and omits any fake new-count value.
class FolderDecksSummary extends StatelessWidget {
  const FolderDecksSummary({
    required this.decks,
    required this.onStartStudy,
    super.key,
  });

  final List<DeckWithCount> decks;
  final VoidCallback? onStartStudy;

  int get _cardTotal =>
      decks.fold<int>(0, (int sum, DeckWithCount d) => sum + d.cardCount);

  int get _dueTotal =>
      decks.fold<int>(0, (int sum, DeckWithCount d) => sum + d.dueCount);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int dueTotal = _dueTotal;
    final bool canStartStudy = dueTotal > 0 && onStartStudy != null;
    final String countsLine =
        '${l10n.libraryFolderDecksCount(decks.length)} · '
        '${l10n.libraryFolderCardsCount(_cardTotal)}';
    final String dueLine = dueTotal > 0
        ? l10n.libraryFolderDueCount(dueTotal)
        : l10n.folderSummaryAllCaughtUp;
    final String startStudyLabel = dueTotal > 0
        ? '${l10n.folderDetailStartStudyLabel} · '
              '${l10n.libraryFolderDueCount(dueTotal)}'
        : l10n.folderDetailStartStudyLabel;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MxIconTile(
                icon: Icons.insights_outlined,
                size: SizeTokens.avatar,
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      l10n.folderDetailMasteryUnavailableLabel,
                      role: MxTextRole.labelMedium,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      countsLine,
                      role: MxTextRole.titleSmall,
                      fontWeight: TypographyTokens.bold,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      dueLine,
                      role: MxTextRole.labelMedium,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          MxActionButton(
            intent: MxActionIntent.studyPrimary,
            label: startStudyLabel,
            icon: Icons.play_arrow_outlined,
            fullWidth: true,
            onPressed: canStartStudy ? onStartStudy : null,
          ),
        ],
      ),
    );
  }
}

/// Subfolders-mode summary: a three-stat strip (subfolders · cards · due total)
/// over the folder's direct children.
class FolderSubfoldersSummary extends StatelessWidget {
  const FolderSubfoldersSummary({required this.subfolders, super.key});

  final List<FolderWithCount> subfolders;

  int get _cardTotal => subfolders.fold<int>(
    0,
    (int sum, FolderWithCount f) => sum + f.cardCount,
  );

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
          _FolderStatItem(
            value: _cardTotal,
            label: l10n.folderSummaryCardsStat,
          ),
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

/// Hairline separator between stats — a tokenized 1px [ColoredBox].
class _FolderStatDivider extends StatelessWidget {
  const _FolderStatDivider();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
    child: ColoredBox(
      color: context.colorScheme.outlineVariant,
      child: const SizedBox(
        width: BorderTokens.width,
        height: SizeTokens.iconLg,
      ),
    ),
  );
}
