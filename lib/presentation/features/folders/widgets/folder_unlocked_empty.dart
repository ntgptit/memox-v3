import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Empty state for an `unlocked` folder — the mode-choice flow.
///
/// The canonical mock renders a small "empty folder" chip, an explanatory
/// card, two side-by-side creation choices, and a tokenized info banner.
class FolderUnlockedEmpty extends StatelessWidget {
  const FolderUnlockedEmpty({
    required this.onNewSubfolder,
    required this.onNewDeck,
    super.key,
  });

  final VoidCallback onNewSubfolder;
  final VoidCallback onNewDeck;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.screenPadding,
        SpacingTokens.sm,
        SpacingTokens.screenPadding,
        SpacingTokens.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _EmptyChip(label: l10n.folderDetailEmptyFolderChipLabel),
          const SizedBox(height: SpacingTokens.sm),
          _IntroCard(
            title: l10n.folderDetailEmptyTitle,
            message: l10n.folderDetailEmptyMessage,
          ),
          const SizedBox(height: SpacingTokens.md),
          _ActionRow(
            onNewDeck: onNewDeck,
            onNewSubfolder: onNewSubfolder,
            deckLabel: l10n.folderNewDeckLabel,
            subfolderLabel: l10n.folderNewSubfolderLabel,
          ),
          const SizedBox(height: SpacingTokens.md),
          _HintCard(hint: l10n.folderDetailEmptyHint),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
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
              Icons.folder_open_outlined,
              size: SizeTokens.surfaceBadge,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          MxText(
            title,
            role: MxTextRole.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.xs),
          MxText(
            message,
            role: MxTextRole.bodyMedium,
            color: scheme.onSurfaceVariant,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onNewDeck,
    required this.onNewSubfolder,
    required this.deckLabel,
    required this.subfolderLabel,
  });

  final VoidCallback onNewDeck;
  final VoidCallback onNewSubfolder;
  final String deckLabel;
  final String subfolderLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Expanded(
        child: MxPrimaryButton(
          label: deckLabel,
          icon: Icons.layers_outlined,
          onPressed: onNewDeck,
          fullWidth: true,
        ),
      ),
      const SizedBox(width: SpacingTokens.sm),
      Expanded(
        child: MxSecondaryButton(
          label: subfolderLabel,
          icon: Icons.create_new_folder_outlined,
          onPressed: onNewSubfolder,
          fullWidth: true,
        ),
      ),
    ],
  );
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: SizeTokens.iconMinor,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: MxText(
              hint,
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChip extends StatelessWidget {
  const _EmptyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: OpacityTokens.hover),
        borderRadius: RadiusTokens.brFull,
      ),
      child: MxText(
        StringUtils.uppercased(label),
        role: MxTextRole.labelMedium,
        color: scheme.primary,
      ),
    );
  }
}
