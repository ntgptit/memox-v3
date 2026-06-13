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

/// Card History overflow actions (`docs/wireframes/09-flashcard-history.md`
/// §App bar overflow). V1 exposes Edit / Reset progress / Delete. Suspend is
/// deferred with the Bury/Suspend feature (WBS 4.11.x).
enum CardHistoryAction { edit, resetProgress, delete }

Future<CardHistoryAction?> showCardHistoryActions(
  BuildContext context, {
  required String front,
}) => showMxBottomSheet<CardHistoryAction>(
  context,
  builder: (BuildContext context) => _CardHistoryActionsSheet(front: front),
);

class _CardHistoryActionsSheet extends StatelessWidget {
  const _CardHistoryActionsSheet({required this.front});

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
            onTap: () => Navigator.of(context).pop(CardHistoryAction.edit),
          ),
          _ActionRow(
            icon: Icons.restart_alt,
            label: l10n.cardHistoryResetAction,
            onTap: () =>
                Navigator.of(context).pop(CardHistoryAction.resetProgress),
          ),
          _ActionRow(
            icon: Icons.delete_outline,
            label: l10n.commonDelete,
            destructive: true,
            onTap: () => Navigator.of(context).pop(CardHistoryAction.delete),
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
            ],
          ),
        ),
      ),
    );
  }
}
