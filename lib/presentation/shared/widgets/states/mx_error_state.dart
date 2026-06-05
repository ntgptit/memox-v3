import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';

/// Error placeholder — glyph, message, and a retry action.
///
/// Section G of the handoff (Banner/Callout danger tone, full-screen form).
/// Pass localized [title]/[message]/[retryLabel]; failure → copy mapping is the
/// caller's job (`docs/contracts/error-contract.md`).
class MxErrorState extends StatelessWidget {
  const MxErrorState({
    required this.title,
    this.message,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline,
    super.key,
  });

  final String title;
  final String? message;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

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
              width: SizeTokens.iconXl - 12,
              height: SizeTokens.iconXl - 12,
              decoration: BoxDecoration(
                color: scheme.error.withValues(alpha: OpacityTokens.hover),
                borderRadius: RadiusTokens.brLg,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: SizeTokens.iconMd + 2,
                color: scheme.error,
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
            if (retryLabel != null && onRetry != null) ...<Widget>[
              const SizedBox(height: SpacingTokens.lg),
              MxActionButton(
                intent: MxActionIntent.emptyState,
                label: retryLabel!,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
