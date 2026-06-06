import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

class FlashcardEditorTagsSection extends StatelessWidget {
  const FlashcardEditorTagsSection({
    required this.title,
    required this.optionalLabel,
    required this.addTagLabel,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    super.key,
  });

  final String title;
  final String optionalLabel;
  final String addTagLabel;
  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.sell_outlined,
              size: SizeTokens.iconSm,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.xs),
            MxText(
              title,
              role: MxTextRole.labelLarge,
              color: scheme.onSurfaceVariant,
              fontWeight: TypographyTokens.semiBold,
            ),
            const SizedBox(width: SpacingTokens.xs),
            MxText(
              optionalLabel,
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.sm,
          runSpacing: SpacingTokens.sm,
          children: <Widget>[
            ...tags.map(
              (String tag) => FlashcardEditorTagChip(
                label: tag,
                onRemove: () => onRemoveTag(tag),
              ),
            ),
            FlashcardEditorAddTagChip(label: addTagLabel, onTap: onAddTag),
          ],
        ),
      ],
    );
  }
}

class FlashcardEditorTagChip extends StatelessWidget {
  const FlashcardEditorTagChip({
    required this.label,
    required this.onRemove,
    super.key,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: onRemove,
      borderRadius: RadiusTokens.brFull,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.12),
          borderRadius: RadiusTokens.brFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MxText(
              label,
              role: MxTextRole.labelMedium,
              color: scheme.primary,
              fontWeight: TypographyTokens.semiBold,
            ),
            const SizedBox(width: SpacingTokens.xs),
            Icon(
              Icons.close_rounded,
              size: SizeTokens.iconXs,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardEditorAddTagChip extends StatelessWidget {
  const FlashcardEditorAddTagChip({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: onTap,
      borderRadius: RadiusTokens.brFull,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: RadiusTokens.brFull,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.add,
              size: SizeTokens.iconXs,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: SpacingTokens.xs),
            MxText(
              label,
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
              fontWeight: TypographyTokens.semiBold,
            ),
          ],
        ),
      ),
    );
  }
}
