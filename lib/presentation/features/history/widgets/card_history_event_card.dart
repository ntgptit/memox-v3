import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/widgets/card_history_labels.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Shared timeline-row scaffold: a node on the left rail + an event card with a
/// chip, relative/absolute time, a description, and optional meta row. Reused by
/// the attempt row and the lifecycle row
/// (`docs/wireframes/09-flashcard-history.md` §Timeline).
class CardHistoryEventCard extends StatelessWidget {
  const CardHistoryEventCard({
    required this.nodeColor,
    required this.isFirst,
    required this.isLast,
    required this.occurredAt,
    required this.now,
    required this.chip,
    required this.description,
    this.meta,
    super.key,
  });

  final Color nodeColor;
  final bool isFirst;
  final bool isLast;
  final DateTime occurredAt;
  final DateTime now;
  final Widget chip;
  final String description;
  final Widget? meta;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Rail(
            color: nodeColor,
            lineColor: scheme.outlineVariant,
            isFirst: isFirst,
            isLast: isLast,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.md),
              child: MxCard(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        chip,
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: _Time(occurredAt: occurredAt, now: now),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    MxText(description, role: MxTextRole.bodyLarge),
                    if (meta != null) ...<Widget>[
                      const SizedBox(height: SpacingTokens.xs),
                      meta!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({required this.occurredAt, required this.now});

  final DateTime occurredAt;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        MxText(
          CardHistoryLabels.relativeTime(l10n, occurredAt, now),
          role: MxTextRole.labelMedium,
          fontWeight: TypographyTokens.bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        MxText(
          CardHistoryLabels.absoluteTime(occurredAt),
          role: MxTextRole.labelSmall,
          color: context.colorScheme.onSurfaceVariant,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
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
        Expanded(child: _segment(hidden: isFirst)),
        _Node(color: color),
        Expanded(child: _segment(hidden: isLast)),
      ],
    ),
  );

  Widget _segment({required bool hidden}) => hidden
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
