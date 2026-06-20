import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/folder_summary.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// A Library folder card: folder icon, name, a metadata digest, an optional due
/// badge, and a trailing kebab that opens the folder action sheet. No chevron
/// (`docs/design/screens/library-overview.visual-contract.md` §Folder Card
/// Contract). WBS 3.1.2.
class LibraryFolderTile extends StatelessWidget {
  const LibraryFolderTile({
    required this.summary,
    required this.onActions,
    this.onTap,
    super.key,
  });

  /// The folder + its recursive counts.
  final FolderSummary summary;

  /// Opens the folder action sheet (kebab tap / row long-press).
  final VoidCallback onActions;

  /// Row tap (folder detail navigation lands with WBS 3.2.2; may be null).
  final VoidCallback? onTap;

  String _meta(AppLocalizations l10n) {
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

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxCard(
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Icon(Icons.folder_outlined, color: colors.accent),
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
                  _meta(l10n),
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
          MxIconButton(
            icon: Icons.more_vert,
            tooltip: l10n.libraryOverflowTooltip,
            onPressed: onActions,
          ),
        ],
      ),
    );
  }
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
