import 'package:flutter/material.dart';
import 'package:memox/domain/models/deck_move_target.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// Shows the deck move-destination picker for [targets] and resolves to the
/// chosen [DeckMoveTarget], or `null` when dismissed (kit
/// `04-folder-detail--move-sheet`).
///
/// Mirrors the folder §folder-picker pattern (`folder_move_picker_sheet.dart`):
/// blocked destinations (a folder that holds subfolders) are shown disabled with
/// a reason — never hidden (`docs/wireframes/25-shared-bottom-sheets.md`
/// §folder-picker) — and the deck's current folder is shown with a check but is
/// not selectable (moving there is a no-op). Tap a row to move. The kit's
/// radio + "Move here" confirm styling is a deferred visual refinement that
/// would apply to both pickers together. WBS 2.19.2.
Future<DeckMoveTarget?> showDeckMovePicker(
  BuildContext context, {
  required List<DeckMoveTarget> targets,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showMxBottomSheet<DeckMoveTarget>(
    context,
    title: l10n.deckMoveTitle,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final DeckMoveTarget target in targets)
          _DeckMoveTargetRow(target: target),
      ],
    ),
  );
}

class _DeckMoveTargetRow extends StatelessWidget {
  const _DeckMoveTargetRow({required this.target});

  final DeckMoveTarget target;

  String? _blockReason(AppLocalizations l10n) => switch (target.block) {
    DeckMoveBlock.lockedToSubfolders => l10n.deckMoveBlockSubfolders,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Blocked rows and the current parent are not selectable.
    final bool selectable = target.isSelectable && !target.isCurrentParent;
    final String? subtitle =
        _blockReason(l10n) ??
        (target.breadcrumb.length > 1
            ? target.breadcrumb.take(target.breadcrumb.length - 1).join(' / ')
            : null);

    return MxListTile(
      leading: const Icon(Icons.folder_outlined),
      title: target.name,
      subtitle: subtitle,
      trailing: target.isCurrentParent ? const Icon(Icons.check) : null,
      onTap: selectable ? () => Navigator.of(context).pop(target) : null,
    );
  }
}
