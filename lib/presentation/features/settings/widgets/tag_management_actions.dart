import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/models/merge_result.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/controllers/tag_action_controller.dart';
import 'package:memox/presentation/features/settings/widgets/tag_action_sheet.dart';
import 'package:memox/presentation/features/settings/widgets/tag_merge_sheet.dart';
import 'package:memox/presentation/features/settings/widgets/tag_rename_dialog.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_busy_overlay.dart';

/// Opens the per-tag overflow sheet for [tag] and runs the chosen action
/// (Rename / Merge into… / Delete) over [allTags] (kit screen 11). The Drift
/// watch refreshes the list on success; failures surface the op-error dialog
/// with a Try-again retry.
Future<void> runTagOverflow(
  BuildContext context,
  WidgetRef ref, {
  required TagWithCount tag,
  required List<TagWithCount> allTags,
}) async {
  final TagAction? action = await showTagActionSheet(context, tag: tag);
  if (action == null) return;
  if (!context.mounted) return;
  switch (action) {
    case TagAction.rename:
      await _runRename(context, ref, tag: tag, allTags: allTags);
    case TagAction.merge:
      await _runMerge(context, ref, tag: tag, allTags: allTags);
    case TagAction.delete:
      await _runDelete(context, ref, tag: tag);
  }
}

Future<void> _runRename(
  BuildContext context,
  WidgetRef ref, {
  required TagWithCount tag,
  required List<TagWithCount> allTags,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final TagRenameOutcome? outcome = await showTagRenameDialog(
    context,
    currentName: tag.name,
    existingNames: <String>{for (final TagWithCount t in allTags) t.name},
  );
  if (outcome == null) return;
  if (!context.mounted) return;
  if (outcome.merge) {
    await _run<MergeResult>(
      context,
      ref,
      busyLabel: l10n.tagManagementBusyMerging,
      errorTitle: l10n.tagManagementMergeFailedTitle,
      errorMessage: l10n.tagManagementMergeFailedMessage,
      op: (TagActionController c) =>
          c.merge(sourceName: tag.name, destinationName: outcome.name),
    );
    return;
  }
  await _run<void>(
    context,
    ref,
    busyLabel: l10n.tagManagementBusyRenaming,
    errorTitle: l10n.tagManagementRenameFailedTitle,
    errorMessage: l10n.tagManagementRenameFailedMessage,
    op: (TagActionController c) =>
        c.rename(oldName: tag.name, newName: outcome.name),
  );
}

Future<void> _runMerge(
  BuildContext context,
  WidgetRef ref, {
  required TagWithCount tag,
  required List<TagWithCount> allTags,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final List<TagWithCount> candidates = <TagWithCount>[
    for (final TagWithCount t in allTags)
      if (StringUtils.caseFold(t.name) != StringUtils.caseFold(tag.name)) t,
  ];
  if (candidates.isEmpty) return;
  final String? destination = await showTagMergeSheet(
    context,
    source: tag,
    candidates: candidates,
  );
  if (destination == null) return;
  if (!context.mounted) return;
  await _run<MergeResult>(
    context,
    ref,
    busyLabel: l10n.tagManagementBusyMerging,
    errorTitle: l10n.tagManagementMergeFailedTitle,
    errorMessage: l10n.tagManagementMergeFailedMessage,
    op: (TagActionController c) =>
        c.merge(sourceName: tag.name, destinationName: destination),
  );
}

Future<void> _runDelete(
  BuildContext context,
  WidgetRef ref, {
  required TagWithCount tag,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool confirmed = await MxConfirmDialog.show(
    context,
    title: l10n.tagManagementDeleteTitle(tag.name),
    message: l10n.tagManagementDeleteMessage(tag.cardCount),
    confirmLabel: l10n.tagManagementDeleteConfirm,
    cancelLabel: l10n.commonCancel,
    destructive: true,
  );
  if (!confirmed) return;
  if (!context.mounted) return;
  await _run<int>(
    context,
    ref,
    busyLabel: l10n.tagManagementBusyDeleting,
    errorTitle: l10n.tagManagementDeleteFailedTitle,
    errorMessage: l10n.tagManagementDeleteFailedMessage,
    op: (TagActionController c) => c.delete(tag: tag.name),
  );
}

/// Runs [op] behind a blocking [MxBusyOverlay]; on failure shows the op-error
/// dialog and retries when the user taps "Try again". The Drift watch refreshes
/// the list on success.
Future<void> _run<R>(
  BuildContext context,
  WidgetRef ref, {
  required String busyLabel,
  required String errorTitle,
  required String errorMessage,
  required Future<Result<R>> Function(TagActionController) op,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final TagActionController controller = ref.read(
    tagActionControllerProvider.notifier,
  );
  while (true) {
    final Future<void> overlay = showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => MxBusyOverlay(label: busyLabel),
    );
    final Result<R> result = await op(controller);
    if (context.mounted) {
      // Dismiss the busy overlay and let its route teardown settle. When the
      // screen has been popped mid-op, skip both (the overlay route is disposed
      // with the screen) to avoid awaiting a future that only the disposal
      // resolves.
      Navigator.of(context, rootNavigator: true).pop();
      await overlay;
    }
    if (result.failure == null) return;
    if (!context.mounted) return;
    final bool retry = await MxConfirmDialog.show(
      context,
      title: errorTitle,
      message: errorMessage,
      confirmLabel: l10n.commonTryAgain,
      cancelLabel: l10n.commonDismiss,
    );
    if (!retry) return;
    if (!context.mounted) return;
  }
}
