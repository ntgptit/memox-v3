part of 'flashcard_editor_sections.dart';

/// Save-failure banner anchored just above the editor bottom bar
/// (`docs/wireframes/07-flashcard-create.md` save-failed,
/// `docs/wireframes/08-flashcard-edit.md` save-failed). Text-only: the retry
/// affordance is the bottom bar's "Retry save" CTA, so the banner carries no
/// button of its own.
class FlashcardEditorSaveFailedBanner extends StatelessWidget {
  const FlashcardEditorSaveFailedBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      key: const ValueKey<String>('flashcard_editor_save_failed_banner'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: RadiusTokens.brLg,
        border: Border.all(color: scheme.error),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline, color: scheme.error),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: MxText(
              message,
              role: MxTextRole.bodyMedium,
              color: scheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardEditorDangerZoneSection extends StatelessWidget {
  const FlashcardEditorDangerZoneSection({
    required this.zoneLabel,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final String zoneLabel;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: SpacingTokens.xs),
        Container(height: BorderTokens.width, color: scheme.outlineVariant),
        const SizedBox(height: SpacingTokens.lg),
        Row(
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              size: SizeTokens.iconXs,
              color: scheme.error,
            ),
            const SizedBox(width: SpacingTokens.xs),
            MxText(
              zoneLabel,
              role: MxTextRole.labelLarge,
              color: scheme.error,
              fontWeight: TypographyTokens.semiBold,
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            color: scheme.error.withValues(alpha: 0.03),
            borderRadius: RadiusTokens.brLg,
            border: Border.all(color: scheme.error.withValues(alpha: 0.20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MxText(
                title,
                role: MxTextRole.titleSmall,
                color: scheme.onSurface,
                fontWeight: TypographyTokens.semiBold,
              ),
              const SizedBox(height: SpacingTokens.xxs),
              MxText(
                message,
                role: MxTextRole.bodySmall,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(height: SpacingTokens.md),
              MxSecondaryButton(
                label: actionLabel,
                onPressed: onAction,
                variant: MxSecondaryVariant.outlined,
                size: MxButtonSize.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FlashcardEditorBottomHelperText extends StatelessWidget {
  const FlashcardEditorBottomHelperText({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => MxText(
    label,
    role: MxTextRole.bodySmall,
    color: context.colorScheme.onSurfaceVariant,
    textAlign: TextAlign.center,
  );
}
