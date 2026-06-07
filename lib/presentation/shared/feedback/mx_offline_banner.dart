import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';

/// Connectivity inline banner — non-blocking, dismiss-on-reconnect.
///
/// Section G of the handoff. Driven by a connectivity stream at the call site;
/// the [message] (and optional [action] copy) are localized by the caller.
/// Render it at the top of a screen body, collapsed when online.
///
/// Purpose:
/// Provides a reusable MemoX feedback widget that stays aligned with the design system.
///
/// Use when:
/// A screen needs the shared feedback surface instead of a one-off custom widget.
///
/// Do not use when:
/// A different interaction pattern or a one-off layout is a better fit.
///
/// Public API:
/// - message: public content.
/// - actionLabel: public property.
/// - onAction: callback.
/// Category:
/// feedback
class MxOfflineBanner extends StatelessWidget {
  const MxOfflineBanner({
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color tone = context.customColors.warning;
    return Material(
      color: tone.withValues(alpha: OpacityTokens.focus),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.inline,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.cloud_off_outlined,
              size: SizeTokens.iconSm,
              color: tone,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}
