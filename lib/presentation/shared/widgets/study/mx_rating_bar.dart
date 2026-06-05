import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/custom_colors.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// SRS recall rating — Again / Hard / Good / Easy.
///
/// Section F of the handoff. Presentation-level enum; the domain
/// `AttemptResult` (when it exists) maps onto it at the call site. Colors come
/// from the `rating*` tokens.
enum MxRating {
  again,
  hard,
  good,
  easy;

  Color color(CustomColors colors) => switch (this) {
    MxRating.again => colors.ratingAgain,
    MxRating.hard => colors.ratingHard,
    MxRating.good => colors.ratingGood,
    MxRating.easy => colors.ratingEasy,
  };
}

/// Row of four SRS rating buttons used in Review.
///
/// [labels] supplies the localized text per rating (defaults to enum order at
/// the call site). Calls [onRate] with the chosen [MxRating].
class MxRatingBar extends StatelessWidget {
  const MxRatingBar({
    required this.labels,
    required this.onRate,
    super.key,
  }) : assert(labels.length == 4, 'Provide a label for each of the 4 ratings.');

  /// Localized labels in [MxRating] order: again, hard, good, easy.
  final List<String> labels;
  final ValueChanged<MxRating> onRate;

  @override
  Widget build(BuildContext context) {
    final CustomColors colors = context.customColors;
    return Row(
      children: <Widget>[
        for (int i = 0; i < MxRating.values.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: _RatingButton(
              label: labels[i],
              color: MxRating.values[i].color(colors),
              onTap: () => onRate(MxRating.values[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  const _RatingButton({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
      color: color,
      borderRadius: RadiusTokens.brMd,
      child: MxTappable(
        onTap: onTap,
        borderRadius: RadiusTokens.brMd,
        child: SizedBox(
          height: SizeTokens.button,
          child: Center(
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: TypographyTokens.bold,
              ),
            ),
          ),
        ),
      ),
    );
}
