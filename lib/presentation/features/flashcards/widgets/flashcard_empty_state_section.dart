import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';

/// Empty-deck state (`docs/wireframes/06-flashcard-list.md` §empty state): glyph,
/// headline, hint, and the dual Add / Import CTAs. Shown when the deck holds no
/// cards (`totalCount == 0`), regardless of any active search term.
class FlashcardEmptyState extends StatelessWidget {
  const FlashcardEmptyState({
    required this.onAddCard,
    required this.onImport,
    super.key,
  });

  final VoidCallback onAddCard;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    final TextTheme text = context.textTheme;

    return Center(
      key: const ValueKey<String>('flashcard_empty_state'),
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
                Icons.style_outlined,
                size: SizeTokens.surfaceBadge,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(l10n.flashcardsEmptyTitle, style: text.titleMedium),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.flashcardsEmptyMessage,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxActionButton(
              intent: MxActionIntent.emptyState,
              label: l10n.flashcardListAddCardAction,
              icon: Icons.add,
              fullWidth: true,
              onPressed: onAddCard,
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxActionButton(
              intent: MxActionIntent.inline,
              label: l10n.flashcardListImportAction,
              icon: Icons.file_download_outlined,
              onPressed: onImport,
            ),
          ],
        ),
      ),
    );
  }
}
