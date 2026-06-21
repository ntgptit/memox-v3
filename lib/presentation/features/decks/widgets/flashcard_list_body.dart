import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/theme/mx_colors.dart';
import 'package:memox/core/theme/mx_spacing.dart';
import 'package:memox/core/util/string_utils.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_list_actions.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_tile.dart';
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
        return _content(context, ref, detail, StringUtils.trimmed(term));
      },
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
        _Overline(label: l10n.flashcardCountHeader(detail.totalCount)),
        const SizedBox(height: MxSpacing.space3),
        _groupedCard(
          context,
          ref,
          sortByContentMode<Flashcard>(
            detail.cards,
            ref.watch(librarySortModeProvider),
            name: (Flashcard c) => c.front,
            createdAt: (Flashcard c) => c.createdAt,
          ),
        ),
      ],
    );
  }

  Widget _groupedCard(
    BuildContext context,
    WidgetRef ref,
    List<Flashcard> cards,
  ) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      if (i > 0) rows.add(const MxDivider(indent: _dividerInset));
      final Flashcard card = cards[i];
      rows.add(
        FlashcardTile(
          card: card,
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
