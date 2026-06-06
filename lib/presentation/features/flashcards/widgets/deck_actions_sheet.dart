import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

/// A deck-level overflow action on the Flashcard List
/// (`docs/wireframes/06-flashcard-list.md` §overflow). V1 exposes only the
/// implemented actions — Import (route), Reorder cards, Delete deck. Edit / Move
/// / Export / Select are Future and intentionally not surfaced.
enum DeckListAction { importFlashcards, reorder, delete }

/// Opens the deck overflow sheet and resolves to the chosen [DeckListAction],
/// or `null` when dismissed. The sheet only renders prepared view data and
/// returns the choice; the caller owns the navigation/dialog each action drives.
Future<DeckListAction?> showDeckActions(
  BuildContext context, {
  required String deckName,
  required String subtitle,
}) => showMxBottomSheet<DeckListAction>(
  context,
  builder: (BuildContext context) =>
      _DeckActionsSheet(deckName: deckName, subtitle: subtitle),
);

class _DeckActionsSheet extends StatelessWidget {
  const _DeckActionsSheet({required this.deckName, required this.subtitle});

  final String deckName;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = context.colorScheme;
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.xs,
              SpacingTokens.lg,
              SpacingTokens.sm,
            ),
            child: Row(
              children: <Widget>[
                const MxIconTile(icon: Icons.layers_rounded, size: 40),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      MxText(
                        deckName,
                        role: MxTextRole.titleSmall,
                        fontWeight: TypographyTokens.bold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: SpacingTokens.xxs),
                      MxText(
                        subtitle,
                        role: MxTextRole.labelMedium,
                        color: scheme.onSurfaceVariant,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _ActionRow(
            icon: Icons.file_download_outlined,
            label: l10n.libraryFolderActionsImport,
            onTap: () =>
                Navigator.of(context).pop(DeckListAction.importFlashcards),
          ),
          _ActionRow(
            icon: Icons.swap_vert,
            label: l10n.flashcardDeckReorderAction,
            onTap: () => Navigator.of(context).pop(DeckListAction.reorder),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.sm,
            ),
            child: ColoredBox(
              color: scheme.outlineVariant,
              child: const SizedBox(height: 1, width: double.infinity),
            ),
          ),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.decksDeleteTitle,
            destructive: true,
            onTap: () => Navigator.of(context).pop(DeckListAction.delete),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    final Color tint = destructive ? scheme.error : scheme.primary;
    final Color labelColor = destructive ? scheme.error : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: MxTappable(
        onTap: onTap,
        borderRadius: RadiusTokens.brSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.lg,
            vertical: SpacingTokens.md,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: SizeTokens.iconLg,
                height: SizeTokens.iconLg,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: OpacityTokens.hover),
                  borderRadius: RadiusTokens.brSm,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: SizeTokens.iconXs, color: tint),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: MxText(
                  label,
                  role: MxTextRole.bodyLarge,
                  color: labelColor,
                  fontWeight: TypographyTokens.medium,
                ),
              ),
              if (!destructive)
                Icon(
                  Icons.chevron_right,
                  size: SizeTokens.iconSm,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
