import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/shadow_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';

/// Binary confirmation dialog (`docs/wireframes/24-shared-dialogs.md`
/// §delete-confirm and other confirm flows).
///
/// Returns `true` only when the user taps confirm; cancel / dismissal returns
/// `false`. All copy is caller-supplied (localized). [destructive] tints the
/// confirm button with the error role for delete-style actions.
Future<bool> showMxConfirmDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  required String cancelLabel,
  String? message,
  bool destructive = false,
}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final ColorScheme scheme = context.colorScheme;
      return PopScope(
        canPop: false,
        child: Dialog(
          insetPadding: const EdgeInsets.all(SpacingTokens.lg),
          backgroundColor: scheme.surfaceContainerHigh.withValues(alpha: 0),
          surfaceTintColor: scheme.surfaceContainerHigh.withValues(alpha: 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 432),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: RadiusTokens.brLg,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.24),
                    blurRadius: ShadowTokens.blurDialog,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: TypographyTokens.bold,
                      ),
                    ),
                    if (message != null) ...<Widget>[
                      const SizedBox(height: SpacingTokens.md),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.lg),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: SizeTokens.dialogActionWidth,
                            height: SizeTokens.controlMd,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SpacingTokens.md,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: RadiusTokens.brMd,
                                ),
                              ),
                              child: Text(cancelLabel),
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          SizedBox(
                            width: SizeTokens.dialogActionWidth,
                            height: SizeTokens.controlMd,
                            child: FilledButton(
                              style: destructive
                                  ? FilledButton.styleFrom(
                                      backgroundColor: scheme.error,
                                      foregroundColor: scheme.onError,
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpacingTokens.md,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: RadiusTokens.brMd,
                                      ),
                                    )
                                  : FilledButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: SpacingTokens.md,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: RadiusTokens.brMd,
                                      ),
                                    ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(confirmLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}
