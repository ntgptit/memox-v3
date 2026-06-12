import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/flashcards/widgets/deck_actions_sheet.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_delete_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_folder_form_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_failure_message.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

/// Opens the current folder's overflow action sheet (Rename / Move / Delete) and
/// dispatches the chosen action (`docs/wireframes/05-folder-detail.md` §overflow,
/// states `delConfirm` + `moveSheet`).
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
      await _renameFolder(
        context,
        ref,
        detail.folder,
        helperText: _folderDetailSubtitle(l10n, detail),
      );
    case LibraryFolderAction.move:
      await _moveFolder(context, ref, detail.folder);
    case LibraryFolderAction.delete:
      await _deleteFolder(context, ref, detail);
    case LibraryFolderAction.importFlashcards:
      // Not offered for the current-folder overflow (showImport: false).
      break;
  }
}

/// Opens a child subfolder row's action sheet.
Future<void> showFolderDetailSubfolderActions(
  BuildContext context,
  WidgetRef ref,
  FolderWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
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
      await _renameFolder(
        context,
        ref,
        item.folder,
        helperText: _folderActionSubtitle(l10n, item),
      );
    case LibraryFolderAction.move:
      await _moveFolder(context, ref, item.folder);
    case LibraryFolderAction.importFlashcards:
      context.pushFolderDetail(item.folder.id);
    case LibraryFolderAction.delete:
      await _deleteChildFolder(context, ref, item);
  }
}

/// Opens a child deck row's action sheet.
Future<void> showFolderDetailDeckActions(
  BuildContext context,
  WidgetRef ref,
  DeckWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final DeckListAction? action = await showDeckActions(
    context,
    deckName: item.deck.name,
    subtitle: l10n.flashcardListSubtitle(
      item.cardCount,
      _languageLabel(l10n, item.deck.targetLanguage),
    ),
  );
  if (action == null) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  switch (action) {
    case DeckListAction.importFlashcards:
      context.pushDeckImport(item.deck.id);
    case DeckListAction.reorder:
      ref
          .read(flashcardListToolbarProvider(item.deck.id).notifier)
          .startReorder();
      context.pushFlashcardList(item.deck.id);
    case DeckListAction.delete:
      await _deleteChildDeck(context, ref, item);
  }
}

Future<void> _renameFolder(
  BuildContext context,
  WidgetRef ref,
  Folder folder, {
  required String helperText,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String? name = await showMxFolderRenameDialog(
    context,
    title: l10n.foldersRenameTitle,
    description: l10n.folderRenameDialogDescription,
    fieldLabel: l10n.folderRenameDialogFieldLabel,
    helperText: helperText,
    confirmLabel: l10n.commonRename,
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
  Folder folder,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final Result<List<FolderMoveTarget>> targets = await ref
      .read(libraryActionControllerProvider.notifier)
      .loadMoveTargets(folder.id);
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
      .moveFolder(folder.id, destination.id);
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
  FolderDetail detail,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final String summaryText = detail.folder.contentMode == ContentMode.subfolders
      ? l10n.libraryFolderSubfoldersCount(detail.subfolders.length)
      : l10n.libraryFolderDecksCount(detail.decks.length);
  final bool confirmed = await showMxFolderDeleteDialog(
    context,
    folderName: detail.folder.name,
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
      .deleteFolder(detail.folder.id);
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
    // The folder is gone — leave the now-stale detail screen for its parent.
    (void _) {
      showMxSnackbar(context, message: l10n.foldersDeletedMessage);
      unawaited(Navigator.of(context).maybePop());
    },
  );
}

Future<void> _deleteChildFolder(
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

Future<void> _deleteChildDeck(
  BuildContext context,
  WidgetRef ref,
  DeckWithCount item,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool confirmed = await showMxConfirmDialog(
    context,
    title: l10n.decksDeleteTitle,
    message: l10n.decksDeleteMessage,
    confirmLabel: l10n.commonDelete,
    cancelLabel: l10n.commonCancel,
    destructive: true,
  );
  if (!confirmed) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final Result<void> result = await ref
      .read(flashcardListControllerProvider.notifier)
      .deleteDeck(item.deck.id);
  if (!context.mounted) {
    return;
  }
  result.fold(
    (Failure failure) => showMxSnackbar(
      context,
      message: l10n.failureMessage(
        failure,
        fallback: l10n.flashcardListActionError,
      ),
      isError: true,
    ),
    (void _) => showMxSnackbar(context, message: l10n.decksDeletedMessage),
  );
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

String _folderActionSubtitle(AppLocalizations l10n, FolderWithCount item) {
  final String primary = item.folder.contentMode == ContentMode.subfolders
      ? l10n.libraryFolderSubfoldersCount(item.subfolderCount)
      : l10n.libraryFolderDecksCount(item.deckCount);
  return '$primary · ${l10n.libraryFolderCardsCount(item.cardCount)}';
}

String _languageLabel(AppLocalizations l10n, TargetLanguage lang) =>
    switch (lang) {
      TargetLanguage.korean => l10n.flashcardListLanguageKorean,
      TargetLanguage.english => l10n.flashcardListLanguageEnglish,
      TargetLanguage.unsupported => l10n.flashcardListLanguageOther,
    };
