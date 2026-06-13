import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/types/box_number.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// "CURRENT PROGRESS" card: Leitner box stepper + the lifetime stat grid
/// (`docs/wireframes/09-flashcard-history.md` §CURRENT PROGRESS).
class CardHistoryProgressCard extends StatelessWidget {
  const CardHistoryProgressCard({
    required this.header,
    required this.now,
    super.key,
  });

  final CardHistoryHeader header;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color muted = context.colorScheme.onSurfaceVariant;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxText(
            StringUtils.uppercased(l10n.cardHistoryProgressTitle),
            role: MxTextRole.labelSmall,
            color: muted,
            fontWeight: TypographyTokens.bold,
          ),
          const SizedBox(height: SpacingTokens.md),
          _BoxStepper(boxNumber: header.boxNumber),
          const SizedBox(height: SpacingTokens.lg),
          _StatRow(
            left: _Stat(
              icon: Icons.schedule_outlined,
              label: l10n.cardHistoryStatDue,
              value: CardHistoryLabels.dueValue(l10n, header, now),
            ),
            right: _Stat(
              icon: Icons.sync_alt,
              label: l10n.cardHistoryStatReviews,
              value: '${header.reviewCount}',
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _StatRow(
            left: _Stat(
              icon: Icons.track_changes_outlined,
              label: l10n.cardHistoryStatRecall,
              value: CardHistoryLabels.recallValue(l10n, header),
            ),
            right: _Stat(
              icon: Icons.replay,
              label: l10n.cardHistoryStatLapses,
              value: '${header.lapseCount}',
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _StatRow(
            left: _Stat(
              icon: Icons.local_fire_department_outlined,
              label: l10n.cardHistoryStatStreak,
              value: CardHistoryLabels.streakValue(l10n, header.correctStreak),
            ),
            right: _Stat(
              icon: Icons.calendar_today_outlined,
              label: l10n.cardHistoryStatSinceAdded,
              value: CardHistoryLabels.sinceAddedValue(
                l10n,
                header.createdAt,
                now,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxStepper extends StatelessWidget {
  const _BoxStepper({required this.boxNumber});

  final int boxNumber;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            for (int box = kMinBox; box <= kMaxBox; box++) ...<Widget>[
              if (box > kMinBox) const SizedBox(width: SpacingTokens.xxs),
              Expanded(
                child: Container(
                  height: SpacingTokens.xs,
                  decoration: BoxDecoration(
                    color: box == boxNumber
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: RadiusTokens.brFull,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        Row(
          children: <Widget>[
            MxText(
              l10n.cardHistoryBoxStepLabel(kMinBox),
              role: MxTextRole.labelSmall,
              color: scheme.onSurfaceVariant,
            ),
            Expanded(
              child: Center(
                child: MxText(
                  l10n.cardHistoryBoxStepLabel(boxNumber),
                  role: MxTextRole.labelSmall,
                  color: scheme.primary,
                  fontWeight: TypographyTokens.bold,
                ),
              ),
            ),
            MxText(
              l10n.cardHistoryBoxStepLabel(kMaxBox),
              role: MxTextRole.labelSmall,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(child: left),
      const SizedBox(width: SpacingTokens.md),
      Expanded(child: right),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: SizeTokens.iconLg,
          height: SizeTokens.iconLg,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: OpacityTokens.hover),
            borderRadius: RadiusTokens.brSm,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: SizeTokens.iconXs, color: scheme.primary),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxText(
                label,
                role: MxTextRole.labelMedium,
                color: scheme.onSurfaceVariant,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SpacingTokens.xxs),
              MxText(
                value,
                role: MxTextRole.bodyLarge,
                fontWeight: TypographyTokens.bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
