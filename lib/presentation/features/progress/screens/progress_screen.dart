import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/opacity_tokens.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/progress_range.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/progress/viewmodels/progress_viewmodel.dart';
import 'package:memox/presentation/features/progress/widgets/progress_activity_sections.dart';
import 'package:memox/presentation/features/progress/widgets/progress_range_tabs.dart';
import 'package:memox/presentation/features/progress/widgets/progress_summary_sections.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Progress screen V1 (`docs/wireframes/03-progress.md`; mock
/// `shots/19-progress--*`, all 7 kit states).
///
/// Sections are data-driven, so the kit's Empty / Insufficient / Partial
/// variants fall out of the data instead of being separate screen states:
/// every section renders its own hint box when its slice of
/// [ProgressOverview] is empty, the bar chart requires
/// [kProgressTrendMinDays] distinct study days, and the accuracy delta needs
/// a non-empty previous range.
///
/// Mock elements that stay Future: the help (?) app-bar action (no help
/// content exists) and the Card-states chevrons (filtered flashcard list is
/// WBS 2.17.x).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // guard:allow-screen-watch -- reason: the body swaps between skeleton,
    // error, and data per the overview query, and both skeleton and body need
    // the selected range so the tabs stay live in every state.
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ProgressRange range = ref.watch(progressRangeControllerProvider);

    return MxScaffold(
      appBar: MxAppBar(titleText: l10n.progressTitle),
      body: MxRetainedAsyncState<ProgressOverview>(
        value: ref.watch(progressOverviewQueryProvider),
        skeletonBuilder: (_) => _ProgressLoadingState(range: range),
        errorBuilder: (Object error, StackTrace? stackTrace) => MxErrorState(
          icon: Icons.cloud_off_outlined,
          title: l10n.progressErrorTitle,
          message: l10n.progressErrorMessage,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(progressOverviewQueryProvider),
        ),
        data: (ProgressOverview overview) =>
            _ProgressBody(overview: overview, range: range),
      ),
    );
  }
}

class _ProgressBody extends ConsumerWidget {
  const _ProgressBody({required this.overview, required this.range});

  final ProgressOverview overview;
  final ProgressRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String footer = switch (range) {
      ProgressRange.week => l10n.progressFooterWeek,
      ProgressRange.month => l10n.progressFooterMonth,
      ProgressRange.allTime => l10n.progressFooterAllTime,
    };

    return ListView(
      children: <Widget>[
        const SizedBox(height: SpacingTokens.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: ProgressRangeTabs(
            selected: range,
            onSelect: (ProgressRange next) =>
                ref.read(progressRangeControllerProvider.notifier).select(next),
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        ProgressCardsStudiedCard(activity: overview.activity),
        const SizedBox(height: SpacingTokens.md),
        ProgressAccuracyCard(activity: overview.activity),
        const SizedBox(height: SpacingTokens.md),
        ProgressBoxDistributionCard(distribution: overview.boxDistribution),
        const SizedBox(height: SpacingTokens.md),
        ProgressStreakCard(streak: overview.streak),
        const SizedBox(height: SpacingTokens.lg),
        ProgressOverline(label: l10n.progressCardStatesTitle),
        const SizedBox(height: SpacingTokens.xs),
        ProgressCardStatesCard(counts: overview.cardStateCounts),
        const SizedBox(height: SpacingTokens.sm),
        MxText(
          footer,
          role: MxTextRole.bodySmall,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }
}

/// Loading state mirrors the mock: tabs stay visible, three skeleton cards
/// each with an overline bar, a number bar, and a chart block.
class _ProgressLoadingState extends ConsumerWidget {
  const _ProgressLoadingState({required this.range});

  final ProgressRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView(
    children: <Widget>[
      const SizedBox(height: SpacingTokens.sm),
      Align(
        alignment: Alignment.centerLeft,
        child: ProgressRangeTabs(
          selected: range,
          onSelect: (ProgressRange next) =>
              ref.read(progressRangeControllerProvider.notifier).select(next),
        ),
      ),
      const SizedBox(height: SpacingTokens.md),
      const _ProgressSectionSkeleton(),
      const SizedBox(height: SpacingTokens.md),
      const _ProgressSectionSkeleton(),
      const SizedBox(height: SpacingTokens.md),
      const _ProgressSectionSkeleton(),
      const SizedBox(height: SpacingTokens.xl),
    ],
  );
}

class _ProgressSectionSkeleton extends StatelessWidget {
  const _ProgressSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const FractionallySizedBox(
            widthFactor: 0.3,
            alignment: Alignment.centerLeft,
            child: MxSkeleton(height: SpacingTokens.sm),
          ),
          const SizedBox(height: SpacingTokens.sm),
          const FractionallySizedBox(
            widthFactor: 0.4,
            alignment: Alignment.centerLeft,
            child: MxSkeleton(height: SpacingTokens.lg),
          ),
          const SizedBox(height: SpacingTokens.md),
          Container(
            height: SizeTokens.chart,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh.withValues(
                alpha: OpacityTokens.hint,
              ),
              borderRadius: RadiusTokens.brSm,
            ),
          ),
        ],
      ),
    );
  }
}
