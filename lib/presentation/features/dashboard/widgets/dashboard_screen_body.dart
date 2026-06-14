import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';

import '../widgets/dashboard_screen_bottom_cards.dart';
import '../widgets/dashboard_screen_skeletons.dart';
import '../widgets/dashboard_screen_top_cards.dart';

class DashboardBody extends ConsumerWidget {
  const DashboardBody({required this.model, super.key});

  final LibraryOverviewReadModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (isZeroContent(model)) {
      return ListView(
        children: const <Widget>[
          SizedBox(height: SpacingTokens.md),
          DashboardOnboardingState(),
          SizedBox(height: SpacingTokens.xl),
        ],
      );
    }

    final AsyncValue<DashboardResumeSessionSummary?> resumeQuery = ref.watch(
      dashboardResumeSessionQueryProvider,
    );

    return ListView(
      children: <Widget>[
        const SizedBox(height: SpacingTokens.md),
        MxRetainedAsyncState<DashboardResumeSessionSummary?>(
          value: resumeQuery,
          skeletonBuilder: (_) => const DashboardResumeCardSkeleton(),
          errorBuilder: (Object error, StackTrace? stackTrace) => Padding(
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            child: MxErrorState(
              title: l10n.sharedErrorTitle,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(dashboardResumeSessionQueryProvider),
            ),
          ),
          data: (DashboardResumeSessionSummary? summary) => summary == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: DashboardResumeSection(summary: summary),
                ),
        ),
        const DashboardStatsRow(),
        const SizedBox(height: SpacingTokens.md),
        const DashboardTodayCard(),
        const SizedBox(height: SpacingTokens.md),
        const DashboardNewLearningCard(),
        const SizedBox(height: SpacingTokens.md),
        const DashboardRecentDecksSection(),
        const SizedBox(height: SpacingTokens.lg),
      ],
    );
  }
}

class DashboardAppBarTitle extends StatelessWidget {
  const DashboardAppBarTitle({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MxText(title, role: MxTextRole.headlineMedium, color: scheme.onSurface),
        const SizedBox(height: SpacingTokens.xs),
        MxText(
          subtitle,
          role: MxTextRole.bodySmall,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

bool isZeroContent(LibraryOverviewReadModel model) {
  final int deckCount = model.folders.fold<int>(
    0,
    (int sum, FolderWithCount item) => sum + item.deckCount,
  );
  final int cardCount = model.folders.fold<int>(
    0,
    (int sum, FolderWithCount item) => sum + item.cardCount,
  );
  return deckCount == 0 && cardCount == 0;
}
