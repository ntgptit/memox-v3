import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/border_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/domain/models/card_history.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/history/viewmodels/card_history_viewmodel.dart';
import 'package:memox/presentation/features/history/widgets/card_history_reset_divider.dart';
import 'package:memox/presentation/features/history/widgets/card_history_timeline_row.dart';
import 'package:memox/presentation/shared/async/mx_retained_async_state.dart';
import 'package:memox/presentation/shared/layouts/mx_content_shell.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_action_intent.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_loading_state.dart';

/// Timeline section of the Card History screen: title, attempt rows (newest
/// first), the optional reset divider, and the Load more control. First-page
/// loading/error/empty are handled here; the header above stays visible.
class CardHistoryTimelineSection extends ConsumerWidget {
  const CardHistoryTimelineSection({
    required this.flashcardId,
    required this.lastResetAt,
    required this.onStartStudy,
    super.key,
  });

  final String flashcardId;
  final DateTime? lastResetAt;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<CardHistoryTimelineState> timeline = ref.watch(
      cardHistoryTimelineProvider(flashcardId),
    );

    return MxRetainedAsyncState<CardHistoryTimelineState>(
      value: timeline,
      skeletonBuilder: (_) => const MxLoadingState(rows: 4),
      errorBuilder: (Object error, StackTrace? stack) => MxErrorState(
        icon: Icons.history,
        title: l10n.cardHistoryErrorTitle,
        message: l10n.cardHistoryErrorMessage,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(cardHistoryTimelineProvider(flashcardId)),
      ),
      data: (CardHistoryTimelineState state) => state.isEmpty
          ? MxEmptyState(
              icon: Icons.insights_outlined,
              title: l10n.cardHistoryEmptyTitle,
              message: l10n.cardHistoryEmptyMessage,
              actionLabel: l10n.cardHistoryEmptyAction,
              onAction: onStartStudy,
            )
          : _TimelineList(
              flashcardId: flashcardId,
              state: state,
              lastResetAt: lastResetAt,
            ),
    );
  }
}

class _TimelineList extends ConsumerWidget {
  const _TimelineList({
    required this.flashcardId,
    required this.state,
    required this.lastResetAt,
  });

  final String flashcardId;
  final CardHistoryTimelineState state;
  final DateTime? lastResetAt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int dividerIndex = _dividerIndex();

    return ListView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xl),
      children: <Widget>[
        MxContentShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: SpacingTokens.lg,
                  bottom: SpacingTokens.xs,
                ),
                child: MxText(
                  l10n.cardHistoryTimelineTitle,
                  role: MxTextRole.titleSmall,
                ),
              ),
              for (int i = 0; i < state.attempts.length; i++) ...<Widget>[
                if (i == dividerIndex)
                  CardHistoryResetDivider(resetAt: lastResetAt!),
                CardHistoryTimelineRow(attempt: state.attempts[i]),
                if (i < state.attempts.length - 1) const _RowHairline(),
              ],
              if (state.hasMore)
                Padding(
                  padding: const EdgeInsets.only(top: SpacingTokens.md),
                  child: MxActionButton(
                    intent: MxActionIntent.inline,
                    label: state.loadMoreFailed
                        ? l10n.cardHistoryLoadMoreError
                        : l10n.cardHistoryLoadMore,
                    icon: state.loadMoreFailed
                        ? Icons.refresh
                        : Icons.expand_more,
                    onPressed: state.isLoadingMore
                        ? null
                        : () => ref
                              .read(
                                cardHistoryTimelineProvider(
                                  flashcardId,
                                ).notifier,
                              )
                              .loadMore(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Index of the first attempt older than [lastResetAt]; the divider sits
  /// above it. Returns `-1` when no divider should render (no reset, no attempts
  /// above, or the older side is not yet loaded) — wireframe §Rules.
  int _dividerIndex() {
    final DateTime? resetAt = lastResetAt;
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

class _RowHairline extends StatelessWidget {
  const _RowHairline();

  @override
  Widget build(BuildContext context) => Container(
    height: BorderTokens.width,
    color: context.colorScheme.outlineVariant,
  );
}
