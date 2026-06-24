import 'package:flutter/material.dart';
import 'package:memox/domain/models/tag_with_count.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_list_tile.dart';

/// Shows the merge-target picker for [source] over [candidates] (all OTHER tags;
/// kit `11--merge-sheet`) and resolves to the chosen destination tag name, or
/// `null` when dismissed. Tap a tag to merge `source` into it.
///
/// Tap-to-select mirrors the deck/folder move pickers; the kit's radio + "Merge
/// into X" confirm button is the same deferred visual refinement those pickers
/// document (`docs/wireframes/25-shared-bottom-sheets.md`).
Future<String?> showTagMergeSheet(
  BuildContext context, {
  required TagWithCount source,
  required List<TagWithCount> candidates,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  return showMxBottomSheet<String>(
    context,
    title: l10n.tagManagementMergeSheetTitle(source.name),
    // Plain list, consistent with the deck/folder move pickers. The bounded
    // sheet (0.9×height) can clip a very long tag list — a shared
    // MxBottomSheet scroll limitation tracked across all three pickers, not
    // specific to tags.
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final TagWithCount tag in candidates)
          MxListTile(
            leading: const Icon(Icons.tag),
            title: tag.name,
            subtitle: l10n.tagManagementCardCount(tag.cardCount),
            onTap: () => Navigator.of(context).pop(tag.name),
          ),
      ],
    ),
  );
}
