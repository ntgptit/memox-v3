import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/utils/relative_time.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/dashboard_progress_summary.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/status/mx_mastery_ring.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';

import '../widgets/dashboard_screen_bottom_cards.dart';

int estimatedReviewMinutes(int dueCount) {
  if (dueCount <= 0) {
    return 0;
  }
  final int minutes = (dueCount * 36 / 60).round();
  return minutes < 1 ? 1 : minutes;
}

int dueDeckCount(ProgressDueSummary summary) =>
    summary.decks.where((DeckDueSummary deck) => deck.dueCount > 0).length;

class DashboardResumeSection extends StatelessWidget {
  const DashboardResumeSection({required this.summary, super.key});

  final DashboardResumeSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        DashboardOverlineLabel(
          label: l10n.dashboardResumeSectionTitle,
          accent: context.customColors.streak,
        ),
        const SizedBox(height: SpacingTokens.sm),
        DashboardResumeCard(summary: summary),
      ],
    );
  }
}

class DashboardResumeCard extends ConsumerWidget {
  const DashboardResumeCard({required this.summary, super.key});

  final DashboardResumeSessionSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DashboardVisualChrome chrome = ref.watch(
      dashboardVisualChromeProvider,
    );
    final DateTime now = DateTime.now();
    final double progress = summary.totalCount == 0
        ? 0
        : (summary.answeredCount / summary.totalCount).clamp(0, 1).toDouble();
    final String scopeLabel = scopeLabelFor(l10n, summary);
    final RelativeTime relativeTime = RelativeTime.between(
      summary.session.updatedAt,
      now,
    );
    final String relativeLabel = l10n.relativeTimeAgo(
      relativeTime.unit.name,
      relativeTime.count,
    );
    final String metaLabel = l10n.dashboardResumeMeta(
      summary.answeredCount,
      summary.totalCount,
      relativeLabel,
    );

    return MxCard(
      padding: const EdgeInsets.all(SpacingTokens.form),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MxIconTile(
                icon: Icons.pause_rounded,
                color: context.customColors.streak,
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MxText(
                      scopeLabel,
                      role: MxTextRole.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpacingTokens.xxs),
                    MxText(
                      metaLabel,
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
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                child: MxActionButton(
                  intent: MxActionIntent.cardPrimary,
                  label: l10n.dashboardContinueSessionAction,
                  onPressed: () => context.pushStudySession(summary.session.id),
                  icon: Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Flexible(
                fit: FlexFit.loose,
                child: MxActionButton(
                  intent: MxActionIntent.cardSecondary,
                  label: l10n.dashboardDiscardAction,
                  onPressed: () => discard(context, ref),
                  icon: Icons.delete_outline_rounded,
                ),
              ),
            ],
          ),
          if (chrome.pausedSessionCount > 1) ...<Widget>[
            const SizedBox(height: SpacingTokens.sm),
            DashboardPausedSessionsChip(count: chrome.pausedSessionCount),
          ],
        ],
      ),
    );
  }

  Future<void> discard(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed = await showMxConfirmDialog(
      context,
      title: l10n.dashboardDiscardConfirmTitle,
      message: l10n.dashboardDiscardConfirmMessage,
      confirmLabel: l10n.dashboardDiscardAction,
      cancelLabel: l10n.commonCancel,
      destructive: true,
    );
    if (!confirmed) {
      return;
    }
    final Result<void> result = await ref
        .read(cancelStudySessionUseCaseProvider)
        .call(sessionId: summary.session.id);
    if (result is Ok<void>) {
      ref.invalidate(dashboardResumeSessionQueryProvider);
    }
  }
}

class DashboardStatsRow extends ConsumerWidget {
  const DashboardStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardProgressSummary> query = ref.watch(
      dashboardProgressSummaryQueryProvider,
    );
    return MxRetainedAsyncState<DashboardProgressSummary>(
      value: query,
      skeletonBuilder: (_) => const SizedBox.shrink(),
      errorBuilder: (Object error, StackTrace? stackTrace) =>
          const SizedBox.shrink(),
      data: (DashboardProgressSummary summary) {
        final Widget? streak = streakCard(context, summary.streak);
        final Widget? goal = goalCard(context, summary.goal);
        if (streak == null && goal == null) {
          return const SizedBox.shrink();
        }
        if (streak != null && goal != null) {
          return Row(
            children: <Widget>[
              Expanded(child: streak),
              const SizedBox(width: SpacingTokens.md),
              Expanded(child: goal),
            ],
          );
        }
        return streak ?? goal ?? const SizedBox.shrink();
      },
    );
  }

  Widget? streakCard(BuildContext context, DashboardStreakSummary streak) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (streak) {
      DashboardStreakSummaryKnown(:final currentStreak)
          when currentStreak >= 1 =>
        DashboardStatTile(
          leading: MxIconTile(
            icon: Icons.local_fire_department,
            color: context.customColors.streak,
            size: SizeTokens.surfaceTileSm,
          ),
          value: '$currentStreak',
          suffix: _suffixAfterNumber(l10n.dashboardStreakDays(currentStreak)),
          caption: l10n.sharedStreakLabel,
        ),
      _ => null,
    };
  }

  Widget? goalCard(BuildContext context, DashboardGoalSummary goal) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (goal) {
      DashboardGoalSummaryEnabled(:final dailyGoal, :final todayAttemptCount) =>
        DashboardStatTile(
          leading: MxMasteryRing(
            pct: dailyGoal == 0 ? 0 : todayAttemptCount / dailyGoal,
            size: SizeTokens.surfaceTileSm,
            showLabel: false,
          ),
          value: '$todayAttemptCount',
          suffix: '/$dailyGoal',
          caption: l10n.dashboardTodayGoalLabel,
        ),
      DashboardGoalSummaryDisabled(
        :final dailyGoal,
        :final todayAttemptCount,
      ) =>
        DashboardStatTile(
          leading: MxMasteryRing(
            pct: dailyGoal == 0 ? 0 : todayAttemptCount / dailyGoal,
            size: SizeTokens.surfaceTileSm,
            showLabel: false,
          ),
          value: '$todayAttemptCount',
          suffix: '/$dailyGoal',
          caption: l10n.dashboardTodayGoalLabel,
        ),
      _ => null,
    };
  }
}

class DashboardStatTile extends StatelessWidget {
  const DashboardStatTile({
    required this.leading,
    required this.value,
    this.suffix,
    required this.caption,
    super.key,
  });

  final Widget leading;
  final String value;
  final String? suffix;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.form,
        vertical: SpacingTokens.md,
      ),
      child: Row(
        children: <Widget>[
          leading,
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    MxText(
                      value,
                      role: MxTextRole.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (suffix != null && suffix!.isNotEmpty) ...<Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: SpacingTokens.xxs,
                        ),
                        child: MxText(
                          suffix!,
                          role: MxTextRole.labelSmall,
                          color: scheme.onSurfaceVariant,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                MxText(
                  StringUtils.uppercased(caption),
                  role: MxTextRole.labelSmall,
                  color: scheme.onSurfaceVariant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardTodayCard extends ConsumerWidget {
  const DashboardTodayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ProgressDueSummary> query = ref.watch(
      dashboardDueSummaryQueryProvider,
    );
    return MxRetainedAsyncState<ProgressDueSummary>(
      value: query,
      skeletonBuilder: (_) => const SizedBox.shrink(),
      errorBuilder: (Object error, StackTrace? stackTrace) => MxErrorState(
        title: l10n.sharedErrorTitle,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(dashboardDueSummaryQueryProvider),
      ),
      data: (ProgressDueSummary summary) =>
          DashboardTodayCardBody(summary: summary),
    );
  }
}

class DashboardTodayCardBody extends StatelessWidget {
  const DashboardTodayCardBody({required this.summary, super.key});

  final ProgressDueSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int dueToday = summary.totalDueCount;
    final bool hasDueCards = dueToday > 0;

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (hasDueCards) ...<Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.bolt_rounded,
                  size: SizeTokens.iconSm,
                  color: context.customColors.accent,
                ),
                const SizedBox(width: SpacingTokens.xs),
                MxText(
                  StringUtils.uppercased(l10n.dashboardTodayReviewOverline),
                  role: MxTextRole.labelLarge,
                  color: context.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            MxText(
              l10n.dashboardDueCountTitle(dueToday),
              role: MxTextRole.titleLarge,
            ),
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              l10n.dashboardReviewScopeMeta(
                dueDeckCount(summary),
                estimatedReviewMinutes(dueToday),
              ),
              role: MxTextRole.bodySmall,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: MxActionButton(
                    intent: MxActionIntent.cardPrimary,
                    label: l10n.dashboardStartReviewAction,
                    onPressed: () =>
                        context.goStudyEntry(entryType: EntryType.today),
                    icon: Icons.play_arrow_rounded,
                  ),
                ),
              ],
            ),
          ] else ...<Widget>[
            Align(
              alignment: Alignment.center,
              child: MxIconTile(
                icon: Icons.check_circle_outline_rounded,
                color: context.customColors.mastery,
                size: SizeTokens.avatar,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            MxText(
              l10n.dashboardNoDueTitle,
              role: MxTextRole.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.xxs),
            MxText(
              l10n.dashboardNoDueMessage,
              role: MxTextRole.bodySmall,
              color: context.colorScheme.onSurfaceVariant,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

String _suffixAfterNumber(String value) =>
    value.replaceFirst(RegExp(r'^\d+\s*'), '');

String scopeLabelFor(AppLocalizations l10n, DashboardResumeSessionSummary s) {
  if (s.scopeLabel != null && StringUtils.trimmed(s.scopeLabel!).isNotEmpty) {
    return s.scopeLabel!;
  }
  return switch (s.session.entryType) {
    EntryType.deck => l10n.progressEntryDeck,
    EntryType.folder => l10n.progressEntryFolder,
    EntryType.today => l10n.dashboardTodayReviewOverline,
  };
}
