import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/folder_visual_tokens.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_folder_tile.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A folder action chosen from the overflow sheet.
///
/// V1 exposes the supported subset only; the mock's "Study due cards" /
/// "Archive folder" rows are out of scope
/// (`docs/design/screens/library-overview.visual-contract.md` §`03f`).
enum FolderAction { rename, move, delete }

/// Shows the folder overflow action sheet for [summary] (a header with the
/// folder's tinted tile + name + meta, then Rename / Move / Delete) and
/// resolves to the chosen [FolderAction] (or `null` when dismissed).
/// WBS 2.2.2 / 2.4.2 / 2.3.2.
Future<FolderAction?> showFolderActionsSheet(
  BuildContext context, {
  required FolderSummary summary,
}) => showMxBottomSheet<FolderAction>(
  context,
  child: _FolderActionsSheet(summary: summary),
);

class _FolderActionsSheet extends StatelessWidget {
  const _FolderActionsSheet({required this.summary});

  final FolderSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Header: tinted tile + folder name + meta digest.
        Row(
          children: <Widget>[
            FolderIconTile(
              color: folderTint(colors, summary.folder.color),
              icon: folderGlyph(summary.folder.icon),
            ),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    summary.folder.name,
                    role: MxTextRole.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  MxText(
                    folderMetaLine(l10n, summary),
                    role: MxTextRole.bodySmall,
                    color: colors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: MxSpacing.space2),
          child: MxDivider(),
        ),
        _SheetActionRow(
          icon: Icons.edit_outlined,
          label: l10n.folderActionRename,
          onTap: () => Navigator.of(context).pop(FolderAction.rename),
        ),
        _SheetActionRow(
          icon: Icons.drive_file_move_outlined,
          label: l10n.folderActionMove,
          onTap: () => Navigator.of(context).pop(FolderAction.move),
        ),
        _SheetActionRow(
          icon: Icons.delete_outline,
          label: l10n.folderActionDelete,
          danger: true,
          onTap: () => Navigator.of(context).pop(FolderAction.delete),
        ),
      ],
    );
  }
}

class _SheetActionRow extends StatelessWidget {
  const _SheetActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final Color tint = danger ? colors.danger : colors.textSecondary;
    return MxTappable(
      onTap: onTap,
      borderRadius: MxRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
          children: <Widget>[
            FolderIconTile(color: tint, icon: icon),
            const SizedBox(width: MxSpacing.space3),
            MxText(
              label,
              role: MxTextRole.titleMedium,
              color: danger ? colors.danger : null,
            ),
          ],
        ),
      ),
    );
  }
}
