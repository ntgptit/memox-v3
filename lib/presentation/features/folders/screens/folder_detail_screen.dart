import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_actions.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_body.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_search.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/navigation/library_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';

/// Folder Detail — the content browser one level down: a folder's subfolders or
/// decks, with a stats summary, search, folder/deck management, and a
/// content-aware create FAB. Tapping a subfolder pushes a nested Folder Detail;
/// tapping a deck opens its flashcard list. WBS 3.2.2.
class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({required this.folderId, super.key});

  final String folderId;

  FolderSummary _viewedSummary(FolderDetail d) => FolderSummary(
    folder: d.folder,
    subfolderCount: d.subfolders.length,
    deckCount: d.deckCount,
    cardCount: d.cardCount,
    dueCount: d.dueCount,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // guard:allow-screen-watch -- reason: the app bar swaps to search mode, the
    // FAB is content-mode aware, and the breadcrumb/title come from the folder
    // stream, so the shell reacts to search-active + detail state; a body widget
    // cannot own the app-bar/FAB/breadcrumb decisions.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool searching = ref.watch(folderSearchActiveProvider(folderId));
    final AsyncValue<FolderDetail?> detailAsync = ref.watch(
      folderDetailStreamProvider(folderId),
    );
    final FolderDetail? detail = detailAsync.value;

    // Pop back to the parent when the viewed folder is deleted (its own
    // overflow Delete, or a delete from elsewhere) so we never sit on a dead
    // screen.
    ref.listen<AsyncValue<FolderDetail?>>(
      folderDetailStreamProvider(folderId),
      (AsyncValue<FolderDetail?>? prev, AsyncValue<FolderDetail?> next) {
        final bool gone = next.hasValue && next.value == null;
        if (!gone) return;
        if (!context.mounted) return;
        if (Navigator.of(context).canPop()) context.pop();
      },
    );

    final ContentMode mode = detail?.folder.contentMode ?? ContentMode.unlocked;
    final Widget? fab = _fab(context, ref, l10n, searching, mode);

    return MxScaffold(
      appBar: searching
          ? FolderDetailSearchAppBar(folderId: folderId)
          : MxAppBar(
              title: detail?.folder.name ?? '',
              actions: <Widget>[
                MxIconButton(
                  icon: Icons.search,
                  tooltip: l10n.folderDetailSearchTooltip,
                  onPressed: () => ref
                      .read(folderSearchActiveProvider(folderId).notifier)
                      .activate(),
                ),
                if (detail != null)
                  MxIconButton(
                    icon: Icons.more_vert,
                    tooltip: l10n.libraryOverflowTooltip,
                    onPressed: () =>
                        runFolderActions(context, ref, _viewedSummary(detail)),
                  ),
              ],
            ),
      floatingActionButton: fab,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Ancestry trail docked under the app bar (design redesign). Hidden in
          // search mode and until the folder (with its breadcrumb) has loaded.
          if (!searching && detail != null)
            Padding(
              padding: const EdgeInsets.only(bottom: MxSpacing.space2),
              child: MxBreadcrumb(
                items: buildLibraryBreadcrumb(
                  context,
                  rootLabel: l10n.libraryRootLabel,
                  folders: detail.breadcrumb,
                ),
              ),
            ),
          Expanded(child: FolderDetailBody(folderId: folderId)),
        ],
      ),
    );
  }

  /// The create FAB matches the folder's content mode (mock `04`): a decks-mode
  /// folder gets a `Create deck` FAB, a subfolders-mode folder a `Create
  /// subfolder` FAB. An unlocked (empty) folder shows no FAB — its empty state
  /// offers both CTAs. Hidden while searching.
  Widget? _fab(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    bool searching,
    ContentMode mode,
  ) {
    if (searching) return null;
    return switch (mode) {
      ContentMode.decks => MxFab(
        icon: Icons.style_outlined,
        tooltip: l10n.folderDetailCreateDeck,
        onPressed: () => runCreateDeck(context, ref, folderId),
      ),
      ContentMode.subfolders => MxFab(
        icon: Icons.create_new_folder_outlined,
        tooltip: l10n.folderDetailCreateSubfolder,
        onPressed: () => runCreateSubfolder(context, ref, folderId),
      ),
      ContentMode.unlocked => null,
    };
  }
}
