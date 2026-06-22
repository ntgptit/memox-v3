import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/dialogs/mx_bottom_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';

/// An action chosen from the study-session card-actions sheet (long-press the
/// review card, wireframe `13` Actions / `25` §card-actions). Edit lands with
/// WP-SR4b-2 (it needs the card's deck id, which the review read model does not
/// yet carry).
enum StudyCardAction { buryUntilTomorrow, suspend }

/// Shows the study-session card-actions sheet — **Bury until tomorrow** /
/// **Suspend card** — and resolves to the chosen [StudyCardAction] or `null`
/// when dismissed. Reuses the shared `showMxBottomSheet` chrome. WBS 4.5.3.
Future<StudyCardAction?> showStudyCardActionsSheet(BuildContext context) =>
    showMxBottomSheet<StudyCardAction>(
      context,
      child: const _StudyCardActionsSheet(),
    );

class _StudyCardActionsSheet extends StatelessWidget {
  const _StudyCardActionsSheet();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ActionRow(
          icon: Icons.bedtime_outlined,
          label: l10n.studyActionBury,
          onTap: () =>
              Navigator.of(context).pop(StudyCardAction.buryUntilTomorrow),
        ),
        _ActionRow(
          icon: Icons.pause_circle_outlined,
          label: l10n.studyActionSuspend,
          onTap: () => Navigator.of(context).pop(StudyCardAction.suspend),
        ),
      ],
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
    final MxColors colors = context.mxColors;
    return MxTappable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        child: Row(
          children: <Widget>[
            Icon(icon, color: colors.textSecondary),
            const SizedBox(width: MxSpacing.space3),
            MxText(label, role: MxTextRole.bodyLarge),
          ],
        ),
      ),
    );
  }
}
