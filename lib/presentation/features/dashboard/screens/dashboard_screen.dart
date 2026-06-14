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
import 'package:memox/domain/models/dashboard_deck_highlights.dart';
import 'package:memox/domain/models/dashboard_progress_summary.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/library_overview.dart';
import 'package:memox/domain/models/progress_read_model.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:memox/presentation/features/folders/viewmodels/library_overview_viewmodel.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_card_actions.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_skeleton.dart';
import 'package:memox/presentation/shared/widgets/status/mx_card_status.dart';
import 'package:memox/presentation/shared/widgets/status/mx_linear_progress.dart';
import 'package:memox/presentation/shared/widgets/status/mx_mastery_ring.dart';
import 'package:memox/presentation/shared/widgets/status/mx_status_badge.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_section_header.dart';

/// Estimated wall-clock seconds to review one due card. Used only for the
/// Today's-review "about X minutes" hint copy (`docs/wireframes/01-dashboard.md`
/// §Today's review). Not a scheduling input.
const int _kSecondsPerReviewCard = 36;

int _estimatedReviewMinutes(int dueCount) {
  if (dueCount <= 0) {
    return 0;
  }
  final int minutes = (dueCount * _kSecondsPerReviewCard / 60).round();
  return minutes < 1 ? 1 : minutes;
}

int _dueDeckCount(ProgressDueSummary summary) =>
    summary.decks.where((DeckDueSummary deck) => deck.dueCount > 0).length;

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MaterialLocalizations material = MaterialLocalizations.of(context);

    return MxScaffold(
      appBar: MxAppBar(
        title: _DashboardAppBarTitle(
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

    if (zeroContent) {
      return ListView(
        children: const <Widget>[
          SizedBox(height: SpacingTokens.md),
          _DashboardOnboardingState(),
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
                  child: _DashboardResumeSection(summary: summary),
                ),
        ),
        const _DashboardStatsRow(),
        const SizedBox(height: SpacingTokens.md),
        const _DashboardTodayCard(),
        const SizedBox(height: SpacingTokens.md),
        const _DashboardNewLearningCard(),
        const SizedBox(height: SpacingTokens.md),
        const _DashboardRecentDecksSection(),
        const SizedBox(height: SpacingTokens.lg),
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
        MxText(title, role: MxTextRole.headlineMedium, color: scheme.onSurface),
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

class _DashboardResumeSection extends StatelessWidget {
  const _DashboardResumeSection({required this.summary});

  final DashboardResumeSessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _DashboardOverlineLabel(
          label: l10n.dashboardResumeSectionTitle,
          accent: context.customColors.streak,
        ),
        const SizedBox(height: SpacingTokens.sm),
        _DashboardResumeCard(summary: summary),
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
          MxCardActions(
            primary: MxActionButton(
              intent: MxActionIntent.cardPrimary,
              label: l10n.dashboardContinueSessionAction,
              icon: Icons.play_arrow_rounded,
              onPressed: () => context.pushStudySession(summary.session.id),
            ),
            secondary: MxActionButton(
              intent: MxActionIntent.cardSecondary,
              label: l10n.dashboardDiscardAction,
              onPressed: () => _discard(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
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

  String _scopeLabel(AppLocalizations l10n, DashboardResumeSessionSummary s) {
    if (s.scopeLabel != null && StringUtils.trimmed(s.scopeLabel!).isNotEmpty) {
      return s.scopeLabel!;
    }
    return switch (s.session.entryType) {
      EntryType.deck => l10n.progressEntryDeck,
      EntryType.folder => l10n.progressEntryFolder,
      EntryType.today => l10n.dashboardTodayReviewOverline,
    };
  }
}

class _DashboardStatsRow extends ConsumerWidget {
  const _DashboardStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardProgressSummary> query = ref.watch(
      dashboardProgressSummaryQueryProvider,
    );
    return MxRetainedAsyncState<DashboardProgressSummary>(
      value: query,
      skeletonBuilder: (_) => const _DashboardStatsSkeleton(),
      errorBuilder: (Object error, StackTrace? stackTrace) =>
          const SizedBox.shrink(),
      data: (DashboardProgressSummary summary) {
        final Widget? streak = _streakCard(context, summary.streak);
        final Widget? goal = _goalCard(context, summary.goal);
        if (streak == null && goal == null) {
          return const SizedBox.shrink();
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (streak != null) Expanded(child: streak),
              if (streak != null && goal != null)
                const SizedBox(width: SpacingTokens.md),
              if (goal != null) Expanded(child: goal),
            ],
          ),
        );
      },
    );
  }

  Widget? _streakCard(BuildContext context, DashboardStreakSummary streak) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (streak) {
      DashboardStreakSummaryKnown(:final currentStreak)
          when currentStreak >= 1 =>
        _DashboardStatTile(
          leading: MxIconTile(
            icon: Icons.local_fire_department,
            color: context.customColors.streak,
            size: SizeTokens.iconLg,
          ),
          value: '$currentStreak',
          caption: l10n.sharedStreakLabel,
        ),
      _ => null,
    };
  }

  Widget? _goalCard(BuildContext context, DashboardGoalSummary goal) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (goal) {
      DashboardGoalSummaryEnabled(:final dailyGoal, :final todayAttemptCount) =>
        _DashboardStatTile(
          leading: MxMasteryRing(
            pct: dailyGoal == 0 ? 0 : todayAttemptCount / dailyGoal,
            size: SizeTokens.iconLg,
            showLabel: false,
          ),
          value: l10n.dashboardGoalProgress(todayAttemptCount, dailyGoal),
          caption: l10n.dashboardTodayGoalLabel,
        ),
      _ => null,
    };
  }
}

/// Compact stat tile (leading glyph/ring + a small metric + overline caption).
///
/// Deliberately lighter than [MxStatDisplay]'s 48px hero number so the paired
/// stats stay shallow on a phone (`docs/wireframes/01-dashboard.md` §stats row).
class _DashboardStatTile extends StatelessWidget {
  const _DashboardStatTile({
    required this.leading,
    required this.value,
    required this.caption,
  });

  final Widget leading;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = context.colorScheme;
    return MxCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: <Widget>[
          leading,
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  value,
                  role: MxTextRole.headlineMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _DashboardTodayCard extends ConsumerWidget {
  const _DashboardTodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ProgressDueSummary> query = ref.watch(
      dashboardDueSummaryQueryProvider,
    );
    return MxRetainedAsyncState<ProgressDueSummary>(
      value: query,
      skeletonBuilder: (_) => const _DashboardSectionSkeleton(),
      errorBuilder: (Object error, StackTrace? stackTrace) => MxErrorState(
        title: l10n.sharedErrorTitle,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(dashboardDueSummaryQueryProvider),
      ),
      data: (ProgressDueSummary summary) =>
          _DashboardTodayCardBody(summary: summary),
    );
  }
}

class _DashboardTodayCardBody extends StatelessWidget {
  const _DashboardTodayCardBody({required this.summary});

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
            hasDueCards
                ? l10n.dashboardDueCountTitle(dueToday)
                : l10n.dashboardNoDueTitle,
            role: MxTextRole.titleLarge,
          ),
          const SizedBox(height: SpacingTokens.xxs),
          MxText(
            hasDueCards
                ? l10n.dashboardReviewScopeMeta(
                    _dueDeckCount(summary),
                    _estimatedReviewMinutes(dueToday),
                  )
                : l10n.dashboardNoDueMessage,
            role: MxTextRole.bodySmall,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: SpacingTokens.md),
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
              label: l10n.dashboardStartReviewAction,
              icon: Icons.play_arrow_rounded,
              onPressed: hasDueCards
                  ? () => context.goStudyEntry(entryType: EntryType.today)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardNewLearningCard extends ConsumerWidget {
  const _DashboardNewLearningCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<DashboardDeckHighlights> query = ref.watch(
      dashboardDeckHighlightsQueryProvider,
    );
    final int newCardCount = query.maybeWhen(
      data: (DashboardDeckHighlights highlights) => highlights.newCardCount,
      orElse: () => 0,
    );
    if (newCardCount <= 0) {
      return const SizedBox.shrink();
    }

    return MxCard(
      onTap: () => context.goStudyEntry(
        entryType: EntryType.today,
        studyType: StudyType.newCards,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_outlined,
            size: SizeTokens.iconSm,
            color: context.colorScheme.primary,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: MxText(
              l10n.dashboardStartNewLearningAction,
              role: MxTextRole.labelLarge,
              color: context.colorScheme.primary,
            ),
          ),
          MxStatusBadge(
            status: MxCardStatus.newCard,
            label: l10n.dashboardNewCardsBadge(newCardCount),
          ),
        ],
      ),
    );
  }
}

class _DashboardRecentDecksSection extends ConsumerWidget {
  const _DashboardRecentDecksSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<DashboardDeckHighlights> query = ref.watch(
      dashboardDeckHighlightsQueryProvider,
    );
    return MxRetainedAsyncState<DashboardDeckHighlights>(
      value: query,
      skeletonBuilder: (_) => const _DashboardSectionSkeleton(),
      errorBuilder: (Object error, StackTrace? stackTrace) =>
          const SizedBox.shrink(),
      data: (DashboardDeckHighlights highlights) {
        if (highlights.recentDecks.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MxSectionHeader(
              label: l10n.dashboardRecentDecksTitle,
              trailing: MxActionButton(
                intent: MxActionIntent.inline,
                label: l10n.libraryTitle,
                icon: Icons.chevron_right_rounded,
                onPressed: () => context.goLibrary(),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            for (
              int index = 0;
              index < highlights.recentDecks.length;
              index++
            ) ...<Widget>[
              _DashboardRecentDeckRow(
                deck: highlights.recentDecks[index],
                index: index,
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
          ],
        );
      },
    );
  }
}

class _DashboardRecentDeckRow extends StatelessWidget {
  const _DashboardRecentDeckRow({required this.deck, required this.index});

  final DashboardRecentDeck deck;
  final int index;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color accent = switch (index % 3) {
      0 => context.customColors.mastery,
      1 => context.customColors.accent,
      _ => context.customColors.streak,
    };
    final String cardsLabel = l10n.dashboardDeckCardCount(deck.cardCount);
    final String metaLabel = deck.lastStudiedAt == null
        ? cardsLabel
        : () {
            final RelativeTime relativeTime = RelativeTime.between(
              deck.lastStudiedAt!,
              DateTime.now(),
            );
            return '$cardsLabel · ${l10n.dashboardDeckLastStudied(l10n.relativeTimeAgo(relativeTime.unit.name, relativeTime.count))}';
          }();

    return MxCard(
      onTap: () => context.pushFlashcardList(deck.deckId),
      child: Row(
        children: <Widget>[
          MxIconTile(icon: Icons.style_outlined, color: accent),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MxText(
                  deck.deckName,
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
          if (deck.dueCount > 0) ...<Widget>[
            const SizedBox(width: SpacingTokens.sm),
            MxStatusBadge(
              status: MxCardStatus.reviewing,
              label: l10n.dashboardDeckDueBadge(deck.dueCount),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardOverlineLabel extends StatelessWidget {
  const _DashboardOverlineLabel({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      Container(
        width: SpacingTokens.compact,
        height: SpacingTokens.compact,
        decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
      ),
      const SizedBox(width: SpacingTokens.tight),
      MxText(
        StringUtils.uppercased(label),
        role: MxTextRole.labelLarge,
        color: context.colorScheme.onSurfaceVariant,
      ),
    ],
  );
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
  Widget build(BuildContext context) => ListView(
    children: const <Widget>[
      SizedBox(height: SpacingTokens.md),
      _DashboardResumeCardSkeleton(),
      SizedBox(height: SpacingTokens.md),
      _DashboardStatsSkeleton(),
      SizedBox(height: SpacingTokens.md),
      _DashboardSectionSkeleton(),
      SizedBox(height: SpacingTokens.xl),
    ],
  );
}

class _DashboardStatsSkeleton extends StatelessWidget {
  const _DashboardStatsSkeleton();

  @override
  Widget build(BuildContext context) => const Row(
    children: <Widget>[
      Expanded(child: MxCard(child: _DashboardSkeletonBlock(lines: 2))),
      SizedBox(width: SpacingTokens.md),
      Expanded(child: MxCard(child: _DashboardSkeletonBlock(lines: 2))),
    ],
  );
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
  const _DashboardSkeletonBlock({required this.lines, this.hasActions = false});

  final int lines;
  final bool hasActions;

  @override
  Widget build(BuildContext context) => Column(
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
