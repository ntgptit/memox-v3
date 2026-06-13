import 'package:flutter/material.dart';
import 'package:memox/core/theme/extensions/theme_context.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/core/theme/tokens/typography_tokens.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_detail_card_row.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_empty_state_section.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/states/mx_empty_state.dart';

/// Renders a loaded [FlashcardListDetail] — the card list, the reorder list, the
/// empty-deck state, or no-results-on-search
/// (`docs/wireframes/06-flashcard-list.md` §States). The empty-deck check uses
/// `totalCount` so it wins even while a search term is active.
///
/// The list opens with a `{n} CARDS` count header (mock 06 loaded). The mock's
/// `Due first` sort control is **Future** — the read model carries no due/SRS
/// ordering — so it is intentionally not rendered.
class FlashcardListBody extends StatelessWidget {
  const FlashcardListBody({
    required this.detail,
    required this.isSearching,
    required this.isReordering,
    required this.onAddCard,
    required this.onImport,
    required this.onClearSearch,
    required this.onCardTap,
    required this.onCardActions,
    required this.onReorder,
    super.key,
  });

  final FlashcardListDetail detail;
  final bool isSearching;
  final bool isReordering;
  final VoidCallback onAddCard;
  final VoidCallback onImport;
  final VoidCallback onClearSearch;
  final ValueChanged<Flashcard> onCardTap;
  final ValueChanged<Flashcard> onCardActions;
  final ValueChanged<List<String>> onReorder;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // Empty deck wins over an active search term (§States Empty).
    if (detail.totalCount == 0) {
      return FlashcardEmptyState(onAddCard: onAddCard, onImport: onImport);
    }

    if (detail.cards.isEmpty && isSearching) {
      return MxEmptyState(
        key: const ValueKey<String>('flashcard_no_results'),
        icon: Icons.search_off_outlined,
        title: l10n.flashcardsNoResultsTitle,
        message: l10n.flashcardsNoResultsMessage,
        actionLabel: l10n.flashcardsClearSearchAction,
        onAction: onClearSearch,
      );
    }

    if (isReordering) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _ListHeader(
            label: l10n.flashcardListReorderHeader(detail.cards.length),
          ),
          Expanded(
            child: _ReorderList(cards: detail.cards, onReorder: onReorder),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ListHeader(label: l10n.flashcardListCountHeader(detail.cards.length)),
        Expanded(
          child: ListView.separated(
            key: const ValueKey<String>('flashcard_list'),
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            itemCount: detail.cards.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: SpacingTokens.sm),
            itemBuilder: (BuildContext context, int index) {
              final Flashcard card = detail.cards[index];
              return FlashcardDetailCardRow(
                card: card,
                onTap: () => onCardTap(card),
                onShowActions: () => onCardActions(card),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Section header above the list / reorder body (mock 06 `{n} CARDS`). Uppercase
/// label rendered by the localized plural; carries no Future sort affordance.
class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    key: const ValueKey<String>('flashcard_list_count_header'),
    padding: const EdgeInsets.only(
      top: SpacingTokens.sm,
      bottom: SpacingTokens.sm,
    ),
    child: MxText(
      label,
      role: MxTextRole.labelMedium,
      color: context.colorScheme.onSurfaceVariant,
      fontWeight: TypographyTokens.semiBold,
    ),
  );
}

/// Drag-to-reorder list (§States Reorder). Each row keeps its content with a
/// leading drag handle (mock 06 reorder); on drop the full post-move id order is
/// reported so the repository can persist `sort_order`.
class _ReorderList extends StatelessWidget {
  const _ReorderList({required this.cards, required this.onReorder});

  final List<Flashcard> cards;
  final ValueChanged<List<String>> onReorder;

  @override
  Widget build(BuildContext context) => ReorderableListView.builder(
    key: const ValueKey<String>('flashcard_reorder_list'),
    padding: const EdgeInsets.only(bottom: SpacingTokens.md),
    itemCount: cards.length,
    buildDefaultDragHandles: false,
    itemBuilder: (BuildContext context, int index) {
      final Flashcard card = cards[index];
      return Padding(
        key: ValueKey<String>(card.id),
        padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
        child: Row(
          children: <Widget>[
            ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_indicator,
                size: SizeTokens.iconMd,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: FlashcardDetailCardRow(
                card: card,
                onTap: () {},
                onShowActions: () {},
                trailing: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      );
    },
    onReorder: (int oldIndex, int newIndex) {
      final List<String> ids = cards
          .map((Flashcard c) => c.id)
          .toList(growable: true);
      int target = newIndex;
      if (newIndex > oldIndex) {
        target -= 1;
      }
      final String moved = ids.removeAt(oldIndex);
      ids.insert(target, moved);
      onReorder(ids);
    },
  );
}
