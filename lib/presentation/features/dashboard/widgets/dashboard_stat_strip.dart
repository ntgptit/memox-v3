import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Dashboard engagement stat strip (kit `02 · stat-summary`): one card with
/// four neutral metrics — Due / Decks / Accuracy / Streak. "Due" is the single
/// accented number so it reads as the notable figure without nagging the user to
/// study. Accuracy shows the [AppLocalizations.dashboardStatEmpty] placeholder
/// until there is graded activity (no fabricated 0%). Keyed
/// `mx-node:02-dashboard/stat-summary`.
class DashboardStatStrip extends StatelessWidget {
  const DashboardStatStrip({
    required this.cardsDue,
    required this.totalDecks,
    required this.accuracyPercent,
    required this.currentStreak,
    super.key,
  });

  final int cardsDue;
  final int totalDecks;

  /// Null until there is graded activity — rendered as the em-dash placeholder.
  final int? accuracyPercent;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey<String>('mx-node:02-dashboard/stat-summary'),
      padding: const EdgeInsets.symmetric(
        vertical: MxSpacing.space4,
        horizontal: MxSpacing.space2,
      ),
      child: Row(
        children: <Widget>[
          _Stat(value: '$cardsDue', label: l10n.dashboardStatDue, accent: true),
          _Stat(value: '$totalDecks', label: l10n.dashboardStatDecks),
          _Stat(
            value: accuracyPercent == null
                ? l10n.dashboardStatEmpty
                : '$accuracyPercent%',
            label: l10n.dashboardStatAccuracy,
          ),
          _Stat(value: '$currentStreak', label: l10n.dashboardStatStreak),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.accent = false});

  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          MxText(
            value,
            role: MxTextRole.displayMedium,
            color: accent ? colors.accent : colors.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MxSpacing.space1),
          MxText(
            label,
            role: MxTextRole.labelSmall,
            color: colors.textSecondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
