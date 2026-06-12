import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_overview_body.dart';
import 'package:memox/presentation/features/folders/widgets/library_search_field.dart';
import 'package:memox/presentation/features/folders/widgets/library_sections.dart';
import 'package:memox/presentation/features/folders/widgets/library_skeleton.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_delete_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_form_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Library Overview — root content browser (top-level folders only).
///
/// `docs/wireframes/02-library.md`. The shell keeps no provider watching;
/// `_LibraryOverviewView` owns that and renders all six states via
/// `MxRetainedAsyncState` (loaded / skeleton / error) plus the body
/// (true-empty / search-no-results). The header's filter affordance is a
/// visual-only disabled `tune` control (no approved filter sheet yet).
class LibraryOverviewScreen extends ConsumerWidget {
  const LibraryOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxScaffold(
      appBar: MxAppBar(
        titleText: l10n.libraryTitle,
        actions: <Widget>[
          MxIconButton(
            icon: Icons.tune_rounded,
            tooltip: l10n.libraryFilterTooltip,
            onPressed: null,
          ),
        ],
      ),
      floatingActionButton: MxFab.extended(
        icon: Icons.create_new_folder_outlined,
        label: l10n.libraryNewFolderLabel,
        onPressed: () => _showCreateFolderDialog(context, ref),
      ),
      body: const _LibraryOverviewView(),
    );
  }
}

/// Reactive content section — kept out of the screen shell so the shell build
/// stays watch-free (`memox.screen_shell.template_shell_no_ref_watch`).
class _LibraryOverviewView extends ConsumerWidget {
  const _LibraryOverviewView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<LibraryOverviewReadModel> query = ref.watch(
      libraryOverviewQueryProvider,
    );
    final LibraryToolbarState toolbar = ref.watch(libraryToolbarProvider);
    // Retained-data refetch failures are surfaced app-wide by
    // `MxAppFeedbackObserver`; no screen-local listener needed.

    return Column(
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(
            top: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: LibrarySearchField(),
        ),
        Expanded(
          child: MxRetainedAsyncState<LibraryOverviewReadModel>(
            value: query,
            skeletonBuilder: (_) => const LibrarySkeleton(),
            errorBuilder: (Object error, StackTrace? stack) =>
                LibraryErrorSection(
                  onRetry: () => ref.invalidate(libraryOverviewQueryProvider),
                ),
            data: (LibraryOverviewReadModel model) => LibraryOverviewBody(
              model: model,
              isSearching: toolbar.isSearching,
              onCreateFolder: () => _showCreateFolderDialog(context, ref),
              onClearSearch: () =>
                  ref.read(libraryToolbarProvider.notifier).clearSearch(),
              onShowFolderActions: (FolderWithCount item) =>
                  _showFolderActions(context, ref, item),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showCreateFolderDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxFolderCreateDialog(
    context,
    title: l10n.folderCreateDialogTitle,
    description: l10n.folderCreateDialogDescription,
    fieldLabel: l10n.folderCreateFieldLabel,
    colorLabel: l10n.folderCreateColorLabel,
    iconLabel: l10n.folderCreateIconLabel,
    confirmLabel: l10n.commonCreate,
    cancelLabel: l10n.commonCancel,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .createFolder(name);
  if (!context.mounted) {
    return;
  }
  // Success: the Drift stream refreshes the list — no manual state push.
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        duplicate: l10n.libraryFolderDuplicateError,
        fallback: l10n.libraryCreateFolderError,
      ),
      isError: true,
    ),
    (Folder _) {},
  );
}

/// Opens the folder action sheet and dispatches the chosen action
/// (`docs/wireframes/02-library.md` §Overflow sheet).
Future<void> _showFolderActions(
  BuildContext context,
  WidgetRef ref,
  FolderWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  // Import targets a deck; subfolder-mode folders hold no decks, so it is
  // hidden for them (`docs/wireframes/02-library.md`).
  final bool showImport = item.folder.contentMode != ContentMode.subfolders;
  final LibraryFolderAction? action = await showLibraryFolderActions(
    context,
    name: item.folder.name,
    subtitle: _folderActionSubtitle(l10n, item),
    showImport: showImport,
  );
  if (action == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  switch (action) {
    case LibraryFolderAction.rename:
      await _renameFolder(context, ref, item);
    case LibraryFolderAction.move:
      await _moveFolder(context, ref, item);
    case LibraryFolderAction.importFlashcards:
      // Follows the existing per-deck import flow: open the folder, where the
      // user picks (or creates) a deck and imports into it.
      context.pushFolderDetail(item.folder.id);
    case LibraryFolderAction.delete:
      await _deleteFolder(context, ref, item);
  }
}

String _folderActionSubtitle(AppLocalizations l10n, FolderWithCount item) {
  final String primary = item.folder.contentMode == ContentMode.subfolders
      ? l10n.libraryFolderSubfoldersCount(item.subfolderCount)
      : l10n.libraryFolderDecksCount(item.deckCount);
  return '$primary · ${l10n.libraryFolderCardsCount(item.cardCount)}';
}

Future<void> _renameFolder(
  BuildContext context,
  WidgetRef ref,
  FolderWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxFolderRenameDialog(
    context,
    title: l10n.foldersRenameTitle,
    description: l10n.folderRenameDialogDescription,
    fieldLabel: l10n.folderRenameDialogFieldLabel,
    helperText: l10n.folderRenameDialogHelper(
      _folderActionSubtitle(l10n, item),
    ),
    confirmLabel: l10n.commonRename,
    cancelLabel: l10n.commonCancel,
    initialValue: item.folder.name,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .renameFolder(item.folder.id, name);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        duplicate: l10n.libraryFolderDuplicateError,
        fallback: l10n.libraryFolderActionError,
      ),
      isError: true,
    ),
    (Folder _) => showMxSnackbar(context, message: l10n.foldersUpdatedMessage),
  );
}

Future<void> _moveFolder(
  BuildContext context,
  WidgetRef ref,
  FolderWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Result<List<FolderMoveTarget>> targets = await ref
      .read(libraryActionControllerProvider.notifier)
      .loadMoveTargets(item.folder.id);
  if (!context.mounted) {
    return;
  }
  if (targets case Err<List<FolderMoveTarget>>(:final Failure failure)) {
    showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        fallback: l10n.libraryFolderActionError,
      ),
      isError: true,
    );
    return;
  }
  final List<FolderMoveTarget> list = targets.valueOrNull!;
  final FolderMoveTarget? destination = await showFolderMovePicker(
    context,
    targets: list,
  );
  if (destination == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .moveFolder(item.folder.id, destination.id);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        duplicate: l10n.libraryFolderDuplicateError,
        fallback: l10n.libraryFolderActionError,
      ),
      isError: true,
    ),
    (Folder _) => showMxSnackbar(context, message: l10n.foldersMovedMessage),
  );
}

Future<void> _deleteFolder(
  BuildContext context,
  WidgetRef ref,
  FolderWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String summaryText = item.folder.contentMode == ContentMode.subfolders
      ? l10n.libraryFolderSubfoldersCount(item.subfolderCount)
      : l10n.libraryFolderDecksCount(item.deckCount);
  final bool confirmed = await showMxFolderDeleteDialog(
    context,
    folderName: item.folder.name,
    removalMessage: l10n.folderDeleteDialogRemovalMessage(summaryText),
    title: l10n.folderDeleteDialogTitle,
    reassuranceText: l10n.folderDeleteDialogReassurance,
    confirmLabel: l10n.folderDeleteDialogConfirmLabel,
    deleteButtonLabel: l10n.folderDeleteDialogDeleteButton,
    cancelLabel: l10n.commonCancel,
    confirmHint: l10n.folderDeleteDialogConfirmLabel,
  );
  if (!confirmed) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<void> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .deleteFolder(item.folder.id);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        duplicate: l10n.libraryFolderDuplicateError,
        fallback: l10n.libraryFolderActionError,
      ),
      isError: true,
    ),
    (void _) => showMxSnackbar(context, message: l10n.foldersDeletedMessage),
  );
}
