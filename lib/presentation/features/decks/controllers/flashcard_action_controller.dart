import 'package:memox/app/di/flashcard_providers.dart';
import 'package:memox/app/di/folder_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_action_controller.g.dart';

/// Stateless presentation controller for flashcard + deck mutations on the
/// Flashcard-list screen. Methods delegate to the use cases and return the
/// [Result]; the Drift watch stream refreshes the list automatically. The
/// minimal create/update path carries front/back only — optional notes and tags
/// land with the full editor (WBS 2.11.2 / 2.12.2). WBS 3.4.2.
@riverpod
class FlashcardActionController extends _$FlashcardActionController {
  @override
  void build() {}

  Future<Result<Flashcard>> create({
    required DeckId deckId,
    required String front,
    required String back,
  }) => ref
      .read(createFlashcardUseCaseProvider)
      .call(deckId: deckId, front: front, back: back);

  Future<Result<Flashcard>> update({
    required FlashcardId flashcardId,
    required String front,
    required String back,
  }) => ref
      .read(updateFlashcardUseCaseProvider)
      .call(flashcardId: flashcardId, front: front, back: back);

  Future<Result<void>> delete({required FlashcardId flashcardId}) =>
      ref.read(deleteFlashcardUseCaseProvider).call(flashcardId: flashcardId);

  /// Delete the whole deck (and its cards, via cascade). Caller MUST confirm.
  Future<Result<void>> deleteDeck({required DeckId deckId}) =>
      ref.read(deleteDeckUseCaseProvider).call(id: deckId);
}
