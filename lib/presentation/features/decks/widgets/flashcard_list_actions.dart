import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/router/route_paths.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/controllers/flashcard_action_controller.dart';
import 'package:memox/presentation/features/decks/flashcard_failure_message.dart';
import 'package:memox/presentation/features/decks/viewmodels/flashcard_list_viewmodel.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_deck_overflow_sheet.dart';
import 'package:memox/presentation/shared/dialogs/mx_confirm_dialog.dart';
import 'package:memox/presentation/shared/feedback/mx_snackbar.dart';

void _report(BuildContext context, Failure? failure, String success) {
  if (failure != null) {
    showMxSnackbar(
      context,
      message: flashcardFailureMessage(AppLocalizations.of(context), failure),
      isError: true,
    );
    return;
  }
  showMxSnackbar(context, message: success);
}

/// Add-card flow in [deckId]: push the card editor screen (mock `07`). The
/// editor owns the create + snackbar on save. WBS 2.11.2.
void runAddCard(BuildContext context, DeckId deckId) => context.pushNamed(
  RouteNames.flashcardCreate,
  pathParameters: <String, String>{RouteParams.deckId: deckId},
);

/// Edit-card flow: push the card editor pre-filled (mock `08`). The editor owns
/// the update + snackbar on save. WBS 2.12.2.
void runEditCard(BuildContext context, Flashcard card) => context.pushNamed(
  RouteNames.flashcardEdit,
  pathParameters: <String, String>{
    RouteParams.deckId: card.deckId,
    RouteParams.flashcardId: card.id,
  },
);

/// Deck overflow (kebab) sheet: Reorder cards → enter reorder mode; Delete deck
/// → confirm + delete + pop. Returns `true` only when the deck was deleted (so
/// the caller can pop). WBS 2.14.2.
Future<bool> runDeckOverflow(
  BuildContext context,
  WidgetRef ref,
  DeckId deckId,
  int cardCount,
) async {
  final DeckOverflowAction? action = await showDeckOverflowSheet(context);
  if (action == null) return false;
  if (!context.mounted) return false;
  switch (action) {
    case DeckOverflowAction.reorder:
      ref.read(flashcardReorderActiveProvider(deckId).notifier).enter();
      return false;
    case DeckOverflowAction.deleteDeck:
      return runDeleteDeck(context, ref, deckId, cardCount);
  }
}

/// Persist a card reorder after a drag in reorder mode (full post-drag id list).
Future<void> runReorderCards(
  BuildContext context,
  WidgetRef ref,
  DeckId deckId,
  List<FlashcardId> orderedIds,
) async {
  final Result<void> result = await ref
      .read(flashcardActionControllerProvider.notifier)
      .reorder(deckId: deckId, orderedIds: orderedIds);
  if (!context.mounted) return;
  final Failure? failure = result.failure;
  if (failure != null) {
    showMxSnackbar(
      context,
      message: flashcardFailureMessage(AppLocalizations.of(context), failure),
      isError: true,
    );
  }
}

/// Delete-card flow: confirm, delete, report.
Future<void> runDeleteCard(
  BuildContext context,
  WidgetRef ref,
  Flashcard card,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool confirmed = await MxConfirmDialog.show(
    context,
    title: l10n.cardDeleteTitle,
    message: l10n.cardDeleteMessage,
    confirmLabel: l10n.cardDeleteConfirm,
    cancelLabel: l10n.commonCancel,
    destructive: true,
  );
  if (!confirmed) return;
  if (!context.mounted) return;
  final Result<void> result = await ref
      .read(flashcardActionControllerProvider.notifier)
      .delete(flashcardId: card.id);
  if (!context.mounted) return;
  _report(context, result.failure, l10n.cardDeletedSnack);
}

/// Delete-deck flow from the list app bar: confirm (blast radius = card count),
/// delete, then pop back to the folder. Returns `true` when the deck was
/// deleted so the caller can pop.
Future<bool> runDeleteDeck(
  BuildContext context,
  WidgetRef ref,
  DeckId deckId,
  int cardCount,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool confirmed = await MxConfirmDialog.show(
    context,
    title: l10n.deckDeleteTitle,
    message: l10n.deckDeleteMessage(cardCount),
    confirmLabel: l10n.deckDeleteConfirm,
    cancelLabel: l10n.commonCancel,
    destructive: true,
  );
  if (!confirmed) return false;
  if (!context.mounted) return false;
  final Result<void> result = await ref
      .read(flashcardActionControllerProvider.notifier)
      .deleteDeck(deckId: deckId);
  if (!context.mounted) return false;
  if (result.failure != null) {
    _report(context, result.failure, l10n.deckDeletedSnack);
    return false;
  }
  showMxSnackbar(context, message: l10n.deckDeletedSnack);
  return true;
}
