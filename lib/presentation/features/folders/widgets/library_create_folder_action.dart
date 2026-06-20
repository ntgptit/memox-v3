import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/controllers/library_action_controller.dart';
import 'package:memox/presentation/features/folders/folder_failure_message.dart';
import 'package:memox/presentation/features/folders/widgets/folder_create_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

/// Shared create-folder flow: open the create dialog, run the mutation, and
/// report the typed [Result] as a snackbar. Triggered from both the Library FAB
/// and the true-empty state CTA, so it lives in one place. The Drift watch
/// stream refreshes the list automatically. WBS 2.1.2.
Future<void> runCreateFolder(BuildContext context, WidgetRef ref) async {
  final FolderDraft? draft = await showFolderCreateDialog(context);
  if (draft == null) return;
  if (!context.mounted) return;

  final String successMessage = AppLocalizations.of(context).folderCreatedSnack;
  final Result<Folder> result = await ref
      .read(libraryActionControllerProvider.notifier)
      .create(name: draft.name, color: draft.color, icon: draft.icon);
  if (!context.mounted) return;

  final Failure? failure = result.failure;
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
