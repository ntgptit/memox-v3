import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Goal / session progress track.
///
/// Section E of the handoff. Tone is `primary` by default; pass [color] (e.g.
/// the mastery green) to recolor. Heights 4 / 8.
///
/// Purpose:
/// Provides a reusable MemoX display widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared display surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - value: public configuration.
/// - color: public content.
/// - height: public configuration.
/// Category:
/// display
class MxLinearProgress extends StatelessWidget {
  const MxLinearProgress({
    required this.value,
    this.color,
    this.height = SpacingTokens.sm,
    super.key,
  });

  /// Progress in `0..1`.
  final double value;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ClipRRect(
      borderRadius: RadiusTokens.brFull,
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: scheme.surfaceContainerHighest,
        color: color ?? scheme.primary,
      ),
    );
  }
}
