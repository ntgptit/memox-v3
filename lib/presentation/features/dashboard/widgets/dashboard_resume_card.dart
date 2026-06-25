import 'package:flutter/material.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/feedback/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// The Dashboard "Continue studying" card (kit `02 · continue-studying`): shown
/// only when a resumable session exists. A progress bar + answered/total + a
/// Resume action. Keyed `mx-node:02-dashboard/continue-studying`.
///
/// REFINEMENTS (kit elements not yet wired, no fabrication): the session's
/// deck/scope NAME needs scope→name resolution, and a Discard action needs an
/// abandon-session use case — both tracked in
/// `docs/business/engagement/dashboard-engagement.md`.
class DashboardResumeCard extends StatelessWidget {
  const DashboardResumeCard({
    required this.summary,
    required this.onResume,
    super.key,
  });

  final DashboardResumeSessionSummary summary;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MxColors colors = context.mxColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MxText(
          l10n.dashboardContinueTitle,
          role: MxTextRole.labelSmall,
          color: colors.textSecondary,
        ),
        const SizedBox(height: MxSpacing.space2),
        MxCard(
          key: const ValueKey<String>('mx-node:02-dashboard/continue-studying'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MxLinearProgress(value: summary.progress),
              const SizedBox(height: MxSpacing.space3),
              MxText(
                l10n.dashboardResumeProgress(
                  summary.answeredCount,
                  summary.totalCount,
                ),
                role: MxTextRole.bodySmall,
                color: colors.textSecondary,
              ),
              const SizedBox(height: MxSpacing.space4),
              SizedBox(
                width: double.infinity,
                child: MxSecondaryButton(
                  label: l10n.dashboardResumeAction,
                  icon: Icons.play_arrow_rounded,
                  onPressed: onResume,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
