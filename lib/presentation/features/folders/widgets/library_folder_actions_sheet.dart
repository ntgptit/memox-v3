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

/// A folder-row overflow action (`docs/wireframes/02-library.md` §Overflow
/// sheet, `docs/wireframes/25-shared-bottom-sheets.md` §item-context).
enum LibraryFolderAction { rename, move, importFlashcards, delete }

/// Opens the Library folder action sheet for one folder row and resolves to the
/// chosen [LibraryFolderAction], or `null` when dismissed.
///
/// The sheet only renders prepared view data ([name] / [subtitle]) and returns
/// the user's choice; the caller owns the dialog/picker/navigation that each
/// action triggers. [showImport] hides "Import flashcards" for subfolder-mode
/// folders, which hold no decks to import into.
Future<LibraryFolderAction?> showLibraryFolderActions(
  BuildContext context, {
  required String name,
  required String subtitle,
  required bool showImport,
}) => showMxBottomSheet<LibraryFolderAction>(
  context,
  builder: (BuildContext context) => _LibraryFolderActions(
    name: name,
    subtitle: subtitle,
    showImport: showImport,
  ),
);

class _LibraryFolderActions extends StatelessWidget {
  const _LibraryFolderActions({
    required this.name,
    required this.subtitle,
    required this.showImport,
  });

  final String name;
  final String subtitle;
  final bool showImport;

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
                const MxIconTile(
                  icon: Icons.folder_rounded,
                  size: SizeTokens.controlMd,
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      MxText(
                        name,
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
            icon: Icons.drive_file_rename_outline,
            label: l10n.libraryFolderActionsRename,
            onTap: () => Navigator.of(context).pop(LibraryFolderAction.rename),
          ),
          _ActionRow(
            icon: Icons.drive_file_move_outline,
            label: l10n.libraryFolderActionsMove,
            onTap: () => Navigator.of(context).pop(LibraryFolderAction.move),
          ),
          if (showImport)
            _ActionRow(
              icon: Icons.file_download_outlined,
              label: l10n.libraryFolderActionsImport,
              onTap: () => Navigator.of(
                context,
              ).pop(LibraryFolderAction.importFlashcards),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.lg,
              vertical: SpacingTokens.sm,
            ),
            child: SizedBox(
              height: SpacingTokens.xxs,
              width: double.infinity,
              child: ColoredBox(color: scheme.outlineVariant),
            ),
          ),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.libraryFolderActionsDelete,
            destructive: true,
            onTap: () => Navigator.of(context).pop(LibraryFolderAction.delete),
          ),
          const SizedBox(height: SpacingTokens.sm),
        ],
      ),
    );
  }
}

/// One tappable action row: tinted leading glyph, label, trailing chevron.
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
