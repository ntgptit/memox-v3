import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/flashcard_list_detail.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_list_actions.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_list_body.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_list_search.dart';
import 'package:memox/presentation/shared/layouts/mx_scaffold.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_fab.dart';
import 'package:memox/presentation/shared/widgets/buttons/mx_icon_button.dart';
import 'package:memox/presentation/shared/widgets/navigation/mx_app_bar.dart';

/// Flashcard List — a deck's cards: a count overline + a grouped card list,
/// inline search, add/edit/delete card, and deck delete. Reached by tapping a
/// deck on the Folder-detail screen. WBS 3.4.2.
///
/// V1 scope: front/back content only. The full card editor (notes/tags/example,
/// SRS status chips, reorder, import) lands with WBS 2.11.2 / 2.12.2 / 6.x.
class FlashcardListScreen extends ConsumerWidget {
  const FlashcardListScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool searching = ref.watch(flashcardSearchActiveProvider(deckId));
    final AsyncValue<Result<FlashcardListDetail>> async = ref.watch(
      flashcardListStreamProvider(deckId),
    );
    final FlashcardListDetail? detail = async.value?.data;

    // Pop when the deck is gone (deleted here or elsewhere → NotFound result).
    ref.listen<AsyncValue<Result<FlashcardListDetail>>>(
      flashcardListStreamProvider(deckId),
      (
        AsyncValue<Result<FlashcardListDetail>>? prev,
        AsyncValue<Result<FlashcardListDetail>> next,
      ) {
        final bool gone = next.hasValue && next.value!.data == null;
        if (!gone) return;
        if (!context.mounted) return;
        if (Navigator.of(context).canPop()) context.pop();
      },
    );

    // On a successful deck delete the watch stream emits a NotFound result; the
    // `ref.listen` above performs the single pop. We do not pop here too (that
    // would be a redundant second pop for the same event).
    Future<void> deleteDeck() =>
        runDeleteDeck(context, ref, deckId, detail?.totalCount ?? 0);

    return MxScaffold(
      appBar: searching
          ? FlashcardListSearchAppBar(deckId: deckId)
          : MxAppBar(
              title: detail?.deck.name ?? '',
              actions: <Widget>[
                MxIconButton(
                  icon: Icons.search,
                  tooltip: l10n.flashcardSearchTooltip,
                  onPressed: () => ref
                      .read(flashcardSearchActiveProvider(deckId).notifier)
                      .activate(),
                ),
                if (detail != null)
                  MxIconButton(
                    icon: Icons.more_vert,
                    tooltip: l10n.deckOverflowTooltip,
                    onPressed: deleteDeck,
                  ),
              ],
            ),
      floatingActionButton: searching
          ? null
          : MxFab(
              icon: Icons.add,
              tooltip: l10n.flashcardAddCardLabel,
              onPressed: () => runAddCard(context, ref, deckId),
            ),
      body: FlashcardListBody(deckId: deckId),
    );
  }
}
