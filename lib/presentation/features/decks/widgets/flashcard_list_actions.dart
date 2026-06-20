import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/decks/controllers/flashcard_action_controller.dart';
import 'package:memox/presentation/features/decks/flashcard_failure_message.dart';
import 'package:memox/presentation/features/decks/widgets/flashcard_card_dialog.dart';
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

/// Add-card flow in [deckId]: open the card dialog, create the card, report.
Future<void> runAddCard(
  BuildContext context,
  WidgetRef ref,
  DeckId deckId,
) async {
  final CardDraft? draft = await showCardDialog(context);
  if (draft == null) return;
  if (!context.mounted) return;
  final String success = AppLocalizations.of(context).cardCreatedSnack;
  final Result<Flashcard> result = await ref
      .read(flashcardActionControllerProvider.notifier)
      .create(deckId: deckId, front: draft.front, back: draft.back);
  if (!context.mounted) return;
  _report(context, result.failure, success);
}

/// Edit-card flow: open the dialog pre-filled, update, report.
Future<void> runEditCard(
  BuildContext context,
  WidgetRef ref,
  Flashcard card,
) async {
  final CardDraft? draft = await showCardDialog(context, existing: card);
  if (draft == null) return;
  if (!context.mounted) return;
  final String success = AppLocalizations.of(context).cardSavedSnack;
  final Result<Flashcard> result = await ref
      .read(flashcardActionControllerProvider.notifier)
      .update(flashcardId: card.id, front: draft.front, back: draft.back);
  if (!context.mounted) return;
  _report(context, result.failure, success);
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
