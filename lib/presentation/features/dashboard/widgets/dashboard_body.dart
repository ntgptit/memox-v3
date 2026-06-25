import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/dashboard_engagement.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_recent_decks.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_resume_card.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_stat_strip.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_due_summary.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_shortcut_row.dart';

/// The Dashboard body (engagement; WBS 5.x — restored 2026-06-25 by owner ruling):
/// a stat strip + the optional continue-studying card + a due snapshot + recent
/// decks + a shortcut into Stats. Owns the engagement watch so the screen shell
/// stays watch-free.
class DashboardBody extends ConsumerWidget {
  const DashboardBody({this.now, super.key});

  /// Reference time for relative labels (injected by tests/goldens for
  /// determinism). Defaults to `DateTime.now()` inside the widgets.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<DashboardEngagement>> async = ref.watch(
      dashboardEngagementProvider,
    );

    return AppAsyncBuilder<Result<DashboardEngagement>>(
      value: async,
      loading: (_) => const MxLoadingState(),
      data: (Result<DashboardEngagement> result) {
        final DashboardEngagement? data = result.data;
        if (data == null) {
          return MxErrorState(
            icon: Icons.cloud_off_outlined,
            title: l10n.dashboardLoadFailedTitle,
            message: l10n.dashboardLoadFailedMessage,
            action: MxPrimaryButton(
              label: l10n.commonRetryLabel,
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(dashboardEngagementProvider),
            ),
          );
        }
        return _content(context, ref, l10n, data);
      },
    );
  }

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DashboardEngagement data,
  ) {
    final resume = data.resume;
    return ListView(
      padding: const EdgeInsets.all(MxSpacing.screen),
      children: <Widget>[
        DashboardStatStrip(
          cardsDue: data.cardsDue,
          totalDecks: data.totalDecks,
          accuracyPercent: data.accuracyPercent,
          currentStreak: data.currentStreak,
        ),
        if (resume != null) ...<Widget>[
          const SizedBox(height: MxSpacing.gapSection),
          DashboardResumeCard(
            summary: resume,
            onResume: () => context.goNamed(RouteNames.studyToday),
          ),
        ],
        const SizedBox(height: MxSpacing.gapSection),
        MxDueSummary(
          key: const ValueKey<String>('mx-node:02-dashboard/due-summary'),
          caughtUp: data.caughtUp,
          title: data.caughtUp
              ? l10n.dashboardCaughtUpTitle
              : l10n.dashboardCardsDue(data.cardsDue),
          subtitle: data.caughtUp
              ? l10n.dashboardCaughtUpMessage
              : l10n.dashboardDecksWithDue(data.decksWithDue),
          actionLabel: data.caughtUp ? null : l10n.dashboardReviewAction,
          onAction: data.caughtUp
              ? null
              : () => context.goNamed(RouteNames.studyToday),
        ),
        if (data.recentDecks.isNotEmpty) ...<Widget>[
          const SizedBox(height: MxSpacing.gapSection),
          DashboardRecentDecks(
            decks: data.recentDecks,
            now: now,
            onDeckTap: (DeckId _) => context.goNamed(RouteNames.library),
            onSeeAll: () => context.goNamed(RouteNames.library),
          ),
        ],
        const SizedBox(height: MxSpacing.gapSection),
        MxShortcutRow(
          key: const ValueKey<String>('mx-node:02-dashboard/shortcut-progress'),
          icon: Icons.bar_chart_outlined,
          label: l10n.dashboardSeeStatsLabel,
          subtitle: l10n.dashboardProgressShortcutSub,
          onTap: () => context.goNamed(RouteNames.progress),
        ),
      ],
    );
  }
}
