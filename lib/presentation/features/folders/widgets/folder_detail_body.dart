import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/deck_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_actions.dart';
import 'package:memox/presentation/features/folders/widgets/folder_stats_card.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_loading_skeleton.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/sort/content_sort.dart';
import 'package:memox/presentation/shared/sort/library_sort_provider.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_state_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Folder-detail body: the streamed subfolders + decks rendered as a stats card
/// + a grouped list, with loading / empty-unlocked / search-no-results / error
/// states. WBS 3.2.2.
class FolderDetailBody extends ConsumerWidget {
  const FolderDetailBody({required this.folderId, super.key});

  static const double _dividerInset = MxSpacing.space10 + MxSpacing.space3;

  final String folderId;

  void _openSubfolder(BuildContext context, FolderSummary s) =>
      context.pushNamed(
        RouteNames.folderDetail,
        pathParameters: <String, String>{RouteParams.id: s.folder.id},
      );

  void _openDeck(BuildContext context, DeckSummary d) => context.pushNamed(
    RouteNames.deckFlashcards,
    pathParameters: <String, String>{RouteParams.deckId: d.deck.id},
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<FolderDetail?> detail = ref.watch(
      folderDetailStreamProvider(folderId),
    );
    final String term = ref.watch(folderSearchQueryProvider(folderId));

    return AppAsyncBuilder<FolderDetail?>(
      value: detail,
      loading: (_) => ListView(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        children: const <Widget>[LibraryLoadingSkeleton()],
      ),
      error: (_, _) => _error(context, ref, l10n),
      data: (FolderDetail? data) => data == null
          ? _error(context, ref, l10n)
          : _content(context, ref, filterFolderDetail(data, term)),
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, AppLocalizations l10n) =>
      MxStateCard(
        child: MxErrorState(
          title: l10n.folderDetailLoadFailedTitle,
          message: l10n.folderDetailLoadFailedMessage,
          icon: Icons.cloud_off_outlined,
          action: MxPrimaryButton(
            label: l10n.commonRetryLabel,
            icon: Icons.refresh,
            fullWidth: true,
            onPressed: () =>
                ref.invalidate(folderDetailStreamProvider(folderId)),
          ),
        ),
      );

  Widget _content(BuildContext context, WidgetRef ref, FolderDetailView view) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final FolderDetail detail = view.detail;
    final ContentMode mode = detail.folder.contentMode;
    final bool decksMode = mode == ContentMode.decks || view.totalDecks > 0;
    final bool subfoldersMode =
        mode == ContentMode.subfolders || view.totalSubfolders > 0;

    // True-empty unlocked folder → hero with both create CTAs.
    if (!decksMode && !subfoldersMode) {
      return MxStateCard(
        child: MxEmptyState(
          icon: Icons.folder_open_outlined,
          title: l10n.folderDetailEmptyTitle,
          message: l10n.folderDetailEmptyMessage,
          action: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              MxPrimaryButton(
                label: l10n.folderDetailCreateDeck,
                icon: Icons.style_outlined,
                fullWidth: true,
                onPressed: () => runCreateDeck(context, ref, folderId),
              ),
              const SizedBox(height: MxSpacing.space3),
              MxSecondaryButton(
                label: l10n.folderDetailCreateSubfolder,
                icon: Icons.create_new_folder_outlined,
                variant: MxSecondaryVariant.outlined,
                fullWidth: true,
                onPressed: () => runCreateSubfolder(context, ref, folderId),
              ),
            ],
          ),
        ),
      );
    }

    final bool searching = view.searchTerm.isNotEmpty;
    final int visible = view.subfolders.length + view.decks.length;
    if (searching && visible == 0) {
      return MxNoResultsState(
        key: const ValueKey<String>('folder_detail_search_no_results'),
        title: l10n.librarySearchNoResultsTitle,
        message: l10n.librarySearchNoResultsMessage(view.searchTerm),
        action: MxSecondaryButton(
          label: l10n.librarySearchClearLabel,
          onPressed: () =>
              ref.read(folderSearchQueryProvider(folderId).notifier).clear(),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
      children: <Widget>[
        FolderStatsCard(
          key: const ValueKey<String>('mx-node:04-folder-detail/stat-card'),
          stats: _stats(l10n, view, decksMode),
        ),
        const SizedBox(height: MxSpacing.gapSection),
        _Overline(
          label: decksMode
              ? l10n.folderDetailDecksHeader(view.decks.length)
              : l10n.folderDetailFoldersHeader(view.subfolders.length),
        ),
        const SizedBox(height: MxSpacing.space3),
        _groupedCard(context, ref, view),
      ],
    );
  }

  List<FolderStat> _stats(
    AppLocalizations l10n,
    FolderDetailView view,
    bool decksMode,
  ) {
    final FolderDetail d = view.detail;
    if (decksMode) {
      return <FolderStat>[
        (value: d.deckCount, label: l10n.folderStatDecks),
        (value: d.cardCount, label: l10n.folderStatCards),
        (value: d.dueCount, label: l10n.folderStatDue),
      ];
    }
    return <FolderStat>[
      (value: view.totalSubfolders, label: l10n.folderStatSubfolders),
      (value: d.subtreeDeckCount, label: l10n.folderStatDecks),
      (value: d.dueCount, label: l10n.folderStatDue),
    ];
  }

  Widget _groupedCard(BuildContext context, WidgetRef ref, FolderDetailView v) {
    final ContentSortMode sort = ref.watch(
      librarySortModeProvider(sortScopeFolder(folderId)),
    );
    final List<FolderSummary> subfolders = sortByContentMode<FolderSummary>(
      v.subfolders,
      sort,
      name: (FolderSummary s) => s.folder.name,
      createdAt: (FolderSummary s) => s.folder.createdAt,
    );
    final List<DeckSummary> decks = sortByContentMode<DeckSummary>(
      v.decks,
      sort,
      name: (DeckSummary d) => d.deck.name,
      createdAt: (DeckSummary d) => d.deck.createdAt,
    );
    final List<Widget> rows = <Widget>[];
    void addDivider() {
      if (rows.isNotEmpty) {
        rows.add(const MxDivider(indent: _dividerInset));
      }
    }

    for (final FolderSummary s in subfolders) {
      addDivider();
      rows.add(
        LibraryFolderTile(
          summary: s,
          onTap: () => _openSubfolder(context, s),
          onActions: () => runFolderActions(context, ref, s),
        ),
      );
    }
    for (final DeckSummary d in decks) {
      addDivider();
      rows.add(
        DeckTile(
          summary: d,
          onTap: () => _openDeck(context, d),
          onActions: () => runDeckActions(context, ref, d),
        ),
      );
    }
    return MxCard(
      key: const ValueKey<String>('mx-node:04-folder-detail/deck-list'),
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.card,
        vertical: MxSpacing.space2,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

class _Overline extends StatelessWidget {
  const _Overline({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxText(
      StringUtils.upperFold(label),
      role: MxTextRole.labelMedium,
      color: colors.textSecondary,
    );
  }
}
