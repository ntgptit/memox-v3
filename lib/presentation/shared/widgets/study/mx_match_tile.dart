import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Visual state of an [MxMatchTile] (Match mode).
enum MxMatchState { idle, selected, matched, wrong }

/// Match-pairs grid tile — idle / selected (filled primary) / matched (green) / wrong (red flash).
///
/// Section F of the handoff. Matched tiles are non-interactive.
///
/// Purpose:
/// Provides a reusable MemoX button widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared button surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - label: public content.
/// - state: public configuration.
/// - onTap: callback.
/// - height: public configuration.
///
/// States:
/// default, selected, disabled
/// Category:
/// button
class MxMatchTile extends StatelessWidget {
  const MxMatchTile({
    required this.label,
    required this.state,
    this.onTap,
    this.height = 48,
    super.key,
  });

  final String label;
  final MxMatchState state;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color mastery = context.customColors.mastery;

    final (
      Color fill,
      Color fg,
      Border? border,
      bool checked,
    ) = switch (state) {
      MxMatchState.idle => (
        scheme.surfaceContainerLowest,
        scheme.onSurface,
        Border.fromBorderSide(BorderTokens.ghostSide(scheme.primary)),
        false,
      ),
      MxMatchState.selected => (scheme.primary, scheme.onPrimary, null, false),
      MxMatchState.matched => (
        scheme.surfaceContainerLowest,
        mastery,
        Border.all(color: mastery, width: BorderTokens.width),
        true,
      ),
      MxMatchState.wrong => (
        scheme.errorContainer,
        scheme.onErrorContainer,
        null,
        false,
      ),
    };

    return AnimatedContainer(
      duration: DurationTokens.stateChange,
      height: height,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          side: border?.top ?? BorderSide.none,
          borderRadius: RadiusTokens.brMd,
        ),
        child: MxTappable(
          onTap: state == MxMatchState.matched || state == MxMatchState.wrong
              ? null
              : onTap,
          borderRadius: RadiusTokens.brMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (checked) ...<Widget>[
                  Icon(Icons.check, size: SizeTokens.iconSm, color: fg),
                  const SizedBox(width: SpacingTokens.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: TypographyTokens.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
