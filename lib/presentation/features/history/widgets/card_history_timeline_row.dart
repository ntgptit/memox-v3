import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// One timeline event: a node on the left rail + an event card with status chip,
/// relative/absolute time, description, and box-transition · mode meta
/// (`docs/wireframes/09-flashcard-history.md` §Timeline). Attempt duration is
/// not rendered — `study_attempts` has no duration column (documented gap).
class CardHistoryTimelineRow extends StatelessWidget {
  const CardHistoryTimelineRow({
    required this.attempt,
    required this.now,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final CardHistoryAttempt attempt;
  final DateTime now;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color color = _categoryColor(attempt.category, context.colorScheme);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Rail(
            color: color,
            lineColor: context.colorScheme.outlineVariant,
            isFirst: isFirst,
            isLast: isLast,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.md),
              child: _EventCard(attempt: attempt, now: now, color: color),
            ),
          ),
        ],
      ),
    );
  }

  static Color _categoryColor(
    CardHistoryResultCategory category,
    ColorScheme scheme,
  ) => switch (category) {
    CardHistoryResultCategory.correct => scheme.primary,
    CardHistoryResultCategory.recovered => scheme.tertiary,
    CardHistoryResultCategory.forgot => scheme.error,
  };
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.color,
    required this.lineColor,
    required this.isFirst,
    required this.isLast,
  });

  final Color color;
  final Color lineColor;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: SizeTokens.iconMd,
    child: Column(
      children: <Widget>[
        Expanded(child: _segment(isFirst)),
        _Node(color: color),
        Expanded(child: _segment(isLast)),
      ],
    ),
  );

  Widget _segment(bool hidden) => hidden
      ? const SizedBox.shrink()
      : Center(
          child: Container(width: BorderTokens.focusWidth, color: lineColor),
        );
}

class _Node extends StatelessWidget {
  const _Node({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: SpacingTokens.md,
    height: SpacingTokens.md,
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      shape: BoxShape.circle,
      border: Border.all(color: color, width: BorderTokens.focusWidth),
    ),
  );
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.attempt,
    required this.now,
    required this.color,
  });

  final CardHistoryAttempt attempt;
  final DateTime now;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final CardHistoryResultCategory category = attempt.category;

    return MxCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _StatusChip(category: category, color: color),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MxText(
                      CardHistoryLabels.attemptRelative(
                        l10n,
                        attempt.attemptedAt,
                        now,
                      ),
                      role: MxTextRole.labelMedium,
                      fontWeight: TypographyTokens.bold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    MxText(
                      CardHistoryLabels.attemptAbsolute(attempt.attemptedAt),
                      role: MxTextRole.labelSmall,
                      color: scheme.onSurfaceVariant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          MxText(
            CardHistoryLabels.description(l10n, category),
            role: MxTextRole.bodyLarge,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: <Widget>[
              MxText(
                CardHistoryLabels.boxTransition(l10n, attempt),
                role: MxTextRole.labelMedium,
                color: scheme.onSurfaceVariant,
                fontWeight: TypographyTokens.medium,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Icon(
                Icons.layers_outlined,
                size: SizeTokens.iconXs,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: SpacingTokens.xxs),
              Flexible(
                child: MxText(
                  l10n.cardHistoryModeLabel(attempt.studyMode.name),
                  role: MxTextRole.labelMedium,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.category, required this.color});

  final CardHistoryResultCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: OpacityTokens.hover),
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_icon(category), size: SizeTokens.iconXs, color: color),
          const SizedBox(width: SpacingTokens.xxs),
          MxText(
            StringUtils.uppercased(CardHistoryLabels.chipLabel(l10n, category)),
            role: MxTextRole.labelSmall,
            fontWeight: TypographyTokens.bold,
            color: color,
          ),
        ],
      ),
    );
  }

  static IconData _icon(CardHistoryResultCategory category) =>
      switch (category) {
        CardHistoryResultCategory.correct => Icons.check,
        CardHistoryResultCategory.recovered => Icons.north_east,
        CardHistoryResultCategory.forgot => Icons.refresh,
      };
}
