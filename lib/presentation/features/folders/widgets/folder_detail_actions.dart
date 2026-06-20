import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/controllers/library_action_controller.dart';
import 'package:memox/presentation/features/folders/folder_failure_message.dart';
import 'package:memox/presentation/features/folders/widgets/deck_actions_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/deck_create_dialog.dart';
import 'package:memox/presentation/features/folders/widgets/folder_create_dialog.dart';
import 'package:memox/presentation/features/folders/widgets/folder_move_picker_sheet.dart';
import 'package:memox/presentation/features/folders/widgets/folder_rename_dialog.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_actions_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

void _report(BuildContext context, Failure? failure, String successMessage) {
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

/// Create-subfolder flow under [parentId]: open the folder create dialog, run
/// the mutation, report the result. The Drift watch stream refreshes the list.
/// WBS 2.1.2 (subfolder).
Future<void> runCreateSubfolder(
  BuildContext context,
  WidgetRef ref,
  FolderId parentId,
) async {
  final FolderDraft? draft = await showFolderCreateDialog(context);
  if (draft == null) return;
  if (!context.mounted) return;
  final String success = AppLocalizations.of(context).folderCreatedSnack;
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .createSubfolder(
        parentId: parentId,
        name: draft.name,
        color: draft.color,
        icon: draft.icon,
      );
  if (!context.mounted) return;
  _report(context, result.failure, success);
}

/// Create-deck flow in [folderId]: open the deck create dialog, run the
/// mutation, report the result. WBS 2.7.2.
Future<void> runCreateDeck(
  BuildContext context,
  WidgetRef ref,
  FolderId folderId,
) async {
  final DeckDraft? draft = await showDeckCreateDialog(context);
  if (draft == null) return;
  if (!context.mounted) return;
  final String success = AppLocalizations.of(context).deckCreatedSnack;
  final Result<Deck> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .createDeck(
        folderId: folderId,
        name: draft.name,
        targetLanguage: draft.targetLanguage,
      );
  if (!context.mounted) return;
  _report(context, result.failure, success);
}

/// Opens the folder overflow sheet for [summary] and dispatches the chosen
/// action (rename / move / delete) via the shared use cases. Used by both the
/// Library and Folder-detail folder rows.
Future<void> runFolderActions(
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
  final LibraryActionController controller = ref.read(
    libraryActionControllerProvider.notifier,
  );
  final AppLocalizations l10n = AppLocalizations.of(context);
  final FolderId id = summary.folder.id;

  switch (action) {
    case FolderAction.rename:
      final String? newName = await showFolderRenameDialog(
        context,
        currentName: summary.folder.name,
      );
      if (newName == null) return;
      if (!context.mounted) return;
      final Result<Folder> r = await controller.rename(
        id: id,
        newName: newName,
      );
      if (!context.mounted) return;
      _report(context, r.failure, l10n.folderRenamedSnack);
    case FolderAction.move:
      final Result<List<FolderMoveTarget>> targets = await controller
          .moveTargets(folderId: id);
      if (!context.mounted) return;
      final List<FolderMoveTarget>? candidates = targets.data;
      if (candidates == null) {
        _report(context, targets.failure, l10n.folderMovedSnack);
        return;
      }
      final FolderMoveTarget? dest = await showFolderMovePicker(
        context,
        targets: candidates,
      );
      if (dest == null) return;
      if (!context.mounted) return;
      final Result<Folder> r = await controller.move(
        id: id,
        newParentId: dest.id,
      );
      if (!context.mounted) return;
      _report(context, r.failure, l10n.folderMovedSnack);
    case FolderAction.delete:
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
      final Result<void> r = await controller.delete(id: id);
      if (!context.mounted) return;
      _report(context, r.failure, l10n.folderDeletedSnack);
  }
}

/// Opens the deck overflow sheet for [summary] and dispatches rename / delete.
Future<void> runDeckActions(
  BuildContext context,
  WidgetRef ref,
  DeckSummary summary,
) async {
  final DeckAction? action = await showDeckActionsSheet(
    context,
    summary: summary,
  );
  if (action == null) return;
  if (!context.mounted) return;
  final LibraryActionController controller = ref.read(
    libraryActionControllerProvider.notifier,
  );
  final AppLocalizations l10n = AppLocalizations.of(context);
  final DeckId id = summary.deck.id;

  switch (action) {
    case DeckAction.rename:
      final String? newName = await showFolderRenameDialog(
        context,
        currentName: summary.deck.name,
      );
      if (newName == null) return;
      if (!context.mounted) return;
      final Result<Deck> r = await controller.renameDeck(
        deckId: id,
        newName: newName,
      );
      if (!context.mounted) return;
      _report(context, r.failure, l10n.deckRenamedSnack);
    case DeckAction.delete:
      final bool confirmed = await MxConfirmDialog.show(
        context,
        title: l10n.deckDeleteTitle,
        message: l10n.deckDeleteMessage(summary.cardCount),
        confirmLabel: l10n.deckDeleteConfirm,
        cancelLabel: l10n.commonCancel,
        destructive: true,
      );
      if (!confirmed) return;
      if (!context.mounted) return;
      final Result<void> r = await controller.deleteDeck(deckId: id);
      if (!context.mounted) return;
      _report(context, r.failure, l10n.deckDeletedSnack);
  }
}
