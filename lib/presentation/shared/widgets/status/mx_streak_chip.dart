import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

/// Flame chip showing a streak count — `streak` token (orange).
///
/// Section E of the handoff. The [label] is caller-supplied (localized, e.g.
/// "14-day streak").
class MxStreakChip extends StatelessWidget {
  const MxStreakChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final Color streak = context.customColors.streak;
    return Container(
      height: SizeTokens.surfaceBadgeSm,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      decoration: BoxDecoration(
        color: streak.withValues(alpha: OpacityTokens.focus),
        borderRadius: RadiusTokens.brFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.local_fire_department, size: SizeTokens.iconXs, color: streak),
          const SizedBox(width: SpacingTokens.tight),
          Text(
            label,
            style: context.textTheme.labelLarge?.copyWith(
              color: streak,
              fontWeight: TypographyTokens.bold,
            ),
          ),
        ],
      ),
    );
  }
}
