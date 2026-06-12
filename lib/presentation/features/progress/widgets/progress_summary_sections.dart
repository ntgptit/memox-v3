import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/progress/widgets/progress_activity_sections.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// "BOX DISTRIBUTION" section: total + B1..B8 horizontal bars
/// (mock `shots/19-progress--week--*`: B1–B5 primary ramp, B6–B8 mastery
/// ramp, opacity deepening toward B8).
class ProgressBoxDistributionCard extends StatelessWidget {
  const ProgressBoxDistributionCard({required this.distribution, super.key});

  final BoxDistribution distribution;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final int total = distribution.boxes.fold(
      0,
      (int sum, BoxDistributionItem item) => sum + item.cardCount,
    );
    final int maxCount = distribution.boxes.fold(
      0,
      (int max, BoxDistributionItem item) =>
          item.cardCount > max ? item.cardCount : max,
    );

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProgressOverline(label: l10n.progressBoxDistributionTitle),
          if (total == 0)
            ProgressHintBox(text: l10n.progressBoxEmptyHint)
          else ...<Widget>[
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              '$total',
              role: MxTextRole.headlineMedium,
              color: scheme.onSurface,
            ),
            MxText(
              l10n.progressBoxTotalCaption,
              role: MxTextRole.bodySmall,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: SpacingTokens.sm),
            for (final BoxDistributionItem item in distribution.boxes)
              _BoxRow(item: item, maxCount: maxCount),
            const SizedBox(height: SpacingTokens.xs),
            Row(
              children: <Widget>[
                Expanded(
                  child: MxText(
                    l10n.progressBoxLegendLeast,
                    role: MxTextRole.labelSmall,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: MxText(
                    l10n.progressBoxLegendBest,
                    role: MxTextRole.labelSmall,
                    color: scheme.onSurfaceVariant,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BoxRow extends StatelessWidget {
  const _BoxRow({required this.item, required this.maxCount});

  final BoxDistributionItem item;
  final int maxCount;

  /// Mock encoding: fill opacity deepens linearly from B1 to B8
  /// (≈0.43 → 1.0), and the hue switches from primary (learning, B1–B5)
  /// to mastery green (known, B6–B8).
  double get _alpha => 0.35 + 0.65 * (item.boxNumber / 8);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final Color fill = item.boxNumber <= 5
        ? scheme.primary
        : context.customColors.mastery;
    final double fraction = maxCount == 0 ? 0 : item.cardCount / maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xxs),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: SizeTokens.surfaceBadge,
            child: MxText(
              l10n.progressBoxLabel(item.boxNumber),
              role: MxTextRole.labelSmall,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Container(
              height: SpacingTokens.form,
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: RadiusTokens.brXs,
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0, 1).toDouble(),
                child: Container(
                  decoration: BoxDecoration(
                    color: fill.withValues(alpha: _alpha),
                    borderRadius: RadiusTokens.brXs,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          SizedBox(
            width: SizeTokens.surfaceBadgeSm,
            child: MxText(
              '${item.cardCount}',
              role: MxTextRole.labelSmall,
              color: scheme.onSurface,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

/// "STREAK" section: current + longest study-day streak side by side.
class ProgressStreakCard extends StatelessWidget {
  const ProgressStreakCard({required this.streak, super.key});

  final ProgressStreak streak;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ProgressOverline(label: l10n.progressStreakTitle),
          if (streak.currentDays == 0 && streak.longestDays == 0)
            ProgressHintBox(text: l10n.progressStreakEmptyHint)
          else ...<Widget>[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              children: <Widget>[
                Expanded(
                  child: _StreakTile(
                    icon: Icons.local_fire_department_outlined,
                    label: l10n.progressStreakCurrent,
                    days: streak.currentDays,
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: _StreakTile(
                    icon: Icons.emoji_events_outlined,
                    label: l10n.progressStreakLongest,
                    days: streak.longestDays,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StreakTile extends StatelessWidget {
  const _StreakTile({
    required this.icon,
    required this.label,
    required this.days,
  });

  final IconData icon;
  final String label;
  final int days;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: RadiusTokens.brMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: SizeTokens.iconSm, color: scheme.primary),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  label,
                  role: MxTextRole.labelSmall,
                  color: scheme.onSurfaceVariant,
                ),
                MxText(
                  l10n.progressStreakDays(days),
                  role: MxTextRole.titleSmall,
                  color: scheme.onSurface,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Card states" section: suspended + buried-today counts
/// (read-only in V1 — navigation to filtered lists is Future, WBS 2.17.x).
class ProgressCardStatesCard extends StatelessWidget {
  const ProgressCardStatesCard({required this.counts, super.key});

  final ProgressCardStateCounts counts;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CardStateRow(
            icon: Icons.pause_circle_outline,
            title: l10n.progressSuspendedTitle,
            subtitle: l10n.progressSuspendedSubtitle,
            count: counts.suspendedCount,
            caption: l10n.progressSuspendedCaption,
          ),
          const SizedBox(height: SpacingTokens.md),
          _CardStateRow(
            icon: Icons.nightlight_outlined,
            title: l10n.progressBuriedTitle,
            subtitle: l10n.progressBuriedSubtitle,
            count: counts.buriedTodayCount,
            caption: l10n.progressBuriedCaption,
          ),
        ],
      ),
    );
  }
}

class _CardStateRow extends StatelessWidget {
  const _CardStateRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int count;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeTokens.iconTile,
          height: SizeTokens.iconTile,
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: RadiusTokens.brSm,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: SizeTokens.iconXs,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(
                title,
                role: MxTextRole.titleSmall,
                color: scheme.onSurface,
              ),
              MxText(
                subtitle,
                role: MxTextRole.bodySmall,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            MxText(
              '$count',
              role: MxTextRole.titleSmall,
              color: scheme.onSurface,
            ),
            MxText(
              caption,
              role: MxTextRole.labelSmall,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }
}
