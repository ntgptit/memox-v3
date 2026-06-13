import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_button_size.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Empty-deck state (`docs/wireframes/06-flashcard-list.md` §empty state): a
/// framed card with glyph + headline + hint, then the full-width Add / Import
/// CTAs. Shown when the deck holds no cards (`totalCount == 0`), regardless of
/// any active search term.
///
/// The mock's "Start study is available once you have at least one card" note is
/// **Future** — the study layer is not wired to this screen — so it is omitted
/// rather than faked.
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

    return ListView(
      key: const ValueKey<String>('flashcard_empty_state'),
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
      children: <Widget>[
        MxCard(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.xl,
          ),
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
              MxText(
                l10n.flashcardsEmptyTitle,
                role: MxTextRole.titleMedium,
                fontWeight: TypographyTokens.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpacingTokens.xs),
              MxText(
                l10n.flashcardsEmptyMessage,
                role: MxTextRole.bodyMedium,
                color: scheme.onSurfaceVariant,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: SpacingTokens.lg),
        MxActionButton(
          intent: MxActionIntent.emptyState,
          label: l10n.flashcardsEmptyAddFirstAction,
          icon: Icons.add,
          fullWidth: true,
          onPressed: onAddCard,
        ),
        const SizedBox(height: SpacingTokens.sm),
        MxSecondaryButton(
          label: l10n.flashcardsEmptyImportAction,
          icon: Icons.file_upload_outlined,
          onPressed: onImport,
          variant: MxSecondaryVariant.tonal,
          size: MxButtonSize.medium,
          fullWidth: true,
        ),
      ],
    );
  }
}
