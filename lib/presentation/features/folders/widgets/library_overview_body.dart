import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/controllers/library_action_controller.dart';
import 'package:memox/presentation/features/folders/folder_failure_message.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/folder_rename_dialog.dart';
import 'package:memox/presentation/features/folders/widgets/library_create_folder_action.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_loading_skeleton.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/sort/library_sort_provider.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Library Overview body: the streamed folder list rendered as one grouped
/// card, with its loading / loaded / true-empty / search-no-results / error
/// states, plus the folder overflow actions. The search field + Cancel live in
/// the app bar (`LibrarySearchAppBar`), not here. WBS 3.1.2.
class LibraryOverviewBody extends ConsumerWidget {
  const LibraryOverviewBody({super.key});

  /// Inset for the inter-row hairline: tile width + the row's leading gap, so
  /// the divider starts under the text (mirrors the kit `.hr.inset`).
  static const double _dividerInset = MxSpacing.space10 + MxSpacing.space3;

  void _clearSearch(WidgetRef ref) =>
      ref.read(librarySearchQueryProvider.notifier).clear();

  void _openFolder(BuildContext context, FolderSummary summary) =>
      context.pushNamed(
        RouteNames.folderDetail,
        pathParameters: <String, String>{RouteParams.id: summary.folder.id},
      );

  void _reportResult(
    BuildContext context,
    Failure? failure,
    String successMessage,
  ) {
    if (failure != null) {
      showMxSnackbar(
        context,
        message: folderFailureMessage(AppLocalizations.of(context), failure),
        isError: true,
      );
      return;
    }
    showMxSnackbar(context, message: successMessage);
  }

  Future<void> _onFolderActions(
    BuildContext context,
    WidgetRef ref,
    FolderSummary summary,
  ) async {
    final FolderAction? action = await showFolderActionsSheet(
      context,
      summary: summary,
    );
    if (action == null) return;
    if (!context.mounted) return;
    switch (action) {
      case FolderAction.rename:
        await _rename(context, ref, summary);
      case FolderAction.move:
        await _move(context, ref, summary);
      case FolderAction.delete:
        await _delete(context, ref, summary);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    FolderSummary summary,
  ) async {
    final String? newName = await showFolderRenameDialog(
      context,
      currentName: summary.folder.name,
    );
    if (newName == null) return;
    if (!context.mounted) return;
    final String successMessage = AppLocalizations.of(
      context,
    ).folderRenamedSnack;
    final Result<Folder> result = await ref
        .read(libraryActionControllerProvider.notifier)
        .rename(id: summary.folder.id, newName: newName);
    if (!context.mounted) return;
    _reportResult(context, result.failure, successMessage);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    FolderSummary summary,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await MxConfirmDialog.show(
      context,
      title: l10n.folderDeleteTitle,
      message: l10n.folderDeleteBlastRadius(
        summary.deckCount,
        summary.cardCount,
      ),
      confirmLabel: l10n.folderDeleteConfirm,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) return;
    if (!context.mounted) return;
    final String successMessage = l10n.folderDeletedSnack;
    final Result<void> result = await ref
        .read(libraryActionControllerProvider.notifier)
        .delete(id: summary.folder.id);
    if (!context.mounted) return;
    _reportResult(context, result.failure, successMessage);
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    FolderSummary summary,
  ) async {
    final String successMessage = AppLocalizations.of(context).folderMovedSnack;
    final LibraryActionController controller = ref.read(
      libraryActionControllerProvider.notifier,
    );
    final Result<List<FolderMoveTarget>> targets = await controller.moveTargets(
      folderId: summary.folder.id,
    );
    if (!context.mounted) return;
    final List<FolderMoveTarget>? candidates = targets.data;
    if (candidates == null) {
      _reportResult(context, targets.failure, successMessage);
      return;
    }
    final FolderMoveTarget? destination = await showFolderMovePicker(
      context,
      targets: candidates,
    );
    if (destination == null) return;
    if (!context.mounted) return;
    final Result<Folder> result = await controller.move(
      id: summary.folder.id,
      newParentId: destination.id,
    );
    if (!context.mounted) return;
    _reportResult(context, result.failure, successMessage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<LibraryOverview> overview = ref.watch(
      libraryOverviewStreamProvider,
    );
    final String term = ref.watch(librarySearchQueryProvider);

    return AppAsyncBuilder<LibraryOverview>(
      value: overview,
      loading: (_) => ListView(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        children: const <Widget>[LibraryLoadingSkeleton()],
      ),
      error: (_, _) => MxErrorState(
        title: l10n.libraryLoadFailedTitle,
        message: l10n.libraryLoadFailedMessage,
        icon: Icons.cloud_off_outlined,
        action: MxPrimaryButton(
          label: l10n.libraryRetryLabel,
          icon: Icons.refresh,
          fullWidth: true,
          onPressed: () => ref.invalidate(libraryOverviewStreamProvider),
        ),
      ),
      data: (LibraryOverview data) =>
          _content(context, ref, filterLibrary(data, term)),
    );
  }

  Widget _content(BuildContext context, WidgetRef ref, LibraryListView view) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<FolderSummary> folders = sortLibraryFolders(
      view.folders,
      ref.watch(librarySortModeProvider(sortScopeLibrary)),
    );

    if (view.totalFolderCount == 0) {
      return MxEmptyState(
        icon: Icons.folder_outlined,
        title: l10n.libraryEmptyTitle,
        message: l10n.libraryEmptyMessage,
        action: MxPrimaryButton(
          label: l10n.libraryCreateFolderLabel,
          icon: Icons.create_new_folder_outlined,
          fullWidth: true,
          onPressed: () => runCreateFolder(context, ref),
        ),
      );
    }
    if (folders.isEmpty && view.searchTerm.isNotEmpty) {
      return MxNoResultsState(
        key: const ValueKey<String>('library_search_no_results'),
        title: l10n.librarySearchNoResultsTitle,
        message: l10n.librarySearchNoResultsMessage(view.searchTerm),
        action: MxSecondaryButton(
          label: l10n.librarySearchClearLabel,
          onPressed: () => _clearSearch(ref),
        ),
      );
    }

    final bool searching = view.searchTerm.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
      children: <Widget>[
        // Loaded shows the bare card (mock `03a`); search adds the count overline
        // (mock `03e`).
        if (searching) ...<Widget>[
          _CountOverline(count: folders.length),
          const SizedBox(height: MxSpacing.space3),
        ],
        _groupedCard(context, ref, folders),
      ],
    );
  }

  Widget _groupedCard(
    BuildContext context,
    WidgetRef ref,
    List<FolderSummary> folders,
  ) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < folders.length; i++) {
      if (i > 0) {
        rows.add(const MxDivider(indent: _dividerInset));
      }
      final FolderSummary summary = folders[i];
      rows.add(
        LibraryFolderTile(
          summary: summary,
          onTap: () => _openFolder(context, summary),
          onActions: () => _onFolderActions(context, ref, summary),
        ),
      );
    }
    return MxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.card,
        vertical: MxSpacing.space2,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

/// The `{n} FOLDERS` count overline shown above search results (mock `03e`).
class _CountOverline extends StatelessWidget {
  const _CountOverline({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxText(
      StringUtils.upperFold(
        AppLocalizations.of(context).libraryFolderCountHeader(count),
      ),
      role: MxTextRole.labelMedium,
      color: colors.textSecondary,
    );
  }
}
