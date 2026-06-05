import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Visual state of an [MxChoiceOption] (Guess mode).
enum MxChoiceState { idle, correct, wrong }

/// Multiple-choice answer row — idle → correct (green) / wrong (rose).
///
/// Section F of the handoff. State is driven by the parent after a pick;
/// a 100ms `stateChange` cross-fades the color. Wrong answers also fade their
/// content (`fadeOut`).
class MxChoiceOption extends StatelessWidget {
  const MxChoiceOption({
    required this.label,
    required this.state,
    this.onTap,
    super.key,
  });

  final String label;
  final MxChoiceState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color mastery = context.customColors.mastery;
    final Color error = scheme.error;

    final (
      Color border,
      Color fill,
      Color fg,
      IconData? glyph,
    ) = switch (state) {
      MxChoiceState.idle => (
        scheme.outlineVariant,
        scheme.surfaceContainerLowest,
        scheme.onSurface,
        null,
      ),
      MxChoiceState.correct => (
        mastery,
        mastery.withValues(alpha: OpacityTokens.focus),
        mastery,
        Icons.check,
      ),
      MxChoiceState.wrong => (
        error,
        error.withValues(alpha: OpacityTokens.softTint),
        error,
        Icons.close,
      ),
    };

    return AnimatedOpacity(
      duration: DurationTokens.stateChange,
      opacity: state == MxChoiceState.wrong ? OpacityTokens.fadeOut + 0.4 : 1,
      child: MxTappable(
        onTap: onTap,
        borderRadius: RadiusTokens.brMd,
        child: AnimatedContainer(
          duration: DurationTokens.stateChange,
          height: SizeTokens.button,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: RadiusTokens.brMd,
            border: Border.all(color: border, width: BorderTokens.width),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: fg,
                    fontWeight: TypographyTokens.semiBold,
                  ),
                ),
              ),
              if (glyph != null)
                Icon(glyph, size: SizeTokens.iconSm, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
