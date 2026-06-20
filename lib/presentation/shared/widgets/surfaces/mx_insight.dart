import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// The tone of an [MxInsight] — drives the icon-tile tint only (never a colored
/// shadow).
enum MxInsightTone { info, good, warn, down, accent }

/// An analytic nudge card (the kit `Insight`) for the Progress surface.
///
/// Purpose:
/// One owner for goal / streak / accuracy / due nudges framed as *insight*, not
/// pressure ("You're close to today's goal"). A tone-tinted tile + headline +
/// short body + optional inline link action.
///
/// Use when:
/// Surfacing a single analytic observation with an optional follow-up link.
///
/// Do not use when:
/// You need a due summary (use `MxDueSummary`) or a primary CTA.
///
/// Category:
/// card
///
/// Public API:
/// Copy is caller-localized.
/// - tone: tint role for the leading tile.
/// - icon / title: the glyph + headline.
/// - description: optional supporting line.
/// - actionLabel / onAction: optional inline link.
class MxInsight extends StatelessWidget {
  const MxInsight({
    required this.icon,
    required this.title,
    this.tone = MxInsightTone.info,
    this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final MxInsightTone tone;
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  Color _tint(MxColors colors) => switch (tone) {
    MxInsightTone.info => colors.info,
    MxInsightTone.good => colors.statusMastered,
    MxInsightTone.warn => colors.statusLearning,
    MxInsightTone.down => colors.danger,
    MxInsightTone.accent => colors.accent,
  };

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    final String? description = this.description;
    final String? actionLabel = this.actionLabel;
    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MxIconTile(color: _tint(colors), icon: icon),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(title, role: MxTextRole.titleSmall),
                if (description != null) ...<Widget>[
                  const SizedBox(height: MxSpacing.space1),
                  MxText(
                    description,
                    role: MxTextRole.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
                if (actionLabel != null) ...<Widget>[
                  const SizedBox(height: MxSpacing.space2),
                  MxSecondaryButton(
                    label: actionLabel,
                    onPressed: onAction,
                    variant: MxSecondaryVariant.text,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
