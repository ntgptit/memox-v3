import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// One stat shown in the [FolderStatsCard]: a big count + a short label.
typedef FolderStat = ({int value, String label});

/// The Folder-detail summary card (mock `04`): three stat columns
/// (Decks/Cards/Due or Subfolders/Decks/Due). The last column is the **Due**
/// stat and gets an accent-tinted highlight. WBS 3.2.2.
class FolderStatsCard extends StatelessWidget {
  const FolderStatsCard({required this.stats, super.key});

  /// Exactly three stats, left to right; the last is highlighted (Due).
  final List<FolderStat> stats;

  @override
  Widget build(BuildContext context) => MxCard(
    padding: const EdgeInsets.all(MxSpacing.space2),
    child: Row(
      children: <Widget>[
        for (int i = 0; i < stats.length; i++)
          Expanded(
            child: _StatColumn(
              stat: stats[i],
              highlighted: i == stats.length - 1,
            ),
          ),
      ],
    ),
  );
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.stat, required this.highlighted});

  final FolderStat stat;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
      decoration: highlighted
          ? BoxDecoration(
              color: colors.accentSoft,
              borderRadius: MxRadius.mdAll,
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText(
            '${stat.value}',
            role: MxTextRole.titleLarge,
            color: highlighted ? colors.accent : null,
          ),
          const SizedBox(height: MxSpacing.space1),
          MxText(
            stat.label,
            role: MxTextRole.labelSmall,
            color: highlighted ? colors.accent : colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
