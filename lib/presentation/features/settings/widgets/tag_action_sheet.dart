import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A per-tag action chosen from the overflow sheet (kit `11--action-sheet`).
enum TagAction { rename, merge, delete }

/// Shows the per-tag action sheet for [tag] (header "name · N cards", then
/// Rename / Merge into… / Delete) and resolves to the chosen [TagAction] or
/// `null` when dismissed.
Future<TagAction?> showTagActionSheet(
  BuildContext context, {
  required TagWithCount tag,
}) => showMxBottomSheet<TagAction>(context, child: _TagActionSheet(tag: tag));

class _TagActionSheet extends StatelessWidget {
  const _TagActionSheet({required this.tag});

  final TagWithCount tag;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxText(
          l10n.tagManagementSheetHeader(tag.name, tag.cardCount),
          role: MxTextRole.titleMedium,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: MxSpacing.space2),
          child: MxDivider(),
        ),
        _ActionRow(
          icon: Icons.edit_outlined,
          tint: colors.textSecondary,
          label: l10n.tagManagementRenameAction,
          onTap: () => Navigator.of(context).pop(TagAction.rename),
        ),
        _ActionRow(
          icon: Icons.merge_outlined,
          tint: colors.textSecondary,
          label: l10n.tagManagementMergeAction,
          onTap: () => Navigator.of(context).pop(TagAction.merge),
        ),
        _ActionRow(
          icon: Icons.delete_outline,
          tint: colors.danger,
          label: l10n.tagManagementDeleteAction,
          danger: true,
          onTap: () => Navigator.of(context).pop(TagAction.delete),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.tint,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final Color tint;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
          children: <Widget>[
            MxIconTile(color: tint, icon: icon),
            const SizedBox(width: MxSpacing.space3),
            MxText(
              label,
              role: MxTextRole.bodyLarge,
              color: danger ? colors.danger : null,
            ),
          ],
        ),
      ),
    );
  }
}
