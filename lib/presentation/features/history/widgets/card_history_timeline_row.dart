import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_event_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// One attempt event in the timeline: a node on the left rail + an event card
/// with status chip, relative/absolute time, description, and
/// `B{before} → B{after}` · mode · duration meta
/// (`docs/wireframes/09-flashcard-history.md` §Timeline).
class CardHistoryTimelineRow extends StatelessWidget {
  const CardHistoryTimelineRow({
    required this.attempt,
    required this.now,
    required this.isFirst,
    required this.isLast,
    super.key,
  });

  final CardHistoryAttemptEvent attempt;
  final DateTime now;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color color = _categoryColor(attempt.category, context);
    return CardHistoryEventCard(
      nodeColor: color,
      isFirst: isFirst,
      isLast: isLast,
      occurredAt: attempt.occurredAt,
      now: now,
      chip: _StatusChip(category: attempt.category, color: color),
      description: CardHistoryLabels.attemptDescription(
        AppLocalizations.of(context),
        attempt,
      ),
      meta: _AttemptMeta(attempt: attempt, color: color),
    );
  }

  static Color _categoryColor(
    CardHistoryResultCategory category,
    BuildContext context,
  ) => switch (category) {
    CardHistoryResultCategory.correct => context.colorScheme.primary,
    CardHistoryResultCategory.recovered => context.customColors.streak,
    CardHistoryResultCategory.forgot => context.colorScheme.error,
  };
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.category, required this.color});

  final CardHistoryResultCategory category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _Chip(
      color: color,
      icon: _icon(category),
      label: CardHistoryLabels.attemptChipLabel(l10n, category),
    );
  }

  static IconData _icon(CardHistoryResultCategory category) =>
      switch (category) {
        CardHistoryResultCategory.correct => Icons.check,
        CardHistoryResultCategory.recovered => Icons.north_east,
        CardHistoryResultCategory.forgot => Icons.refresh,
      };
}

class _AttemptMeta extends StatelessWidget {
  const _AttemptMeta({required this.attempt, required this.color});

  final CardHistoryAttemptEvent attempt;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color muted = context.colorScheme.onSurfaceVariant;
    final bool decreased = attempt.boxAfter < attempt.boxBefore;

    return Row(
      children: <Widget>[
        if (attempt.hasBoxTransition) ...<Widget>[
          MxText(
            CardHistoryLabels.boxLabel(l10n, attempt.boxBefore),
            role: MxTextRole.labelMedium,
            color: color.withValues(alpha: OpacityTokens.hint),
            fontWeight: TypographyTokens.medium,
          ),
          Icon(
            decreased ? Icons.arrow_back : Icons.arrow_forward,
            size: SizeTokens.iconXs,
            color: color,
          ),
          MxText(
            CardHistoryLabels.boxLabel(l10n, attempt.boxAfter),
            role: MxTextRole.labelMedium,
            color: color,
            fontWeight: TypographyTokens.bold,
          ),
          const SizedBox(width: SpacingTokens.sm),
        ],
        Icon(Icons.layers_outlined, size: SizeTokens.iconXs, color: muted),
        const SizedBox(width: SpacingTokens.xxs),
        Flexible(
          child: MxText(
            l10n.cardHistoryModeLabel(attempt.studyMode.name),
            role: MxTextRole.labelMedium,
            color: muted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: SpacingTokens.sm),
        if (attempt.durationMs != null)
          Icon(Icons.timer_outlined, size: SizeTokens.iconXs, color: muted),
        if (attempt.durationMs != null)
          const SizedBox(width: SpacingTokens.xxs),
        Flexible(
          child: MxText(
            CardHistoryLabels.durationValue(l10n, attempt.durationMs),
            role: MxTextRole.labelMedium,
            color: muted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Shared pill chip for both attempt status and lifecycle event kinds.
class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.icon, required this.label});

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
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
        Icon(icon, size: SizeTokens.iconXs, color: color),
        const SizedBox(width: SpacingTokens.xxs),
        MxText(
          StringUtils.uppercased(label),
          role: MxTextRole.labelSmall,
          fontWeight: TypographyTokens.bold,
          color: color,
        ),
      ],
    ),
  );
}

/// Public chip reused by the lifecycle row.
class CardHistoryChip extends StatelessWidget {
  const CardHistoryChip({
    required this.color,
    required this.icon,
    required this.label,
    super.key,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) =>
      _Chip(color: color, icon: icon, label: label);
}
