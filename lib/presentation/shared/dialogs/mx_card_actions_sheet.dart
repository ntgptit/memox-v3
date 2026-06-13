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

/// Study session card actions available from the long-press sheet.
enum MxStudySessionCardAction { edit, buryUntilTomorrow, suspend }

/// Opens the shared study-session card actions sheet.
Future<MxStudySessionCardAction?> showStudySessionCardActions(
  BuildContext context, {
  required String front,
}) => showMxBottomSheet<MxStudySessionCardAction>(
  context,
  builder: (BuildContext context) =>
      _StudySessionCardActionsSheet(front: front),
);

class _StudySessionCardActionsSheet extends StatelessWidget {
  const _StudySessionCardActionsSheet({required this.front});

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
            child: Row(
              children: <Widget>[
                const MxIconTile(
                  icon: Icons.more_horiz,
                  size: SizeTokens.controlMd,
                ),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: MxText(
                    front,
                    role: MxTextRole.titleSmall,
                    fontWeight: TypographyTokens.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _ActionRow(
            icon: Icons.edit_outlined,
            label: l10n.commonEdit,
            onTap: () =>
                Navigator.of(context).pop(MxStudySessionCardAction.edit),
          ),
          _ActionRow(
            icon: Icons.nightlight_outlined,
            label: l10n.studySessionBuryUntilTomorrowAction,
            onTap: () => Navigator.of(
              context,
            ).pop(MxStudySessionCardAction.buryUntilTomorrow),
          ),
          _ActionRow(
            icon: Icons.pause_circle_outline,
            label: l10n.studySessionSuspendAction,
            onTap: () =>
                Navigator.of(context).pop(MxStudySessionCardAction.suspend),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
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
                  color: scheme.primary.withValues(alpha: OpacityTokens.hover),
                  borderRadius: RadiusTokens.brSm,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: SizeTokens.iconXs,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: MxText(
                  label,
                  role: MxTextRole.bodyLarge,
                  color: scheme.onSurface,
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
