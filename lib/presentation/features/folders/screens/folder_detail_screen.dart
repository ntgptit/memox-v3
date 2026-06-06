import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_detail_body.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_skeleton.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_delete_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_name_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/inputs/mx_search_field.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

/// Folder Detail — browse a folder's children (subfolders OR decks), with
/// breadcrumb, inline search, and a mode-constrained create FAB
/// (`docs/wireframes/05-folder-detail.md`). Study CTAs / resume banner / hero
/// mastery are Future here (the study layer is not built).
class FolderDetailScreen extends ConsumerWidget {
  const FolderDetailScreen({required this.folderId, super.key});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // guard:allow-screen-watch -- reason: the app bar title and the
    // mode-constrained FAB both need the loaded folder (name + content_mode).
    final AsyncValue<FolderDetail> query = ref.watch(
      folderDetailQueryProvider(folderId),
    );
    final FolderDetail? detail = query.asData?.value;

    return MxScaffold(
      appBar: MxAppBar(
        titleText: detail?.folder.name ?? '',
        actions: <Widget>[
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.libraryOverflowTooltip,
            onPressed: detail == null
                ? null
                : () => showFolderDetailActions(context, ref, detail),
          ),
        ],
      ),
      floatingActionButton: _buildFab(context, ref, detail),
      body: _FolderDetailView(folderId: folderId),
    );
  }

  Widget? _buildFab(BuildContext context, WidgetRef ref, FolderDetail? detail) {
    if (detail == null) {
      return null;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (detail.folder.contentMode) {
      ContentMode.subfolders => MxFab.extended(
        icon: Icons.create_new_folder_outlined,
        label: l10n.folderNewSubfolderLabel,
        onPressed: () => createSubfolderDialog(context, ref, folderId),
      ),
      ContentMode.decks => MxFab.extended(
        icon: Icons.add,
        label: l10n.folderNewDeckLabel,
        onPressed: () => createDeckDialog(context, ref, folderId),
      ),
      // Unlocked offers its choice inline in the body, not via a FAB.
      ContentMode.unlocked => null,
    };
  }
}

class _FolderDetailView extends ConsumerWidget {
  const _FolderDetailView({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FolderDetail> query = ref.watch(
      folderDetailQueryProvider(folderId),
    );
    final bool isSearching = ref
        .watch(folderDetailToolbarProvider(folderId))
        .isSearching;

    return Column(
      children: <Widget>[
        _FolderBreadcrumb(folderId: folderId),
        Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: _FolderSearchField(folderId: folderId),
        ),
        Expanded(
          child: MxRetainedAsyncState<FolderDetail>(
            value: query,
            skeletonBuilder: (_) => const LibrarySkeleton(),
            errorBuilder: (Object error, StackTrace? stack) => MxErrorState(
              icon: Icons.folder_off_outlined,
              title: AppLocalizations.of(context).folderNotFoundTitle,
              message: AppLocalizations.of(context).folderNotFoundMessage,
              retryLabel: AppLocalizations.of(context).commonRetry,
              onRetry: () =>
                  ref.invalidate(folderDetailQueryProvider(folderId)),
            ),
            data: (FolderDetail detail) => FolderDetailBody(
              detail: detail,
              isSearching: isSearching,
              onNewSubfolder: () =>
                  createSubfolderDialog(context, ref, folderId),
              onNewDeck: () => createDeckDialog(context, ref, folderId),
              onClearSearch: () => ref
                  .read(folderDetailToolbarProvider(folderId).notifier)
                  .clearSearch(),
            ),
          ),
        ),
      ],
    );
  }
}

class _FolderBreadcrumb extends ConsumerWidget {
  const _FolderBreadcrumb({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FolderDetail? detail = ref
        .watch(folderDetailQueryProvider(folderId))
        .asData
        ?.value;
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<MxBreadcrumbSegment> segments = <MxBreadcrumbSegment>[
      MxBreadcrumbSegment(
        label: l10n.libraryTitle,
        onTap: () => context.goLibrary(),
      ),
      for (final FolderBreadcrumbSegment seg in detail.breadcrumb)
        MxBreadcrumbSegment(
          label: seg.name,
          onTap: () => context.pushFolderDetail(seg.id),
        ),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: MxBreadcrumb(segments: segments),
    );
  }
}

class _FolderSearchField extends ConsumerStatefulWidget {
  const _FolderSearchField({required this.folderId});

  final String folderId;

  @override
  ConsumerState<_FolderSearchField> createState() => _FolderSearchFieldState();
}

class _FolderSearchFieldState extends ConsumerState<_FolderSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxSearchField(
      controller: _controller,
      hintText: l10n.folderDetailSearchHint,
      clearTooltip: l10n.librarySearchClearTooltip,
      onChanged: (String value) => ref
          .read(folderDetailToolbarProvider(widget.folderId).notifier)
          .setSearch(value),
    );
  }
}

Future<void> createSubfolderDialog(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxNameDialog(
    context,
    title: l10n.subfolderCreateDialogTitle,
    fieldLabel: l10n.subfolderCreateFieldLabel,
    confirmLabel: l10n.commonCreate,
    cancelLabel: l10n.commonCancel,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final result = await ref
      .read(folderActionControllerProvider.notifier)
      .createSubfolder(folderId, name);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: _childCreateError(l10n, failure, isDeck: false),
      isError: true,
    ),
    (_) {},
  );
}

Future<void> createDeckDialog(
  BuildContext context,
  WidgetRef ref,
  String folderId,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxNameDialog(
    context,
    title: l10n.deckCreateDialogTitle,
    fieldLabel: l10n.deckCreateFieldLabel,
    confirmLabel: l10n.commonCreate,
    cancelLabel: l10n.commonCancel,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final result = await ref
      .read(folderActionControllerProvider.notifier)
      .createDeck(folderId, name);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: _childCreateError(l10n, failure, isDeck: true),
      isError: true,
    ),
    (_) {},
  );
}

String _childCreateError(
  AppLocalizations l10n,
  Failure failure, {
  required bool isDeck,
}) => switch (failure) {
  ValidationFailure(code: ValidationCode.duplicate) =>
    isDeck ? l10n.folderDeckDuplicateError : l10n.libraryFolderDuplicateError,
  UnsupportedActionFailure() => l10n.folderModeLockedError,
  _ => l10n.folderChildCreateError,
};

/// Opens the current folder's overflow action sheet (Rename / Move / Delete) and
/// dispatches the chosen action (`docs/wireframes/05-folder-detail.md` §overflow,
/// states `delConfirm` + `moveSheet`). Reuses the Library folder action flow so
/// the detail screen and the Library row share one set of use cases. Import is
/// hidden — it targets a specific deck inside the folder, not the folder itself.
Future<void> showFolderDetailActions(
  BuildContext context,
  WidgetRef ref,
  FolderDetail detail,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final LibraryFolderAction? action = await showLibraryFolderActions(
    context,
    name: detail.folder.name,
    subtitle: _folderDetailSubtitle(l10n, detail),
    showImport: false,
  );
  if (action == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  switch (action) {
    case LibraryFolderAction.rename:
      await _renameFolder(context, ref, detail.folder);
    case LibraryFolderAction.move:
      await _moveFolder(context, ref, detail.folder);
    case LibraryFolderAction.delete:
      await _deleteFolder(context, ref, detail);
    case LibraryFolderAction.importFlashcards:
      // Not offered for the current-folder overflow (showImport: false).
      break;
  }
}

String _folderDetailSubtitle(AppLocalizations l10n, FolderDetail detail) {
  final bool isSubfolderMode =
      detail.folder.contentMode == ContentMode.subfolders;
  final String primary = isSubfolderMode
      ? l10n.libraryFolderSubfoldersCount(detail.subfolders.length)
      : l10n.libraryFolderDecksCount(detail.decks.length);
  final int cardTotal = isSubfolderMode
      ? detail.subfolders.fold<int>(0, (int s, item) => s + item.cardCount)
      : detail.decks.fold<int>(0, (int s, item) => s + item.cardCount);
  return '$primary · ${l10n.libraryFolderCardsCount(cardTotal)}';
}

Future<void> _renameFolder(
  BuildContext context,
  WidgetRef ref,
  Folder folder,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxNameDialog(
    context,
    title: l10n.foldersRenameTitle,
    fieldLabel: l10n.folderCreateFieldLabel,
    confirmLabel: l10n.commonSave,
    cancelLabel: l10n.commonCancel,
    initialValue: folder.name,
  );
  if (name == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .renameFolder(folder.id, name);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: _folderActionError(l10n, failure),
      isError: true,
    ),
    (Folder _) => showMxSnackbar(context, message: l10n.foldersUpdatedMessage),
  );
}

Future<void> _moveFolder(
  BuildContext context,
  WidgetRef ref,
  Folder folder,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Result<List<FolderMoveTarget>> targets = await ref
      .read(libraryActionControllerProvider.notifier)
      .loadMoveTargets(folder.id);
  if (!context.mounted) {
    return;
  }
  final List<FolderMoveTarget>? list = targets.fold(
    (Failure _) => null,
    (List<FolderMoveTarget> value) => value,
  );
  if (list == null) {
    showMxSnackbar(context, message: l10n.libraryFolderActionError, isError: true);
    return;
  }
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
      .moveFolder(folder.id, destination.id);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: _folderActionError(l10n, failure),
      isError: true,
    ),
    (Folder _) => showMxSnackbar(context, message: l10n.foldersMovedMessage),
  );
}

Future<void> _deleteFolder(
  BuildContext context,
  WidgetRef ref,
  FolderDetail detail,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String summaryText = detail.folder.contentMode == ContentMode.subfolders
      ? l10n.libraryFolderSubfoldersCount(detail.subfolders.length)
      : l10n.libraryFolderDecksCount(detail.decks.length);
  final bool confirmed = await showMxFolderDeleteDialog(
    context,
    folderName: detail.folder.name,
    summaryText: summaryText,
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
      .deleteFolder(detail.folder.id);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: _folderActionError(l10n, failure),
      isError: true,
    ),
    // The folder is gone — leave the now-stale detail screen for its parent.
    (void _) {
      showMxSnackbar(context, message: l10n.foldersDeletedMessage);
      unawaited(Navigator.of(context).maybePop());
    },
  );
}

String _folderActionError(AppLocalizations l10n, Failure failure) =>
    switch (failure) {
      ValidationFailure(code: ValidationCode.duplicate) =>
        l10n.libraryFolderDuplicateError,
      _ => l10n.libraryFolderActionError,
    };
