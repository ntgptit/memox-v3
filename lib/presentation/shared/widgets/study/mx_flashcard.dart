import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/duration_tokens.dart';
import 'package:memox/core/theme/tokens/easing_tokens.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';

/// Flip card — front (term) / back (meaning). 350ms `cardFlip`, never a bounce.
///
/// Section F of the handoff. Controlled by [showBack]; tapping toggles the face
/// (or call [onTap] yourself). The back face uses the primary outline + tint.
class MxFlashcard extends StatelessWidget {
  const MxFlashcard({
    required this.front,
    required this.back,
    required this.showBack,
    this.onTap,
    this.minHeight = 200,
    super.key,
  });

  final Widget front;
  final Widget back;
  final bool showBack;
  final VoidCallback? onTap;
  final double minHeight;

  @override
  Widget build(BuildContext context) => MxTappable(
    onTap: onTap,
    borderRadius: RadiusTokens.brLg,
    child: TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showBack ? 1 : 0),
      duration: DurationTokens.cardFlip,
      curve: EasingTokens.standard,
      builder: (BuildContext context, double t, _) {
        final bool showingBack = t >= 0.5;
        final double angle = t * math.pi;
        final Widget face = showingBack
            ? _FlashcardFace(isBack: true, minHeight: minHeight, child: back)
            : _FlashcardFace(isBack: false, minHeight: minHeight, child: front);
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: showingBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: face,
                )
              : face,
        );
      },
    ),
  );
}

class _FlashcardFace extends StatelessWidget {
  const _FlashcardFace({
    required this.isBack,
    required this.minHeight,
    required this.child,
  });

  final bool isBack;
  final double minHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.all(SpacingTokens.xl),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isBack
            ? scheme.primary.withValues(alpha: OpacityTokens.softTint)
            : scheme.surfaceContainerLowest,
        borderRadius: RadiusTokens.brLg,
        border: Border.fromBorderSide(
          isBack
              ? BorderSide(color: scheme.primary, width: BorderTokens.width)
              : BorderTokens.ghostSide(scheme.primary),
        ),
      ),
      child: child,
    );
  }
}
