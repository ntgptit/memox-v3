import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_radius.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/entities/flashcard_progress.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_list_actions.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_tile.dart';
import 'package:memox/presentation/features/folders/widgets/folder_icon_tile.dart';
import 'package:memox/presentation/features/folders/widgets/library_loading_skeleton.dart';
import 'package:memox/presentation/shared/async/app_async_builder.dart';
import 'package:memox/presentation/shared/sort/content_sort.dart';
import 'package:memox/presentation/shared/sort/library_sort_provider.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_secondary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_divider.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_error_state.dart';
import 'package:memox/presentation/shared/widgets/states/mx_no_results_state.dart';
import 'package:memox/presentation/shared/widgets/surfaces/mx_card.dart';

/// Flashcard-list body: the streamed cards rendered as a count overline + a
/// grouped list, with loading / empty / search-no-results / error states. A
/// card tap edits it; a long-press deletes it. WBS 3.4.2.
class FlashcardListBody extends ConsumerWidget {
  const FlashcardListBody({required this.deckId, super.key});

  static const double _dividerInset = MxSpacing.space10 + MxSpacing.space3;

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Result<FlashcardListDetail>> async = ref.watch(
      flashcardListStreamProvider(deckId),
    );
    final String term = ref.watch(flashcardSearchQueryProvider(deckId));
    final bool reordering = ref.watch(flashcardReorderActiveProvider(deckId));

    return AppAsyncBuilder<Result<FlashcardListDetail>>(
      value: async,
      loading: (_) => ListView(
        padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
        children: const <Widget>[LibraryLoadingSkeleton()],
      ),
      error: (_, _) => _error(context, ref, l10n),
      data: (Result<FlashcardListDetail> result) {
        final FlashcardListDetail? detail = result.data;
        if (result.failure != null || detail == null) {
          return _error(context, ref, l10n);
        }
        if (reordering) return _reorderContent(context, ref, detail);
        return _content(context, ref, detail, StringUtils.trimmed(term));
      },
    );
  }

  /// Reorder mode (mock `06` reorder): a `{n} CARDS · DRAG TO REORDER` overline +
  /// hint, then a `ReorderableListView` of the cards in manual (`sort_order`)
  /// order with a trailing drag handle per row; a drop persists the new order.
  Widget _reorderContent(
    BuildContext context,
    WidgetRef ref,
    FlashcardListDetail detail,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Flashcard> cards =
        detail.cards; // sort_order from the read model
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: MxSpacing.space3),
          child: _Overline(
            label: l10n.flashcardReorderCountHeader(detail.totalCount),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: MxSpacing.space2),
          child: MxText(
            l10n.flashcardReorderHint,
            role: MxTextRole.bodySmall,
            color: context.mxColors.textSecondary,
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            key: const ValueKey<String>('flashcard_reorder_list'),
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.only(bottom: MxSpacing.space3),
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int i) => _ReorderRow(
              key: ValueKey<String>(cards[i].id),
              card: cards[i],
              index: i,
            ),
            onReorder: (int oldIndex, int newIndex) {
              final List<Flashcard> next = List<Flashcard>.of(cards);
              final int target = newIndex > oldIndex ? newIndex - 1 : newIndex;
              next.insert(target, next.removeAt(oldIndex));
              unawaited(
                runReorderCards(
                  context,
                  ref,
                  deckId,
                  next.map((Flashcard c) => c.id).toList(growable: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _error(BuildContext context, WidgetRef ref, AppLocalizations l10n) =>
      MxErrorState(
        title: l10n.flashcardLoadFailedTitle,
        message: l10n.flashcardLoadFailedMessage,
        icon: Icons.cloud_off_outlined,
        action: MxPrimaryButton(
          label: l10n.libraryRetryLabel,
          icon: Icons.refresh,
          fullWidth: true,
          onPressed: () => ref.invalidate(flashcardListStreamProvider(deckId)),
        ),
      );

  Widget _content(
    BuildContext context,
    WidgetRef ref,
    FlashcardListDetail detail,
    String term,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (detail.totalCount == 0) {
      return MxEmptyState(
        icon: Icons.copy_all_outlined,
        title: l10n.flashcardEmptyTitle,
        message: l10n.flashcardEmptyMessage,
        action: MxPrimaryButton(
          label: l10n.flashcardAddCardLabel,
          icon: Icons.add,
          fullWidth: true,
          onPressed: () => runAddCard(context, ref, deckId),
        ),
      );
    }
    if (detail.cards.isEmpty && term.isNotEmpty) {
      return MxNoResultsState(
        key: const ValueKey<String>('flashcard_search_no_results'),
        title: l10n.librarySearchNoResultsTitle,
        message: l10n.librarySearchNoResultsMessage(term),
        action: MxSecondaryButton(
          label: l10n.librarySearchClearLabel,
          onPressed: () =>
              ref.read(flashcardSearchQueryProvider(deckId).notifier).clear(),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: MxSpacing.space3),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _Overline(
                label: l10n.flashcardCountHeader(detail.totalCount),
              ),
            ),
            // Deck due total beside the `{n} CARDS` overline (mock `06`).
            if (detail.dueCount > 0) _DueBadge(count: detail.dueCount),
          ],
        ),
        const SizedBox(height: MxSpacing.space3),
        _groupedCard(
          context,
          ref,
          sortByContentMode<Flashcard>(
            detail.cards,
            ref.watch(librarySortModeProvider(sortScopeDeck(deckId))),
            name: (Flashcard c) => c.front,
            createdAt: (Flashcard c) => c.createdAt,
          ),
          detail.progressById,
        ),
      ],
    );
  }

  Widget _groupedCard(
    BuildContext context,
    WidgetRef ref,
    List<Flashcard> cards,
    Map<String, FlashcardProgress> progressById,
  ) {
    // One `now` for every row's `due in {n}d` countdown, so they grade against
    // the same instant. (Screen goldens seed New cards only — `progressById`
    // empty — so this wall-clock read never branches there and stays
    // deterministic; the due-in render is golden-covered by the isolated
    // `flashcard_tile` test with an injected `now`.)
    final DateTime now = DateTime.now();
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      if (i > 0) rows.add(const MxDivider(indent: _dividerInset));
      final Flashcard card = cards[i];
      rows.add(
        FlashcardTile(
          card: card,
          progress: progressById[card.id],
          now: now,
          onTap: () => runEditCard(context, ref, card),
          onActions: () => runDeleteCard(context, ref, card),
        ),
      );
    }
    return MxCard(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.card,
        vertical: MxSpacing.space2,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: rows),
    );
  }
}

class _Overline extends StatelessWidget {
  const _Overline({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return MxText(
      StringUtils.upperFold(label),
      role: MxTextRole.labelMedium,
      color: colors.textSecondary,
    );
  }
}

/// A non-tappable card row in reorder mode: icon tile + front/back + a trailing
/// drag handle (`Icons.drag_indicator`) that starts the drag (mock `06` reorder).
class _ReorderRow extends StatelessWidget {
  const _ReorderRow({required this.card, required this.index, super.key});

  final Flashcard card;
  final int index;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.card,
        vertical: MxSpacing.space2,
      ),
      child: Row(
        children: <Widget>[
          FolderIconTile(color: colors.accent, icon: Icons.copy_all_outlined),
          const SizedBox(width: MxSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MxText(
                  card.front,
                  role: MxTextRole.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: MxSpacing.space1),
                MxText(
                  card.back,
                  role: MxTextRole.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: MxSpacing.space2),
          ReorderableDragStartListener(
            index: index,
            child: Icon(Icons.drag_indicator, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// The deck due-total pill shown beside the `{n} CARDS` overline (mock `06`).
class _DueBadge extends StatelessWidget {
  const _DueBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final MxColors colors = context.mxColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpacing.space2,
        vertical: MxSpacing.space1,
      ),
      // Solid accent fill (kit `06` spec): the deck-level overline due total is a
      // high-emphasis badge, distinct from the soft per-row due pills.
      decoration: BoxDecoration(
        color: colors.accent,
        borderRadius: MxRadius.pillAll,
      ),
      child: MxText(
        AppLocalizations.of(context).folderDueBadge(count),
        role: MxTextRole.labelSmall,
        color: colors.accentContrast,
      ),
    );
  }
}
