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
import 'package:memox/presentation/features/history/widgets/card_history_beginning_row.dart';
import 'package:memox/presentation/features/history/widgets/card_history_filter_pill.dart';
import 'package:memox/presentation/features/history/widgets/card_history_header_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_lifecycle_row.dart';
import 'package:memox/presentation/features/history/widgets/card_history_progress_card.dart';
import 'package:memox/presentation/features/history/widgets/card_history_timeline_row.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_breadcrumb.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Card History body: breadcrumb + header + current-progress card + the unified
/// activity feed (attempts + lifecycle events), all in one [CustomScrollView].
/// Timeline loading/empty/error fill the remaining viewport via
/// [SliverFillRemaining]; events render as a [SliverList].
///
/// Async branching is intentionally manual (not `MxRetainedAsyncState`): the
/// timeline states need different sliver shapes. `AsyncValue.when` is avoided to
/// honour `memox.state_management.use_app_async_builder`.
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
    final AsyncValue<CardHistoryTimeline> timeline = ref.watch(
      cardHistoryTimelineProvider(flashcardId),
    );

    return CustomScrollView(
      slivers: <Widget>[
        _adapter(
          top: SpacingTokens.sm,
          child: _Breadcrumb(header: header),
        ),
        _adapter(child: CardHistoryHeaderCard(header: header)),
        _adapter(
          child: CardHistoryProgressCard(header: header, now: now),
        ),
        ..._timelineSlivers(context, ref, timeline, now),
      ],
    );
  }

  // Horizontal page gutter comes from MxScaffold's MxContentShell; only add
  // vertical spacing here (avoid double-gutter).
  Widget _adapter({required Widget child, double top = SpacingTokens.sm}) =>
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: top),
          child: child,
        ),
      );

  List<Widget> _timelineSlivers(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<CardHistoryTimeline> timeline,
    DateTime now,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CardHistoryTimeline? data = timeline.value;

    if (data == null) {
      if (timeline.hasError) {
        return <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
            child: MxErrorState(
              icon: Icons.cloud_off_outlined,
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

    if (data.isEmpty) {
      return <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.lg),
            child: MxCard(
              padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.xl,
                horizontal: SpacingTokens.lg,
              ),
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
          ),
        ),
      ];
    }

    final CardHistoryFilter filter = ref.watch(
      cardHistoryFilterControllerProvider(flashcardId),
    );
    final List<CardHistoryEvent> events = data.events
        .where(filter.matches)
        .toList(growable: false);

    return <Widget>[
      SliverToBoxAdapter(
        child: _TimelineHeader(count: events.length, flashcardId: flashcardId),
      ),
      SliverList.list(
        children: <Widget>[
          for (final CardHistoryEvent event in events)
            _row(event, events.first == event, now),
          const CardHistoryBeginningRow(),
        ],
      ),
    ];
  }

  Widget _row(CardHistoryEvent event, bool isFirst, DateTime now) =>
      switch (event) {
        CardHistoryAttemptEvent() => CardHistoryTimelineRow(
          attempt: event,
          now: now,
          isFirst: isFirst,
          isLast: false,
        ),
        CardHistoryLifecycleEvent() => CardHistoryLifecycleRow(
          event: event,
          deckName: header.deckName,
          now: now,
          isFirst: isFirst,
          isLast: false,
        ),
      };
}

class _TimelineHeader extends ConsumerWidget {
  const _TimelineHeader({required this.count, required this.flashcardId});

  final int count;
  final String flashcardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final CardHistoryFilter filter = ref.watch(
      cardHistoryFilterControllerProvider(flashcardId),
    );
    return Padding(
      padding: const EdgeInsets.only(
        top: SpacingTokens.lg,
        bottom: SpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: MxText(
              StringUtils.uppercased(l10n.cardHistoryTimelineHeader(count)),
              role: MxTextRole.labelMedium,
              color: context.colorScheme.onSurfaceVariant,
              fontWeight: TypographyTokens.bold,
            ),
          ),
          CardHistoryFilterPill(
            filter: filter,
            onSelected: (CardHistoryFilter next) => ref
                .read(cardHistoryFilterControllerProvider(flashcardId).notifier)
                .select(next),
          ),
        ],
      ),
    );
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
