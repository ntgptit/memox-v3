import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/status/mx_stat_display.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MxScaffold(
      appBar: MxAppBar(
        title: _DashboardAppBarTitle(
          title: l10n.dashboardGreetingTitle,
          subtitle: l10n.dashboardGreetingSubtitle,
        ),
        actions: <Widget>[
          MxIconButton(
            icon: Icons.settings_outlined,
            tooltip: l10n.settingsTitle,
            onPressed: () => context.goSettings(),
          ),
        ],
      ),
      body: MxRetainedAsyncState<LibraryOverviewReadModel>(
        value: ref.watch(libraryOverviewQueryProvider),
        skeletonBuilder: (_) => const _DashboardLoadingState(),
        errorBuilder: (Object error, StackTrace? stackTrace) => MxErrorState(
          title: l10n.sharedErrorTitle,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(libraryOverviewQueryProvider),
        ),
        data: (LibraryOverviewReadModel model) => _DashboardBody(model: model),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.model});

  final LibraryOverviewReadModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool zeroContent = _isZeroContent(model);
    final AsyncValue<DashboardResumeSessionSummary?> resumeQuery = ref.watch(
      dashboardResumeSessionQueryProvider,
    );

    return ListView(
      children: <Widget>[
        const SizedBox(height: SpacingTokens.md),
        MxRetainedAsyncState<DashboardResumeSessionSummary?>(
          value: resumeQuery,
          skeletonBuilder: (_) => const _DashboardResumeCardSkeleton(),
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
                  child: _DashboardResumeCard(summary: summary),
                ),
        ),
        if (zeroContent) ...<Widget>[
          const _DashboardOnboardingState(),
        ] else ...<Widget>[
          const _DashboardStreakPlaceholder(),
          const SizedBox(height: SpacingTokens.md),
          _DashboardTodayCard(dueToday: model.dueToday),
        ],
        const SizedBox(height: SpacingTokens.xl),
      ],
    );
  }
}

class _DashboardAppBarTitle extends StatelessWidget {
  const _DashboardAppBarTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MxText(
          title,
          role: MxTextRole.titleMedium,
          color: scheme.onSurface,
        ),
        const SizedBox(height: SpacingTokens.xxs),
        MxText(
          subtitle,
          role: MxTextRole.bodySmall,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

class _DashboardResumeCard extends ConsumerWidget {
  const _DashboardResumeCard({required this.summary});

  final DashboardResumeSessionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime now = DateTime.now();
    final double progress = summary.totalCount == 0
        ? 0
        : (summary.answeredCount / summary.totalCount).clamp(0, 1).toDouble();
    final String scopeLabel = _scopeLabel(l10n, summary);
    final String progressLabel = l10n.studySessionProgressLabel(
      summary.answeredCount,
      summary.totalCount,
    );
    final RelativeTime relativeTime = RelativeTime.between(
      summary.session.updatedAt,
      now,
    );
    final String relativeLabel = l10n.relativeTimeAgo(
      relativeTime.unit.name,
      relativeTime.count,
    );

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MxIconTile(icon: Icons.play_arrow_rounded),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MxText(
                      l10n.dashboardResumeSectionTitle,
                      role: MxTextRole.labelLarge,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      scopeLabel,
                      role: MxTextRole.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      '$progressLabel · $relativeLabel',
                      role: MxTextRole.bodySmall,
                      color: context.colorScheme.onSurfaceVariant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          MxLinearProgress(value: progress, height: SpacingTokens.xs),
          const SizedBox(height: SpacingTokens.lg),
          MxCardActions(
            secondary: MxActionButton(
              intent: MxActionIntent.cardSecondary,
              label: l10n.dashboardDiscardAction,
              onPressed: () =>
                  _discardSession(ref, context, summary.session.id),
            ),
            primary: MxActionButton(
              intent: MxActionIntent.cardPrimary,
              label: l10n.dashboardContinueSessionAction,
              onPressed: () => context.pushStudySession(summary.session.id),
            ),
          ),
        ],
      ),
    );
  }

  String _scopeLabel(AppLocalizations l10n, DashboardResumeSessionSummary s) {
    if (s.scopeLabel != null && StringUtils.trimmed(s.scopeLabel!).isNotEmpty) {
      return s.scopeLabel!;
    }
    return switch (s.session.entryType) {
      EntryType.deck => l10n.progressEntryDeck,
      EntryType.folder => l10n.progressEntryFolder,
      EntryType.today => l10n.dashboardTodayReviewTitle,
    };
  }

  Future<void> _discardSession(
    WidgetRef ref,
    BuildContext context,
    String sessionId,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.dashboardDiscardSessionTitle,
      message: l10n.dashboardDiscardSessionMessage,
      confirmLabel: l10n.dashboardDiscardAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    if (!context.mounted) {
      return;
    }

    final Result<void> result = await ref
        .read(dashboardProvider.notifier)
        .discardSession(sessionId);
    if (!context.mounted) {
      return;
    }
    result.fold(
      (_) => showMxSnackbar(
        context,
        message: l10n.dashboardSessionDiscardFailedMessage,
        isError: true,
      ),
      (void _) {
        showMxSnackbar(context, message: l10n.dashboardSessionDiscardedMessage);
        ref.invalidate(dashboardResumeSessionQueryProvider);
      },
    );
  }
}

class _DashboardTodayCard extends StatelessWidget {
  const _DashboardTodayCard({required this.dueToday});

  final int dueToday;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasDueCards = dueToday > 0;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MxIconTile(icon: Icons.today_outlined),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MxText(
                      hasDueCards
                          ? l10n.dashboardDueTodayTitle
                          : l10n.dashboardNoDueTitle,
                      role: MxTextRole.titleSmall,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      hasDueCards
                          ? l10n.dashboardDueTodayMessage(dueToday)
                          : l10n.dashboardNoDueMessage,
                      role: MxTextRole.bodySmall,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.lg),
          MxCardActions(
            secondary: hasDueCards
                ? null
                : MxActionButton(
                    intent: MxActionIntent.cardSecondary,
                    label: l10n.dashboardOpenLibraryAction,
                    onPressed: () => context.goLibrary(),
                  ),
            primary: MxActionButton(
              intent: MxActionIntent.cardPrimary,
              label: l10n.dashboardStudyTodayAction,
              onPressed: () => context.goStudyEntry(entryType: EntryType.today),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStreakPlaceholder extends StatelessWidget {
  const _DashboardStreakPlaceholder();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxCard(
      child: Row(
        children: <Widget>[
          const MxIconTile(icon: Icons.local_fire_department_outlined),
          const SizedBox(width: SpacingTokens.md),
          MxStatDisplay(
            value: l10n.dashboardStreakDays(0),
            caption: l10n.sharedStreakLabel,
            alignment: CrossAxisAlignment.start,
          ),
        ],
      ),
    );
  }
}

class _DashboardOnboardingState extends StatelessWidget {
  const _DashboardOnboardingState();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.sm),
      child: MxEmptyState(
        icon: Icons.library_add_outlined,
        title: l10n.dashboardNewStudyTitle,
        message: l10n.dashboardNewStudyEmptyMessage,
        actionLabel: l10n.dashboardOpenLibraryAction,
        onAction: () => context.goLibrary(),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        SizedBox(height: SpacingTokens.md),
        _DashboardResumeCardSkeleton(),
        SizedBox(height: SpacingTokens.md),
        _DashboardSectionSkeleton(),
        SizedBox(height: SpacingTokens.md),
        _DashboardSectionSkeleton(),
        SizedBox(height: SpacingTokens.xl),
      ],
    );
  }
}

class _DashboardResumeCardSkeleton extends StatelessWidget {
  const _DashboardResumeCardSkeleton();

  @override
  Widget build(BuildContext context) =>
      const MxCard(child: _DashboardSkeletonBlock(lines: 3, hasActions: true));
}

class _DashboardSectionSkeleton extends StatelessWidget {
  const _DashboardSectionSkeleton();

  @override
  Widget build(BuildContext context) =>
      const MxCard(child: _DashboardSkeletonBlock(lines: 2, hasActions: true));
}

class _DashboardSkeletonBlock extends StatelessWidget {
  const _DashboardSkeletonBlock({
    required this.lines,
    required this.hasActions,
  });

  final int lines;
  final bool hasActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const MxSkeleton(width: SizeTokens.avatar, height: SizeTokens.avatar),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  for (int index = 0; index < lines; index++) ...<Widget>[
                    FractionallySizedBox(
                      widthFactor: index == 0 ? 0.8 : 0.55,
                      alignment: Alignment.centerLeft,
                      child: const MxSkeleton(height: 12),
                    ),
                    if (index != lines - 1)
                      const SizedBox(height: SpacingTokens.xs),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (hasActions) ...<Widget>[
          const SizedBox(height: SpacingTokens.lg),
          const Align(
            alignment: Alignment.centerRight,
            child: MxSkeleton(width: 168, height: 40),
          ),
        ],
      ],
    );
  }
}

bool _isZeroContent(LibraryOverviewReadModel model) {
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
