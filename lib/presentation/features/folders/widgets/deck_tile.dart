import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/relative_time.dart';
import 'package:memox/domain/models/deck_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// A deck row inside the Folder-detail grouped list (mock `04 · decks`): an
/// accent-tinted deck tile, the deck name, a `{n} cards · last {time} ago`
/// digest, an optional due badge, and a trailing chevron. A tap opens the deck's
/// flashcard list; a long-press opens the deck action sheet. WBS 3.2.2.
class DeckTile extends StatelessWidget {
  const DeckTile({
    required this.summary,
    required this.onTap,
    required this.onActions,
    this.now,
    super.key,
  });

  /// The deck + its card/due counts.
  final DeckSummary summary;

  /// Row tap — opens the deck's flashcard list.
  final VoidCallback onTap;

  /// Long-press — opens the deck overflow action sheet.
  final VoidCallback onActions;

  /// Reference time for the relative `last studied` label. Defaults to
  /// `DateTime.now()`; injected by tests/goldens for determinism.
  final DateTime? now;

  /// `{n} cards`, plus `· {last studied}` when the deck has been studied.
  String _metaLine(AppLocalizations l10n) {
    final String cards = l10n.folderMetaCards(summary.cardCount);
    final DateTime? last = summary.lastStudiedAt;
    if (last == null) return cards;
    return '$cards · ${_lastStudiedLabel(l10n, last, now ?? DateTime.now())}';
  }

  String _lastStudiedLabel(AppLocalizations l10n, DateTime last, DateTime ref) {
    final RelativeTime rel = relativeTimeFrom(last, ref);
    return switch (rel.unit) {
      RelativeTimeUnit.justNow => l10n.deckLastStudiedJustNow,
      RelativeTimeUnit.minutes => l10n.deckLastStudiedMinutes(rel.count),
      RelativeTimeUnit.hours => l10n.deckLastStudiedHours(rel.count),
      RelativeTimeUnit.days => l10n.deckLastStudiedDays(rel.count),
      RelativeTimeUnit.weeks => l10n.deckLastStudiedWeeks(rel.count),
    };
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
                    _metaLine(l10n),
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
