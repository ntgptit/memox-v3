import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/domain/models/dashboard_summary.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_due_summary.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_shortcut_row.dart';

/// The Dashboard body (design redesign): a quiet "refer to work" surface — a
/// due snapshot (`MxDueSummary`) plus shortcut rows to Progress and the Library.
/// Daily goal + streak live on Progress, not here; there are no strong study
/// CTAs on the Dashboard. Owns the summary watch so the screen shell stays
/// watch-free. WBS 5.x.
class DashboardBody extends ConsumerWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<DashboardSummary>> async = ref.watch(
      dashboardSummaryProvider,
    );

    return AppAsyncBuilder<Result<DashboardSummary>>(
      value: async,
      loading: (_) => const MxLoadingState(),
      data: (Result<DashboardSummary> result) {
        final DashboardSummary? summary = result.data;
        if (summary == null) {
          return MxErrorState(
            icon: Icons.cloud_off_outlined,
            title: l10n.dashboardLoadFailedTitle,
            message: l10n.dashboardLoadFailedMessage,
            action: MxPrimaryButton(
              label: l10n.commonRetryLabel,
              icon: Icons.refresh,
              onPressed: () => ref.invalidate(dashboardSummaryProvider),
            ),
          );
        }
        return _content(context, l10n, summary);
      },
    );
  }

  Widget _content(
    BuildContext context,
    AppLocalizations l10n,
    DashboardSummary summary,
  ) => ListView(
    padding: const EdgeInsets.all(MxSpacing.screen),
    children: <Widget>[
      MxDueSummary(
        caughtUp: summary.caughtUp,
        title: summary.caughtUp
            ? l10n.dashboardCaughtUpTitle
            : l10n.dashboardCardsDue(summary.cardsDue),
        subtitle: summary.caughtUp
            ? l10n.dashboardCaughtUpMessage
            : l10n.dashboardDecksWithDue(summary.decksWithDue),
      ),
      const SizedBox(height: MxSpacing.gapSection),
      MxShortcutRow(
        icon: Icons.insights_outlined,
        label: l10n.progressTitle,
        subtitle: l10n.dashboardProgressShortcutSub,
        onTap: () => context.goNamed(RouteNames.progress),
      ),
      const SizedBox(height: MxSpacing.space3),
      MxShortcutRow(
        icon: Icons.folder_outlined,
        label: l10n.libraryTitle,
        subtitle: l10n.dashboardLibraryShortcutSub,
        onTap: () => context.goNamed(RouteNames.library),
      ),
    ],
  );
}
