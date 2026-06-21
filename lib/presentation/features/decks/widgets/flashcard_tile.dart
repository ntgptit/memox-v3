import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/flashcard_progress.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A flashcard row in the Flashcard-list grouped card (mock `06` `list-row`): an
/// accent-tinted card-stack tile, a `{front} — {back}` title, the SRS state
/// subtitle (`New · not studied` / `Box N · due in Xd`), and a trailing chevron.
/// A tap edits the card; a long-press opens delete.
///
/// The status **chip** the mock draws in the trailing slot is a documented mock
/// visual gap — the business card-state model is New/Due only
/// (`docs/business/srs/srs-review.md` §Rules), with no Learning/Review/Mastered
/// taxonomy to back a chip. WBS 3.4.2.
class FlashcardTile extends StatelessWidget {
  const FlashcardTile({
    required this.card,
    required this.progress,
    required this.now,
    required this.onTap,
    required this.onActions,
    super.key,
  });

  final Flashcard card;

  /// The card's SRS scheduling state, or `null` for a never-studied NEW card.
  final FlashcardProgress? progress;

  /// The instant the `due in {n}d` countdown is measured against (injected so
  /// the row stays deterministic in goldens).
  final DateTime now;

  /// Row tap — edit the card.
  final VoidCallback onTap;

  /// Long-press — open the card overflow (delete).
  final VoidCallback onActions;

  /// The SRS state subtitle. A card with no progress or an unscheduled `dueAt`
  /// is NEW; otherwise it shows the current box + days until next due (the day
  /// of (or past) the due date reads `due today`).
  String _srsSubtitle(AppLocalizations l10n) {
    final FlashcardProgress? p = progress;
    final DateTime? dueAt = p?.dueAt;
    if (p == null || dueAt == null) return l10n.flashcardStateNew;
    final int days = dueAt.difference(now).inDays;
    if (days >= 1) return l10n.flashcardStateBoxDueIn(p.currentBox, days);
    return l10n.flashcardStateBoxDueToday(p.currentBox);
  }

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
            FolderIconTile(color: colors.accent, icon: Icons.copy_all_outlined),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    '${card.front} — ${card.back}',
                    role: MxTextRole.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: MxSpacing.space1),
                  MxText(
                    _srsSubtitle(l10n),
                    role: MxTextRole.bodySmall,
                    color: colors.textSecondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: MxSpacing.space2),
            Icon(
              Icons.chevron_right,
              size: MxIconSize.md,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
