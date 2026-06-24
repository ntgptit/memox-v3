import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_opacity.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// The Card History header card (kit `09`): a tinted tile + the card front + deck
/// name + a `Box n` chip, over a three-stat row (Reviews / Retention / Avg time).
/// Retention + avg time read `—` until there is review data.
class CardHistoryHeaderCard extends StatelessWidget {
  const CardHistoryHeaderCard({required this.header, super.key});

  final CardHistoryHeader header;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double? accuracy = header.accuracy;
    final int? avgMs = header.avgDurationMs;

    return MxCard(
      key: const ValueKey<String>('mx-node:09-flashcard-history/header'),
      padding: const EdgeInsets.all(MxSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              MxIconTile(
                color: colors.statusReviewing,
                icon: Icons.layers_rounded,
              ),
              const SizedBox(width: MxSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    MxText(
                      header.front,
                      role: MxTextRole.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: MxSpacing.space1),
                    MxText(
                      header.deckName,
                      role: MxTextRole.bodySmall,
                      color: colors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: MxSpacing.space2),
              _BoxChip(box: header.boxNumber),
            ],
          ),
          const SizedBox(height: MxSpacing.space4),
          Row(
            children: <Widget>[
              _Stat(
                value: '${header.reviewCount}',
                label: l10n.cardHistoryReviewsLabel,
              ),
              _Stat(
                value: accuracy == null
                    ? l10n.cardHistoryStatEmpty
                    : '${(accuracy * 100).round()}%',
                label: l10n.cardHistoryRetentionLabel,
              ),
              _Stat(
                value: avgMs == null
                    ? l10n.cardHistoryStatEmpty
                    : l10n.cardHistoryDurationSeconds(_seconds(avgMs)),
                label: l10n.cardHistoryAvgTimeLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// One decimal of seconds from milliseconds (e.g. 5360 → "5.4").
  static String _seconds(int ms) => (ms / 1000).toStringAsFixed(1);
}

class _BoxChip extends StatelessWidget {
  const _BoxChip({required this.box});

  final int box;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space3,
        vertical: MxSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: colors.statusReviewing.withValues(alpha: MxOpacity.selected),
        borderRadius: MxRadius.pillAll,
      ),
      child: MxText(
        AppLocalizations.of(context).cardHistoryBoxChip(box),
        role: MxTextRole.labelSmall,
        color: colors.statusReviewing,
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Expanded(
      child: Column(
        children: <Widget>[
          MxText(
            value,
            role: MxTextRole.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: MxSpacing.space1),
          MxText(
            label,
            role: MxTextRole.bodySmall,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
