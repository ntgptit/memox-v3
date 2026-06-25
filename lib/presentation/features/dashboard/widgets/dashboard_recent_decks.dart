import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_icon_size.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/relative_time.dart';
import 'package:memox/domain/models/dashboard_recent_deck.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// The Dashboard "Recent decks" section (kit `02 · recent-decks`): a header with
/// a Library link + a card listing the most-recently-studied decks (deck icon,
/// name, `{n} cards · last {time}` digest, due badge, chevron). Keyed
/// `mx-node:02-dashboard/recent-decks` on the list card; tapping a row opens the
/// Library. Mirrors the Folder-detail `DeckTile` row, reusing its l10n.
class DashboardRecentDecks extends StatelessWidget {
  const DashboardRecentDecks({
    required this.decks,
    required this.onDeckTap,
    required this.onSeeAll,
    this.now,
    super.key,
  });

  final List<DashboardRecentDeck> decks;
  final ValueChanged<DeckId> onDeckTap;
  final VoidCallback onSeeAll;

  /// Reference time for the relative `last studied` label (injected by tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: MxText(
                l10n.dashboardRecentDecksTitle,
                role: MxTextRole.labelSmall,
                color: colors.textSecondary,
              ),
            ),
            MxTappable(
              onTap: onSeeAll,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    l10n.libraryTitle,
                    role: MxTextRole.labelLarge,
                    color: colors.accent,
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: MxIconSize.sm,
                    color: colors.accent,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:02-dashboard/recent-decks'),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < decks.length; i++) ...<Widget>[
                if (i > 0) const MxDivider(),
                _RecentDeckRow(
                  deck: decks[i],
                  onTap: () => onDeckTap(decks[i].deckId),
                  now: now,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentDeckRow extends StatelessWidget {
  const _RecentDeckRow({required this.deck, required this.onTap, this.now});

  final DashboardRecentDeck deck;
  final VoidCallback onTap;
  final DateTime? now;

  String _metaLine(AppLocalizations l10n) {
    final String cards = l10n.folderMetaCards(deck.cardCount);
    final RelativeTime rel = relativeTimeFrom(
      deck.lastStudiedAt,
      now ?? DateTime.now(),
    );
    final String last = switch (rel.unit) {
      RelativeTimeUnit.justNow => l10n.deckLastStudiedJustNow,
      RelativeTimeUnit.minutes => l10n.deckLastStudiedMinutes(rel.count),
      RelativeTimeUnit.hours => l10n.deckLastStudiedHours(rel.count),
      RelativeTimeUnit.days => l10n.deckLastStudiedDays(rel.count),
      RelativeTimeUnit.weeks => l10n.deckLastStudiedWeeks(rel.count),
    };
    return '$cards · $last';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;

    return MxTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
          children: <Widget>[
            MxIconTile(color: colors.accent, icon: Icons.style_outlined),
            const SizedBox(width: MxSpacing.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MxText(
                    deck.name,
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
            if (deck.hasDue) ...<Widget>[
              const SizedBox(width: MxSpacing.space2),
              _DueBadge(count: deck.dueCount),
            ],
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

class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space3,
        vertical: MxSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: MxRadius.pillAll,
      ),
      child: MxText(
        AppLocalizations.of(context).folderDueBadge(count),
        role: MxTextRole.labelSmall,
        color: colors.accentContrast,
      ),
    );
  }
}
