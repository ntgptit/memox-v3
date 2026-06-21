import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// An action chosen from the flashcard-list deck overflow sheet (kebab).
enum DeckOverflowAction { reorder, deleteDeck }

/// Shows the deck overflow sheet (mock `06` kebab): Reorder cards / Delete deck.
/// Resolves to the chosen [DeckOverflowAction] or `null` when dismissed. WBS
/// 2.14.2 (reorder) / 2.9.x (delete deck). Import is a separate flow (Future here).
Future<DeckOverflowAction?> showDeckOverflowSheet(BuildContext context) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showMxBottomSheet<DeckOverflowAction>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _OverflowRow(
          icon: Icons.swap_vert,
          label: l10n.flashcardReorderCardsAction,
          onTap: () => Navigator.of(context).pop(DeckOverflowAction.reorder),
        ),
        _OverflowRow(
          icon: Icons.delete_outline,
          label: l10n.deckActionDelete,
          danger: true,
          onTap: () => Navigator.of(context).pop(DeckOverflowAction.deleteDeck),
        ),
      ],
    ),
  );
}

class _OverflowRow extends StatelessWidget {
  const _OverflowRow({
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
