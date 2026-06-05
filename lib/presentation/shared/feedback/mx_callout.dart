import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Tone of an [MxCallout] — drives bg tint, border, and icon color.
///
/// Section G of the handoff: info (primary) / warning (streak) /
/// danger (error) / ok (mastery).
enum MxCalloutTone { info, warning, danger, ok }

/// Inline contextual message — tinted background + matching border + icon.
///
/// Section G of the handoff. The [message] is caller-supplied (localized);
/// optional trailing [action] (e.g. a text button).
class MxCallout extends StatelessWidget {
  const MxCallout({
    required this.message,
    this.tone = MxCalloutTone.info,
    this.icon,
    this.action,
    super.key,
  });

  final String message;
  final MxCalloutTone tone;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final Color tint = _toneColor(context, tone);
    final IconData glyph = icon ?? _defaultIcon(tone);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm + 2,
      ),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: OpacityTokens.hover),
        borderRadius: RadiusTokens.brMd,
        border: Border.all(color: tint.withValues(alpha: OpacityTokens.selected)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(glyph, size: SizeTokens.iconXs, color: tint),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
          if (action != null) ...<Widget>[
            const SizedBox(width: SpacingTokens.sm),
            action!,
          ],
        ],
      ),
    );
  }

  Color _toneColor(BuildContext context, MxCalloutTone tone) => switch (tone) {
    MxCalloutTone.info => context.colorScheme.primary,
    MxCalloutTone.warning => context.customColors.streak,
    MxCalloutTone.danger => context.colorScheme.error,
    MxCalloutTone.ok => context.customColors.mastery,
  };

  IconData _defaultIcon(MxCalloutTone tone) => switch (tone) {
    MxCalloutTone.info => Icons.info_outline,
    MxCalloutTone.warning => Icons.warning_amber_outlined,
    MxCalloutTone.danger => Icons.error_outline,
    MxCalloutTone.ok => Icons.check_circle_outline,
  };
}
