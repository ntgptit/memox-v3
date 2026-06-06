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

/// A single-card row action (`docs/wireframes/06-flashcard-list.md` §row
/// actions). V1 exposes Edit (route) + Delete (confirm). Move / Export / Select
/// are Future and intentionally not surfaced.
enum FlashcardRowAction { edit, delete }

/// Opens the card-row action sheet and resolves to the chosen
/// [FlashcardRowAction], or `null` when dismissed.
Future<FlashcardRowAction?> showFlashcardRowActions(
  BuildContext context, {
  required String front,
}) => showMxBottomSheet<FlashcardRowAction>(
  context,
  builder: (BuildContext context) => _FlashcardRowActionsSheet(front: front),
);

class _FlashcardRowActionsSheet extends StatelessWidget {
  const _FlashcardRowActionsSheet({required this.front});

  final String front;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.md,
              SpacingTokens.lg,
              SpacingTokens.sm,
            ),
            child: MxText(
              front,
              role: MxTextRole.titleSmall,
              fontWeight: TypographyTokens.bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _ActionRow(
            icon: Icons.edit_outlined,
            label: l10n.commonEdit,
            onTap: () => Navigator.of(context).pop(FlashcardRowAction.edit),
          ),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.commonDelete,
            destructive: true,
            onTap: () => Navigator.of(context).pop(FlashcardRowAction.delete),
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
    return MxTappable(
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
          ],
        ),
      ),
    );
  }
}
