import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
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
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';

/// Library Overview body: inline search + the streamed folder list with its
/// loading / loaded / true-empty / search-no-results / error states, plus the
/// folder overflow actions. WBS 3.1.2 (+ 2.2.2 / 2.3.2 / 2.4.2 / 2.21.1).
class LibraryOverviewBody extends ConsumerStatefulWidget {
  const LibraryOverviewBody({super.key});

  @override
  ConsumerState<LibraryOverviewBody> createState() =>
      _LibraryOverviewBodyState();
}

class _LibraryOverviewBodyState extends ConsumerState<LibraryOverviewBody> {
  void _clearSearch() => ref.read(librarySearchQueryProvider.notifier).clear();

  void _reportResult(Failure? failure, String successMessage) {
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

  Future<void> _onFolderActions(FolderSummary summary) async {
    final FolderAction? action = await showFolderActionsSheet(
      context,
      folderName: summary.folder.name,
    );
    if (action == null) return;
    if (!mounted) return;
    switch (action) {
      case FolderAction.rename:
        await _rename(summary);
      case FolderAction.move:
        await _move(summary);
      case FolderAction.delete:
        await _delete(summary);
    }
  }

  Future<void> _rename(FolderSummary summary) async {
    final String? newName = await showFolderRenameDialog(
      context,
      currentName: summary.folder.name,
    );
    if (newName == null) return;
    if (!mounted) return;
    final String successMessage = AppLocalizations.of(
      context,
    ).folderRenamedSnack;
    final Result<Folder> result = await ref
        .read(libraryActionControllerProvider.notifier)
        .rename(id: summary.folder.id, newName: newName);
    if (!mounted) return;
    _reportResult(result.failure, successMessage);
  }

  Future<void> _delete(FolderSummary summary) async {
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
    if (!mounted) return;
    final String successMessage = l10n.folderDeletedSnack;
    final Result<void> result = await ref
        .read(libraryActionControllerProvider.notifier)
        .delete(id: summary.folder.id);
    if (!mounted) return;
    _reportResult(result.failure, successMessage);
  }

  Future<void> _move(FolderSummary summary) async {
    final String successMessage = AppLocalizations.of(context).folderMovedSnack;
    final LibraryActionController controller = ref.read(
      libraryActionControllerProvider.notifier,
    );
    final Result<List<FolderMoveTarget>> targets = await controller.moveTargets(
      folderId: summary.folder.id,
    );
    if (!mounted) return;
    final List<FolderMoveTarget>? candidates = targets.data;
    if (candidates == null) {
      _reportResult(targets.failure, successMessage);
      return;
    }
    final FolderMoveTarget? destination = await showFolderMovePicker(
      context,
      targets: candidates,
    );
    if (destination == null) return;
    if (!mounted) return;
    final Result<Folder> result = await controller.move(
      id: summary.folder.id,
      newParentId: destination.id,
    );
    if (!mounted) return;
    _reportResult(result.failure, successMessage);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<LibraryOverview> overview = ref.watch(
      libraryOverviewStreamProvider,
    );
    final String term = ref.watch(librarySearchQueryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(vertical: MxSpacing.space3),
          child: LibrarySearchField(),
        ),
        Expanded(
          child: AppAsyncBuilder<LibraryOverview>(
            value: overview,
            loading: (_) => MxLoadingState(message: l10n.libraryLoadingLabel),
            error: (_, _) => MxErrorState(
              title: l10n.libraryLoadFailedTitle,
              message: l10n.libraryLoadFailedMessage,
              icon: Icons.cloud_off_outlined,
              action: MxSecondaryButton(
                label: l10n.libraryRetryLabel,
                onPressed: () => ref.invalidate(libraryOverviewStreamProvider),
              ),
            ),
            data: (LibraryOverview data) =>
                _content(context, filterLibrary(data, term)),
          ),
        ),
      ],
    );
  }

  Widget _content(BuildContext context, LibraryListView view) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (view.totalFolderCount == 0) {
      return MxEmptyState(
        icon: Icons.folder_outlined,
        title: l10n.libraryEmptyTitle,
        message: l10n.libraryEmptyMessage,
      );
    }
    if (view.folders.isEmpty && view.searchTerm.isNotEmpty) {
      return MxNoResultsState(
        key: const ValueKey<String>('library_search_no_results'),
        title: l10n.librarySearchNoResultsTitle,
        message: l10n.librarySearchNoResultsMessage(view.searchTerm),
        action: MxSecondaryButton(
          label: l10n.librarySearchClearLabel,
          onPressed: _clearSearch,
        ),
      );
    }

    final MxColors colors = context.mxColors;
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: MxSpacing.space12),
      itemCount: view.folders.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: MxSpacing.space3),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
            child: MxText(
              l10n.libraryFolderCountHeader(view.totalFolderCount),
              role: MxTextRole.labelMedium,
              color: colors.textSecondary,
            ),
          );
        }
        final FolderSummary summary = view.folders[index - 1];
        return LibraryFolderTile(
          summary: summary,
          onActions: () => _onFolderActions(summary),
        );
      },
    );
  }
}
