import 'package:flutter/material.dart';
import 'package:memox/domain/models/folder_move_target.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// Shows the move-destination picker for [targets] and resolves to the chosen
/// [FolderMoveTarget] (the Library root has `id == null`), or `null` when
/// dismissed. Blocked destinations (cycle / decks-locked) are shown disabled
/// with a reason — never hidden
/// (`docs/wireframes/25-shared-bottom-sheets.md` §folder-picker). The current
/// parent is not selectable (moving there is a no-op). WBS 2.4.2.
Future<FolderMoveTarget?> showFolderMovePicker(
  BuildContext context, {
  required List<FolderMoveTarget> targets,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showMxBottomSheet<FolderMoveTarget>(
    context,
    title: l10n.folderMoveTitle,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final FolderMoveTarget target in targets)
          _MoveTargetRow(target: target),
      ],
    ),
  );
}

class _MoveTargetRow extends StatelessWidget {
  const _MoveTargetRow({required this.target});

  final FolderMoveTarget target;

  String? _blockReason(AppLocalizations l10n) => switch (target.block) {
    FolderMoveBlock.cycle => l10n.folderMoveBlockCycle,
    FolderMoveBlock.lockedToDecks => l10n.folderMoveBlockLockedDecks,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isRoot = target.id == null;
    final String title = isRoot ? l10n.folderMoveRootLabel : target.name;
    // Blocked rows and the current parent are not selectable.
    final bool selectable = target.isSelectable && !target.isCurrentParent;
    final String? subtitle =
        _blockReason(l10n) ??
        (target.breadcrumb.length > 1
            ? target.breadcrumb.take(target.breadcrumb.length - 1).join(' / ')
            : null);

    return MxListTile(
      leading: Icon(isRoot ? Icons.home_outlined : Icons.folder_outlined),
      title: title,
      subtitle: subtitle,
      trailing: target.isCurrentParent ? const Icon(Icons.check) : null,
      onTap: selectable ? () => Navigator.of(context).pop(target) : null,
    );
  }
}
