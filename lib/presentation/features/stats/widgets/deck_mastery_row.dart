import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/deck_mastery.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_mastery_bar.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// One row of the Stats "Per-deck mastery" list (kit `MasteryRow`): a tinted
/// deck tile, the deck name over its mastery bar, and the trailing mastery
/// percent.
///
/// Decks carry no stored color/icon (only folders do; `deck.dart`), so the
/// leading tile cycles the four SRS-status tints by [index] to echo the mock's
/// varied chips and uses one generic deck glyph. Per-deck custom icons are a
/// schema gap parked for batch resolution (`docs/wireframes/18-stats.md`).
class DeckMasteryRow extends StatelessWidget {
  const DeckMasteryRow({required this.deck, required this.index, super.key});

  final DeckMastery deck;
  final int index;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Color> tints = <Color>[
      colors.statusNew,
      colors.statusLearning,
      colors.statusReviewing,
      colors.statusMastered,
    ];
    final Color tint = tints[index % tints.length];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
      child: Row(
        children: <Widget>[
          MxIconTile(color: tint, icon: Icons.style_outlined),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  deck.deckName,
                  role: MxTextRole.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: MxSpacing.space2),
                MxMasteryBar(fraction: deck.masteryFraction),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space3),
          SizedBox(
            width: MxSpacing.space12,
            child: MxText(
              l10n.statsMasteryPercent(deck.masteryPercent),
              role: MxTextRole.labelLarge,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
