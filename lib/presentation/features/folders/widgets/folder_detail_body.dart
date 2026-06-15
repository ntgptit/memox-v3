import 'package:flutter/material.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_deck_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_summary.dart';
import 'package:memox/presentation/features/folders/widgets/folder_subfolder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_unlocked_empty.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Renders a loaded [FolderDetail] — the subfolders or decks list, the
/// unlocked mode-choice, the empty-locked state, or search-no-results.
class FolderDetailBody extends StatelessWidget {
  const FolderDetailBody({
    required this.detail,
    required this.isSearching,
    required this.searchTerm,
    required this.sort,
    required this.onStudyNew,
    required this.onReviewDue,
    required this.onNewSubfolder,
    required this.onNewDeck,
    required this.onClearSearch,
    required this.onShowSubfolderActions,
    required this.onShowDeckActions,
    required this.onSearchTap,
    required this.onSortTap,
    super.key,
  });

  final FolderDetail detail;
  final bool isSearching;
  final String searchTerm;
  final ContentSortMode sort;
  final VoidCallback? onStudyNew;
  final VoidCallback? onReviewDue;
  final VoidCallback onNewSubfolder;
  final VoidCallback onNewDeck;
  final VoidCallback onClearSearch;
  final void Function(FolderWithCount item) onShowSubfolderActions;
  final void Function(DeckWithCount item) onShowDeckActions;
  final VoidCallback onSearchTap;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ContentMode mode = detail.folder.contentMode;
    if (mode == ContentMode.unlocked) {
      return FolderUnlockedEmpty(
        onNewSubfolder: onNewSubfolder,
        onNewDeck: onNewDeck,
      );
    }

    final List<FolderWithCount> subfolders = detail.subfolders;
    final List<DeckWithCount> decks = detail.decks;
    final bool isSubfolderMode = mode == ContentMode.subfolders;
    final bool hasChildren = isSubfolderMode
        ? subfolders.isNotEmpty
        : decks.isNotEmpty;

    if (!hasChildren && !isSearching) {
      return MxEmptyState(
        icon: Icons.folder_open_outlined,
        title: l10n.folderEmptyLockedTitle,
        message: l10n.folderEmptyLockedMessage,
      );
    }

    final Widget summary = switch (mode) {
      ContentMode.subfolders => FolderSubfoldersSummary(subfolders: subfolders),
      ContentMode.decks => FolderDecksSummary(
        decks: decks,
        onStudyNew: onStudyNew,
        onReviewDue: onReviewDue,
      ),
      ContentMode.unlocked => const SizedBox.shrink(),
    };
    final String countLabel = switch (mode) {
      ContentMode.subfolders => l10n.libraryFolderSubfoldersCount(
        subfolders.length,
      ),
      ContentMode.decks => l10n.libraryFolderDecksCount(decks.length),
      ContentMode.unlocked => '',
    };
    final String sortLabel = switch (sort) {
      ContentSortMode.manual => l10n.folderDetailSortManualLabel,
      ContentSortMode.name => l10n.folderDetailSortNameLabel,
      ContentSortMode.newest => l10n.folderDetailSortNewestLabel,
      ContentSortMode.lastStudied => l10n.folderDetailSortManualLabel,
    };
    if (!hasChildren) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        children: <Widget>[
          summary,
          const SizedBox(height: SpacingTokens.md),
          _FolderDetailHeader(
            countLabel: countLabel,
            sortLabel: sortLabel,
            onSearchTap: onSearchTap,
            onSortTap: onSortTap,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _FolderDetailSearchEmpty(
            query: searchTerm,
            onClearSearch: onClearSearch,
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
      itemCount: _itemCount(mode: mode, subfolders: subfolders, decks: decks),
      itemBuilder: (BuildContext context, int index) => switch (index) {
        0 => summary,
        1 => const SizedBox(height: SpacingTokens.md),
        2 => _FolderDetailHeader(
          countLabel: countLabel,
          sortLabel: sortLabel,
          onSearchTap: onSearchTap,
          onSortTap: onSortTap,
        ),
        3 => const SizedBox(height: SpacingTokens.sm),
        _ => _buildChild(
          context: context,
          mode: mode,
          subfolders: subfolders,
          decks: decks,
          onShowSubfolderActions: onShowSubfolderActions,
          onShowDeckActions: onShowDeckActions,
          index: index - 4,
        ),
      },
    );
  }

  int _itemCount({
    required ContentMode mode,
    required List<FolderWithCount> subfolders,
    required List<DeckWithCount> decks,
  }) {
    final int childCount = switch (mode) {
      ContentMode.subfolders => subfolders.length,
      ContentMode.decks => decks.length,
      ContentMode.unlocked => 0,
    };
    return 4 + childCount;
  }

  Widget _buildChild({
    required BuildContext context,
    required ContentMode mode,
    required List<FolderWithCount> subfolders,
    required List<DeckWithCount> decks,
    required void Function(FolderWithCount item) onShowSubfolderActions,
    required void Function(DeckWithCount item) onShowDeckActions,
    required int index,
  }) => switch (mode) {
    ContentMode.subfolders => _buildFolderChild(
      context: context,
      item: subfolders[index],
      isFolder: true,
      onShowSubfolderActions: onShowSubfolderActions,
      onShowDeckActions: onShowDeckActions,
    ),
    ContentMode.decks => _buildFolderChild(
      context: context,
      item: decks[index],
      isFolder: false,
      onShowSubfolderActions: onShowSubfolderActions,
      onShowDeckActions: onShowDeckActions,
    ),
    ContentMode.unlocked => const SizedBox.shrink(),
  };

  Widget _buildFolderChild({
    required BuildContext context,
    required Object item,
    required bool isFolder,
    required void Function(FolderWithCount item) onShowSubfolderActions,
    required void Function(DeckWithCount item) onShowDeckActions,
  }) {
    if (isFolder) {
      final FolderWithCount folder = item as FolderWithCount;
      return Column(
        children: <Widget>[
          FolderSubfolderTile(
            item: folder,
            onTap: () => context.pushFolderDetail(folder.folder.id),
            onShowActions: () => onShowSubfolderActions(folder),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      );
    }

    final DeckWithCount deck = item as DeckWithCount;
    return Column(
      children: <Widget>[
        FolderDeckTile(
          item: deck,
          onTap: () => context.pushFlashcardList(deck.deck.id),
          onShowActions: () => onShowDeckActions(deck),
        ),
        const SizedBox(height: SpacingTokens.sm),
      ],
    );
  }
}

class _FolderDetailHeader extends StatelessWidget {
  const _FolderDetailHeader({
    required this.countLabel,
    required this.sortLabel,
    required this.onSearchTap,
    required this.onSortTap,
  });

  final String countLabel;
  final String sortLabel;
  final VoidCallback onSearchTap;
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: MxSectionHeader(label: countLabel)),
        const SizedBox(width: SpacingTokens.sm),
        MxIconButton(
          icon: Icons.search,
          tooltip: AppLocalizations.of(context).folderDetailSearchHint,
          onPressed: onSearchTap,
          size: MxIconButtonSize.compact,
        ),
        const SizedBox(width: SpacingTokens.xxs),
        _SortPill(label: sortLabel, onTap: onSortTap),
      ],
    ),
  );
}

class _SortPill extends StatelessWidget {
  const _SortPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MxTappable(
    borderRadius: RadiusTokens.brFull,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.swap_vert_rounded,
            size: SizeTokens.iconTiny,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.xs),
          MxText(
            label,
            role: MxTextRole.labelMedium,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: SizeTokens.iconTiny,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    ),
  );
}

class _FolderDetailSearchEmpty extends StatelessWidget {
  const _FolderDetailSearchEmpty({
    required this.query,
    required this.onClearSearch,
  });

  final String query;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey<String>('folder_detail_search_empty_card'),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xl,
        vertical: SpacingTokens.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: SizeTokens.buttonLg,
            height: SizeTokens.buttonLg,
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: RadiusTokens.brLg,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.search_rounded,
              size: SizeTokens.surfaceBadge,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          MxText(
            l10n.folderDetailNoResultsTitle(query),
            role: MxTextRole.titleMedium,
            fontWeight: TypographyTokens.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.xs),
          MxText(
            l10n.folderDetailNoResultsMessage,
            role: MxTextRole.bodyMedium,
            color: context.colorScheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.lg),
          MxSecondaryButton(
            label: l10n.commonClear,
            onPressed: onClearSearch,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class FolderDetailSkeleton extends StatelessWidget {
  const FolderDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) => ListView.separated(
    key: const ValueKey<String>('folder_detail_skeleton'),
    padding: const EdgeInsets.fromLTRB(
      0,
      SpacingTokens.inline,
      0,
      SpacingTokens.md,
    ),
    itemCount: 4,
    itemBuilder: (BuildContext context, int index) =>
        const _FolderDetailSkeletonRow(),
    separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(height: SpacingTokens.inline),
  );
}

class _FolderDetailSkeletonRow extends StatelessWidget {
  const _FolderDetailSkeletonRow();

  @override
  Widget build(BuildContext context) => const MxCard(
    padding: EdgeInsets.symmetric(
      horizontal: SpacingTokens.lg,
      vertical: SpacingTokens.md,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MxSkeleton(
          width: SizeTokens.avatar,
          height: SizeTokens.avatar,
          borderRadius: RadiusTokens.brMd,
        ),
        SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FractionallySizedBox(
                widthFactor: 0.42,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 13),
              ),
              SizedBox(height: SpacingTokens.xs),
              FractionallySizedBox(
                widthFactor: 0.54,
                alignment: Alignment.centerLeft,
                child: MxSkeleton(height: 11),
              ),
              SizedBox(height: SpacingTokens.sm),
              Row(
                children: <Widget>[
                  Expanded(child: MxSkeleton(height: 4)),
                  SizedBox(width: SpacingTokens.sm),
                  MxSkeleton(
                    width: SizeTokens.iconMinor,
                    height: SizeTokens.iconMinor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
