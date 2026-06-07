import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Self-score after write-from-memory — Missed / Partial / Got it.
///
/// Section F of the handoff. Outlined chips in the `self*` tokens (which
/// inherit light values in dark).
enum MxSelfScore {
  missed,
  partial,
  gotIt;

  Color color(CustomColors colors) => switch (this) {
    MxSelfScore.missed => colors.selfMissed,
    MxSelfScore.partial => colors.selfPartial,
    MxSelfScore.gotIt => colors.selfGotIt,
  };
}

/// Three-choice self-assessment row for study flows.
///
/// Purpose:
/// Provides a reusable missed/partial/got-it response row that keeps study
/// feedback styling consistent with MemoX tokens.
///
/// Use when:
/// A study screen needs a compact three-state confidence or recall check.
///
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
/// Category:
/// feedback
///
/// Public API:
/// - labels: localized labels in [MxSelfScore] order
/// - onSelect: callback fired with the chosen score
class MxSelfAssessment extends StatelessWidget {
  const MxSelfAssessment({
    required this.labels,
    required this.onSelect,
    super.key,
  }) : assert(labels.length == 3, 'Provide a label for each of the 3 scores.');

  /// Localized labels in [MxSelfScore] order: missed, partial, gotIt.
  final List<String> labels;
  final ValueChanged<MxSelfScore> onSelect;

  @override
  Widget build(BuildContext context) {
    final CustomColors colors = context.customColors;
    return Row(
      children: <Widget>[
        for (int i = 0; i < MxSelfScore.values.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: _ScoreChip(
              label: labels[i],
              color: MxSelfScore.values[i].color(colors),
              onTap: () => onSelect(MxSelfScore.values[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MxTappable(
    onTap: onTap,
    borderRadius: RadiusTokens.brMd,
    child: Container(
      height: SizeTokens.avatar,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: RadiusTokens.brMd,
        border: Border.all(color: color, width: BorderTokens.width),
      ),
      child: Text(
        label,
        style: context.textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: TypographyTokens.bold,
        ),
      ),
    ),
  );
}
