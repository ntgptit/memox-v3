import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_sort_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/library_create_folder_action.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';
import 'package:memox/presentation/features/folders/widgets/library_root_anchor.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_dock.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/sort/content_sort_sheet.dart';
import 'package:memox/presentation/shared/sort/library_sort_provider.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Library Overview — the root content browser: top-level folders with their
/// recursive counts (grouped card), folder search, folder management via the
/// row overflow sheet, and a `New folder` FAB. State handling lives in
/// [LibraryOverviewBody].
///
/// V1 scope (`docs/design/screens/library-overview.visual-contract.md`): the
/// header sort icon opens the shared content-sort sheet (Manual / Name / Newest;
/// `lastStudied` deferred) and persists the choice globally (WBS 2.23.1). A
/// folder-row tap opens the action sheet until folder-detail navigation lands
/// (WBS 3.2.2). WBS 3.1.2 / 2.1.2.
class LibraryOverviewScreen extends ConsumerWidget {
  const LibraryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // guard:allow-screen-watch -- reason: search mode mounts the bottom dock and
    // the FAB depends on the loaded folder list, so the shell must react to
    // search-active + stream state; pushing these into a body widget would split
    // the dock/FAB decision away from where it is applied.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool searching = ref.watch(librarySearchActiveProvider);
    // The FAB and the root anchor both show only in the loaded-with-folders
    // state (mock `03a`): the true-empty state offers its own inline CTA, and
    // loading / error / search suppress them (mocks `03b` / `03c` / `03d` /
    // `03e`).
    final LibraryOverview? overview = ref
        .watch(libraryOverviewStreamProvider)
        .value;
    final int folderCount = overview?.folders.length ?? 0;
    final bool hasFolders = folderCount > 0;
    final bool showFab = !searching && hasFolders;

    return MxScaffold(
      // The regular Library app bar stays in place while searching (mock `03`
      // Search state keeps the title + sort); the search field drops into the
      // bottom dock instead of swapping the app bar.
      appBar: MxAppBar(
        title: l10n.libraryTitle,
        actions: <Widget>[
          MxIconButton(
            icon: Icons.search,
            tooltip: l10n.librarySearchTooltip,
            onPressed: () => _toggleSearch(ref, searching),
          ),
          MxIconButton(
            key: const ValueKey<String>('mx-node:03-library/sort-btn'),
            icon: Icons.swap_vert,
            tooltip: l10n.sortTooltip,
            onPressed: () => _openSort(context, ref),
          ),
        ],
      ),
      floatingActionButton: showFab
          ? MxFab(
              key: const ValueKey<String>('mx-node:03-library/new-folder-fab'),
              icon: Icons.create_new_folder_outlined,
              tooltip: l10n.libraryCreateFolderTooltip,
              onPressed: () => runCreateFolder(context, ref),
            )
          : null,
      // The search dock is a flat, full-bleed bar pinned under the content
      // (kit `03` Search `search-dock`); the bottom-nav slot renders it without
      // the rounded/elevated BottomSheet chrome and reserves its own foot room.
      bottomNavigationBar: searching
          ? const LibrarySearchDock(
              key: ValueKey<String>('mx-node:03-library/search-dock'),
            )
          : null,
      body: _buildBody(searching, hasFolders, folderCount),
    );
  }

  /// Toggles search mode from the app-bar icon: entering mounts the bottom dock;
  /// exiting clears the term so the next entry starts fresh.
  void _toggleSearch(WidgetRef ref, bool searching) {
    if (!searching) {
      ref.read(librarySearchActiveProvider.notifier).activate();
      return;
    }
    ref.read(librarySearchQueryProvider.notifier).clear();
    ref.read(librarySearchActiveProvider.notifier).deactivate();
  }

  /// Opens the shared sort sheet and persists the chosen mode for the Library
  /// scope (each object keeps its own sort).
  Future<void> _openSort(BuildContext context, WidgetRef ref) async {
    final ContentSortMode current = ref.read(
      librarySortModeProvider(sortScopeLibrary),
    );
    final ContentSortMode? selected = await showContentSortSheet(
      context,
      current: current,
    );
    if (selected == null) return;
    await ref
        .read(librarySortProvider(sortScopeLibrary).notifier)
        .setSort(selected);
  }

  Widget _buildBody(bool searching, bool hasFolders, int folderCount) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      // Root orientation anchor docked under the app bar — the root of the same
      // breadcrumb trail nested Library screens show. Hidden in search and until
      // the loaded list has folders (matches the FAB gating).
      if (!searching && hasFolders)
        Padding(
          padding: const EdgeInsets.only(bottom: MxSpacing.space2),
          child: LibraryRootAnchor(folderCount: folderCount),
        ),
      const Expanded(child: LibraryOverviewBody()),
    ],
  );
}
