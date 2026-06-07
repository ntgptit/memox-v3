import 'package:flutter/material.dart';

import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';

/// Zero-data placeholder — glyph, headline, hint, optional CTA.
///
/// Section G of the handoff. The CTA renders as an `emptyState`-intent
/// [MxActionButton] (host-sized) per
/// `docs/ui-ux/action-hierarchy-contract.md`.
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
/// - icon: public content.
/// - title: public content.
/// - message: public content.
/// - actionLabel: public property.
/// - onAction: callback.
/// Category:
/// feedback
class MxEmptyState extends StatelessWidget {
  const MxEmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: SizeTokens.buttonLg,
              height: SizeTokens.buttonLg,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: OpacityTokens.hover),
                borderRadius: RadiusTokens.brLg,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: SizeTokens.surfaceBadge,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(title, style: text.titleMedium),
            if (message != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.lg),
              MxActionButton(
                intent: MxActionIntent.emptyState,
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
