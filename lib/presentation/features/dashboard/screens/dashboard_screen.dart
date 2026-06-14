import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_screen_body.dart';
import 'package:memox/presentation/features/dashboard/widgets/dashboard_screen_skeletons.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MaterialLocalizations material = MaterialLocalizations.of(context);

    return MxScaffold(
      appBar: MxAppBar(
        title: DashboardAppBarTitle(
          title: l10n.dashboardGreetingTitle,
          subtitle: material.formatFullDate(DateTime.now()),
        ),
        actions: <Widget>[
          MxIconButton(
            icon: Icons.search_rounded,
            tooltip: l10n.dashboardSearchTooltip,
            onPressed: () => context.pushLibrarySearch(),
          ),
          MxIconButton(
            icon: Icons.settings_outlined,
            tooltip: l10n.settingsTitle,
            onPressed: () => context.goSettings(),
          ),
        ],
      ),
      body: MxRetainedAsyncState<LibraryOverviewReadModel>(
        value: ref.watch(libraryOverviewQueryProvider),
        skeletonBuilder: (_) => const DashboardLoadingState(),
        errorBuilder: (Object error, StackTrace? stackTrace) => MxErrorState(
          title: l10n.sharedErrorTitle,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(libraryOverviewQueryProvider),
        ),
        data: (LibraryOverviewReadModel model) => DashboardBody(model: model),
      ),
    );
  }
}
