import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/folder_visual_tokens.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A Library folder row inside the grouped list-card: a tinted icon tile, the
/// folder name, a metadata digest, an optional due badge, and a trailing
/// chevron (`docs/design/screens/library-overview.visual-contract.md` §Folder
/// Card Contract — mock parity revision).
///
/// Interaction: a tap routes to the folder (folder-detail navigation lands with
/// WBS 3.2.2; until then [onTap] opens the action sheet so the row is never a
/// dead tap), and a long-press always opens the action sheet via [onActions].
/// The tile renders no own card — the body wraps the whole list in one
/// `MxCard`, rows separated by inset hairlines, matching the kit. WBS 3.1.2.
class LibraryFolderTile extends StatelessWidget {
  const LibraryFolderTile({
    required this.summary,
    required this.onTap,
    required this.onActions,
    super.key,
  });

  /// The folder + its recursive counts.
  final FolderSummary summary;

  /// Row tap — opens the folder (interim: the action sheet, until WBS 3.2.2).
  final VoidCallback onTap;

  /// Long-press — opens the folder overflow action sheet.
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxTappable(
      onTap: onTap,
      onLongPress: onActions,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
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
            if (summary.dueCount > 0) ...<Widget>[
              const SizedBox(width: MxSpacing.space2),
              _DueBadge(count: summary.dueCount),
            ],
            const SizedBox(width: MxSpacing.space2),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}

/// The folder metadata digest line — subfolder count, or `{n} decks · {m}
/// cards`, or `Empty` — keyed off the folder's [ContentMode]. Shared by the
/// Library row and the overflow action-sheet header.
String folderMetaLine(AppLocalizations l10n, FolderSummary summary) {
  final ContentMode mode = summary.folder.contentMode;
  if (mode == ContentMode.subfolders) {
    return l10n.folderMetaSubfolders(summary.subfolderCount);
  }
  if (mode == ContentMode.decks) {
    return '${l10n.folderMetaDecks(summary.deckCount)} · '
        '${l10n.folderMetaCards(summary.cardCount)}';
  }
  return l10n.folderMetaEmpty;
}

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space2,
        vertical: MxSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: MxRadius.pillAll,
      ),
      child: MxText(
        AppLocalizations.of(context).folderDueBadge(count),
        role: MxTextRole.labelSmall,
        color: colors.accent,
      ),
    );
  }
}
