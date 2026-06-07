import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

class FlashcardEditorLoadingState extends StatelessWidget {
  const FlashcardEditorLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      children: <Widget>[
        const MxSkeleton(height: 14, width: 180),
        const SizedBox(height: SpacingTokens.sm),
        const MxSkeleton(height: 10, width: 120),
        const SizedBox(height: SpacingTokens.lg),
        _skeletonField(),
        const SizedBox(height: SpacingTokens.md),
        _skeletonField(),
        const SizedBox(height: SpacingTokens.lg),
        _skeletonField(lines: 2),
        const SizedBox(height: SpacingTokens.lg),
        Row(
          children: <Widget>[
            Container(
              width: SizeTokens.iconMinor,
              height: SizeTokens.iconMinor,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: RadiusTokens.brFull,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            const Expanded(child: MxSkeleton(height: 12)),
          ],
        ),
      ],
    );
  }

  Widget _skeletonField({int lines = 1}) {
    final List<Widget> children = <Widget>[
      const MxSkeleton(height: 12, width: 100),
      const SizedBox(height: SpacingTokens.sm),
    ];
    for (int index = 0; index < lines; index++) {
      children.add(const MxSkeleton(height: 56));
      if (index != lines - 1) {
        children.add(const SizedBox(height: SpacingTokens.sm));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class FlashcardEditorLoadErrorState extends StatelessWidget {
  const FlashcardEditorLoadErrorState({
    required this.title,
    required this.message,
    required this.backLabel,
    required this.retryLabel,
    required this.onBack,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String message;
  final String backLabel;
  final String retryLabel;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: SizeTokens.buttonLg,
                height: SizeTokens.buttonLg,
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.40),
                  borderRadius: RadiusTokens.brMd,
                ),
                alignment: Alignment.center,
                child: Icon(Icons.cloud_off_outlined, color: scheme.error),
              ),
              const SizedBox(height: SpacingTokens.md),
              MxText(
                title,
                role: MxTextRole.titleMedium,
                fontWeight: TypographyTokens.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                message,
                role: MxTextRole.bodyMedium,
                color: scheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                children: <Widget>[
                  Expanded(
                    child: MxSecondaryButton(
                      label: backLabel,
                      onPressed: onBack,
                      variant: MxSecondaryVariant.outlined,
                      size: MxButtonSize.medium,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: MxPrimaryButton(
                      label: retryLabel,
                      onPressed: onRetry,
                      size: MxButtonSize.medium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
