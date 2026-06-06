import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/presentation/shared/mx_widgets.dart';

class FlashcardEditorDeckChip extends StatelessWidget {
  const FlashcardEditorDeckChip({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Widget child = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: RadiusTokens.brFull,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.08),
              borderRadius: RadiusTokens.brFull,
            ),
            child: Icon(
              Icons.layers_outlined,
              size: SizeTokens.iconXs,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          MxText(
            label,
            role: MxTextRole.labelMedium,
            color: scheme.onSurface,
            fontWeight: TypographyTokens.semiBold,
          ),
          const SizedBox(width: SpacingTokens.xs),
          Icon(
            Icons.expand_more,
            size: SizeTokens.iconSm,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
    return onTap == null
        ? child
        : MxTappable(
            onTap: onTap,
            borderRadius: RadiusTokens.brFull,
            child: child,
          );
  }
}

class FlashcardEditorRequiredMarker extends StatelessWidget {
  const FlashcardEditorRequiredMarker({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: RadiusTokens.brFull,
          ),
        ),
        const SizedBox(width: SpacingTokens.xs),
        MxText(
          label,
          role: MxTextRole.labelMedium,
          color: scheme.primary,
          fontWeight: TypographyTokens.semiBold,
        ),
      ],
    );
  }
}

class FlashcardEditorFieldSection extends StatelessWidget {
  const FlashcardEditorFieldSection({
    required this.title,
    required this.requiredLabel,
    required this.countLabel,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    required this.validator,
    required this.trailingIcon,
    this.autofocus = false,
    this.minLines = 4,
    this.maxLines,
    this.textInputAction = TextInputAction.newline,
    this.onChanged,
    super.key,
  });

  final String title;
  final String requiredLabel;
  final String countLabel;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FormFieldValidator<String> validator;
  final IconData trailingIcon;
  final bool autofocus;
  final int minLines;
  final int? maxLines;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: SpacingTokens.xs,
                runSpacing: SpacingTokens.xxs,
                children: <Widget>[
                  MxText(
                    title,
                    role: MxTextRole.labelLarge,
                    color: scheme.onSurfaceVariant,
                    fontWeight: TypographyTokens.semiBold,
                  ),
                  MxText(
                    requiredLabel,
                    role: MxTextRole.labelMedium,
                    color: scheme.primary,
                    fontWeight: TypographyTokens.semiBold,
                  ),
                ],
              ),
            ),
            MxText(
              countLabel,
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.xs),
        MxTextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          validator: validator,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onChanged: onChanged,
          hintText: placeholder,
          trailingIcon: trailingIcon,
          prominent: true,
        ),
      ],
    );
  }
}

class FlashcardEditorDetailsSection extends StatelessWidget {
  const FlashcardEditorDetailsSection({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.exampleLabel,
    required this.examplePlaceholder,
    required this.pronunciationLabel,
    required this.pronunciationPlaceholder,
    required this.hintLabel,
    required this.hintPlaceholder,
    required this.exampleController,
    required this.pronunciationController,
    required this.hintController,
    required this.exampleFocusNode,
    required this.pronunciationFocusNode,
    required this.hintFocusNode,
    required this.onToggle,
    required this.onChanged,
    this.pronunciationTrailingIcon,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool expanded;
  final String exampleLabel;
  final String examplePlaceholder;
  final String pronunciationLabel;
  final String pronunciationPlaceholder;
  final String hintLabel;
  final String hintPlaceholder;
  final TextEditingController exampleController;
  final TextEditingController pronunciationController;
  final TextEditingController hintController;
  final FocusNode exampleFocusNode;
  final FocusNode pronunciationFocusNode;
  final FocusNode hintFocusNode;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  final IconData? pronunciationTrailingIcon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: RadiusTokens.brLg,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _DetailsToggleRow(
              title: title,
              subtitle: subtitle,
              expanded: expanded,
              onTap: onToggle,
            ),
            if (expanded) ...<Widget>[
              const SizedBox(height: SpacingTokens.md),
              _OptionalField(
                label: exampleLabel,
                placeholder: examplePlaceholder,
                controller: exampleController,
                focusNode: exampleFocusNode,
                onChanged: onChanged,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: SpacingTokens.md),
              _OptionalField(
                label: hintLabel,
                placeholder: hintPlaceholder,
                controller: hintController,
                focusNode: hintFocusNode,
                onChanged: onChanged,
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: SpacingTokens.md),
              _OptionalField(
                label: pronunciationLabel,
                placeholder: pronunciationPlaceholder,
                controller: pronunciationController,
                focusNode: pronunciationFocusNode,
                onChanged: onChanged,
                minLines: 1,
                maxLines: 2,
                trailingIcon: pronunciationTrailingIcon,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailsToggleRow extends StatelessWidget {
  const _DetailsToggleRow({
    required this.title,
    required this.subtitle,
    required this.expanded,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxTappable(
      onTap: onTap,
      borderRadius: RadiusTokens.brLg,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: RadiusTokens.brLg,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.auto_awesome_outlined,
              size: SizeTokens.iconSm,
              color: scheme.primary,
            ),
            const SizedBox(width: SpacingTokens.sm),
            MxText(
              title,
              role: MxTextRole.labelLarge,
              color: scheme.primary,
              fontWeight: TypographyTokens.semiBold,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: MxText(
                subtitle,
                role: MxTextRole.labelMedium,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: SizeTokens.iconSm,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionalField extends StatelessWidget {
  const _OptionalField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.minLines,
    required this.maxLines,
    this.trailingIcon,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxText(
          label,
          role: MxTextRole.labelLarge,
          color: scheme.onSurfaceVariant,
          fontWeight: TypographyTokens.semiBold,
        ),
        const SizedBox(height: SpacingTokens.xs),
        MxTextField(
          controller: controller,
          focusNode: focusNode,
          minLines: minLines,
          maxLines: maxLines,
          textInputAction: TextInputAction.newline,
          onChanged: onChanged,
          hintText: placeholder,
          trailingIcon: trailingIcon,
          prominent: false,
        ),
      ],
    );
  }
}

class FlashcardEditorSaveFailedBanner extends StatelessWidget {
  const FlashcardEditorSaveFailedBanner({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
    super.key,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

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
          const SizedBox(width: SpacingTokens.sm),
          MxSecondaryButton(
            label: retryLabel,
            onPressed: onRetry,
            variant: MxSecondaryVariant.text,
            size: MxButtonSize.small,
          ),
        ],
      ),
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
