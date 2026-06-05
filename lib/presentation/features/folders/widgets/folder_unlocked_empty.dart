import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// Empty state for an `unlocked` folder — the mode-choice flow
/// (`docs/wireframes/05-folder-detail.md` §unlocked). Picking one locks the
/// folder to that mode (enforced by the use case). Both choices are offered
/// because neither is yet committed.
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
    final ColorScheme scheme = context.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: SizeTokens.iconXl - 12,
              height: SizeTokens.iconXl - 12,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: OpacityTokens.hover),
                borderRadius: RadiusTokens.brLg,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.folder_open_outlined,
                size: SizeTokens.iconMd + 2,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            MxText(l10n.folderUnlockedTitle, role: MxTextRole.titleMedium),
            const SizedBox(height: SpacingTokens.xs),
            MxText(
              l10n.folderUnlockedMessage,
              role: MxTextRole.bodyMedium,
              color: scheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxPrimaryButton(
              label: l10n.folderNewSubfolderLabel,
              icon: Icons.create_new_folder_outlined,
              onPressed: onNewSubfolder,
              fullWidth: true,
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxSecondaryButton(
              label: l10n.folderNewDeckLabel,
              icon: Icons.add,
              onPressed: onNewDeck,
              fullWidth: true,
            ),
            const SizedBox(height: SpacingTokens.lg),
            MxText(
              l10n.folderModeLockHint,
              role: MxTextRole.labelMedium,
              color: scheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
