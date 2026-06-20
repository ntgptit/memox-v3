import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// A folder action chosen from the overflow sheet.
///
/// V1 exposes the supported subset only; the mock's "Study due cards" /
/// "Archive folder" rows are out of scope
/// (`docs/design/screens/library-overview.visual-contract.md` §`03f`).
enum FolderAction { rename, move, delete }

/// Shows the folder overflow action sheet for [folderName] and resolves to the
/// chosen [FolderAction] (or `null` when dismissed). Rows: Rename / Move /
/// Delete. WBS 2.2.2 / 2.4.2 / 2.3.2.
Future<FolderAction?> showFolderActionsSheet(
  BuildContext context, {
  required String folderName,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showMxBottomSheet<FolderAction>(
    context,
    title: folderName,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MxListTile(
          leading: const Icon(Icons.edit_outlined),
          title: l10n.folderActionRename,
          onTap: () => Navigator.of(context).pop(FolderAction.rename),
        ),
        MxListTile(
          leading: const Icon(Icons.drive_file_move_outlined),
          title: l10n.folderActionMove,
          onTap: () => Navigator.of(context).pop(FolderAction.move),
        ),
        MxListTile(
          leading: const Icon(Icons.delete_outline),
          title: l10n.folderActionDelete,
          onTap: () => Navigator.of(context).pop(FolderAction.delete),
        ),
      ],
    ),
  );
}
