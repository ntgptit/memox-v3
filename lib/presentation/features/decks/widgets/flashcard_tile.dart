import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A flashcard row in the Flashcard-list grouped card (mock `06`): an
/// accent-tinted card-stack tile, the card front (title), the back (subtitle),
/// and a trailing chevron. A tap edits the card; a long-press opens delete.
///
/// V1 shows front/back only. The SRS box / status chip + due text from the mock
/// need the `flashcard_progress` row, which the list read model does not carry
/// yet — they surface when it does. WBS 3.4.2.
class FlashcardTile extends StatelessWidget {
  const FlashcardTile({
    required this.card,
    required this.onTap,
    required this.onActions,
    super.key,
  });

  final Flashcard card;

  /// Row tap — edit the card.
  final VoidCallback onTap;

  /// Long-press — open the card overflow (delete).
  final VoidCallback onActions;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxTappable(
      onTap: onTap,
      onLongPress: onActions,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
          children: <Widget>[
            FolderIconTile(color: colors.accent, icon: Icons.copy_all_outlined),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    card.front,
                    role: MxTextRole.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  MxText(
                    card.back,
                    role: MxTextRole.bodySmall,
                    color: colors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: MxSpacing.space2),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }
}
