import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/app/router/app_navigation.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/domain/models/folder_detail.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';
import 'package:memox/presentation/features/history/widgets/card_history_header_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_progress_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_reset_divider.dart';
import 'package:memox/presentation/features/history/widgets/card_history_timeline_row.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// Card History body: breadcrumb + header + current-progress card + timeline,
/// all in one [CustomScrollView] so they scroll together (matching the mock).
/// The timeline's loading/empty/error fill the remaining viewport via
/// [SliverFillRemaining] (bounded), while attempts render as a [SliverList].
///
/// Async branching here is intentionally manual (not `MxRetainedAsyncState`):
/// the three timeline states need different sliver shapes. `AsyncValue.when` is
/// avoided to honour `memox.state_management.use_app_async_builder`.
class CardHistoryBody extends ConsumerWidget {
  const CardHistoryBody({
    required this.deckId,
    required this.flashcardId,
    required this.header,
    super.key,
  });

  final String deckId;
  final String flashcardId;
  final CardHistoryHeader header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final AsyncValue<CardHistoryTimelineState> timeline = ref.watch(
      cardHistoryTimelineProvider(flashcardId),
    );

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: MxContentShell(child: _Breadcrumb(header: header)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: MxContentShell(child: CardHistoryHeaderCard(header: header)),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: MxContentShell(
              child: CardHistoryProgressCard(header: header, now: now),
            ),
          ),
        ),
        ..._timelineSlivers(context, ref, timeline, now),
      ],
    );
  }

  List<Widget> _timelineSlivers(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CardHistoryTimelineState> timeline,
    DateTime now,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CardHistoryTimelineState? state = timeline.value;

    if (state == null) {
      if (timeline.hasError) {
        return <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: MxErrorState(
              icon: Icons.history,
              title: l10n.cardHistoryErrorTitle,
              message: l10n.cardHistoryErrorMessage,
              retryLabel: l10n.commonRetry,
              onRetry: () =>
                  ref.invalidate(cardHistoryTimelineProvider(flashcardId)),
            ),
          ),
        ];
      }
      return const <Widget>[
        SliverFillRemaining(
          hasScrollBody: true,
          child: MxLoadingState(rows: 4),
        ),
      ];
    }

    if (state.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: MxEmptyState(
            icon: Icons.insights_outlined,
            title: l10n.cardHistoryEmptyTitle,
            message: l10n.cardHistoryEmptyMessage,
            actionLabel: l10n.cardHistoryEmptyAction,
            onAction: () => context.goStudyEntry(
              entryType: EntryType.deck,
              entryRefId: deckId,
            ),
          ),
        ),
      ];
    }

    return <Widget>[
      SliverList.list(children: _timelineChildren(context, ref, state, now)),
    ];
  }

  List<Widget> _timelineChildren(
    BuildContext context,
    WidgetRef ref,
    CardHistoryTimelineState state,
    DateTime now,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int dividerIndex = _dividerIndex(state);
    final int last = state.attempts.length - 1;

    return <Widget>[
      MxContentShell(
        child: Padding(
          padding: const EdgeInsets.only(
            top: SpacingTokens.lg,
            bottom: SpacingTokens.sm,
          ),
          child: MxText(
            StringUtils.uppercased(
              l10n.cardHistoryTimelineHeader(header.totalEvents),
            ),
            role: MxTextRole.labelMedium,
            color: context.colorScheme.onSurfaceVariant,
            fontWeight: TypographyTokens.bold,
          ),
        ),
      ),
      for (int i = 0; i < state.attempts.length; i++)
        MxContentShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (i == dividerIndex)
                CardHistoryResetDivider(resetAt: header.lastResetAt!),
              CardHistoryTimelineRow(
                attempt: state.attempts[i],
                now: now,
                isFirst: i == 0,
                isLast: i == last && !state.hasMore,
              ),
            ],
          ),
        ),
      if (state.hasMore)
        MxContentShell(
          child: MxActionButton(
            intent: MxActionIntent.inline,
            label: state.loadMoreFailed
                ? l10n.cardHistoryLoadMoreError
                : l10n.cardHistoryLoadMore,
            icon: state.loadMoreFailed ? Icons.refresh : Icons.expand_more,
            onPressed: state.isLoadingMore
                ? null
                : () => ref
                      .read(cardHistoryTimelineProvider(flashcardId).notifier)
                      .loadMore(),
          ),
        ),
      const SizedBox(height: SpacingTokens.xl),
    ];
  }

  /// Index of the first attempt older than `lastResetAt`; the divider sits above
  /// it. Returns `-1` when no divider should render (no reset, no attempts above,
  /// or the older side is not yet loaded) — wireframe §Rules.
  int _dividerIndex(CardHistoryTimelineState state) {
    final DateTime? resetAt = header.lastResetAt;
    if (resetAt == null) {
      return -1;
    }
    final int index = state.attempts.indexWhere(
      (CardHistoryAttempt a) => a.attemptedAt.isBefore(resetAt),
    );
    final bool hasNewerAbove = index > 0;
    final bool hasOlderBelow = index >= 0 && index < state.attempts.length;
    return hasNewerAbove && hasOlderBelow ? index : -1;
  }
}

class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.header});

  final CardHistoryHeader header;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return MxBreadcrumb(
      segments: <MxBreadcrumbSegment>[
        MxBreadcrumbSegment(
          label: l10n.libraryTitle,
          onTap: () => context.goLibrary(),
        ),
        for (final FolderBreadcrumbSegment seg in header.breadcrumb)
          MxBreadcrumbSegment(
            label: seg.name,
            onTap: () => context.pushFolderDetail(seg.id),
          ),
        if (header.deckName.isNotEmpty)
          MxBreadcrumbSegment(
            label: header.deckName,
            onTap: () => context.pushFlashcardList(header.deckId),
          ),
        MxBreadcrumbSegment(label: l10n.cardHistoryBreadcrumbCurrent),
      ],
    );
  }
}
