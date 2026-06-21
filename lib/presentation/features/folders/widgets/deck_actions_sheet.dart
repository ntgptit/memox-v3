import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A deck action chosen from the overflow sheet: rename, move to another folder
/// (WBS 2.19.2), or delete.
enum DeckAction { rename, move, delete }

/// Shows the deck overflow action sheet for [summary] (header with the deck +
/// its card count, then Rename / Delete deck) and resolves to the chosen
/// [DeckAction] or `null` when dismissed. WBS 2.8.2 / 2.9.2.
Future<DeckAction?> showDeckActionsSheet(
  BuildContext context, {
  required DeckSummary summary,
}) => showMxBottomSheet<DeckAction>(
  context,
  child: _DeckActionsSheet(summary: summary),
);

class _DeckActionsSheet extends StatelessWidget {
  const _DeckActionsSheet({required this.summary});

  final DeckSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            FolderIconTile(color: colors.accent, icon: Icons.style_outlined),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    summary.deck.name,
                    role: MxTextRole.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  MxText(
                    l10n.folderMetaCards(summary.cardCount),
                    role: MxTextRole.bodySmall,
                    color: colors.textSecondary,
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
        _DeckActionRow(
          icon: Icons.edit_outlined,
          label: l10n.deckActionRename,
          onTap: () => Navigator.of(context).pop(DeckAction.rename),
        ),
        _DeckActionRow(
          icon: Icons.drive_file_move_outlined,
          label: l10n.deckActionMove,
          onTap: () => Navigator.of(context).pop(DeckAction.move),
        ),
        _DeckActionRow(
          icon: Icons.delete_outline,
          label: l10n.deckActionDelete,
          danger: true,
          onTap: () => Navigator.of(context).pop(DeckAction.delete),
        ),
      ],
    );
  }
}

class _DeckActionRow extends StatelessWidget {
  const _DeckActionRow({
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
