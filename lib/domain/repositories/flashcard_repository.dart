import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/flashcard.dart';
import 'package:memox/domain/models/flashcard_duplicate_check_result.dart';
import 'package:memox/domain/types/ids.dart';

/// Port for flashcard persistence (WBS 2.11.1 create, 2.12.1 update, 2.16.1
/// parent-child validation, 2.20.1 duplicate soft-warning).
/// `FlashcardRepositoryImpl` (data layer) implements it.
///
/// Result/error style uses the project's current record-based [Result] (not
/// `Either`/`fpdart`). Mutation rules (front/back required-after-trim, optional
/// text trimmed to `null`, parent-deck existence) live behind these methods,
/// never in the UI. See `docs/business/flashcard/flashcard-management.md` and
/// `docs/contracts/usecase-contracts/flashcard.md`.
abstract interface class FlashcardRepository {
  /// Create a deck-owned flashcard, appended at the end of the deck's
  /// `sort_order`.
  ///
  /// Trims; rejects empty-after-trim [front] or [back]
  /// ([ValidationCode.empty]); rejects a missing parent deck
  /// ([NotFoundFailure]) — enforcing the parent-child invariant (WBS 2.16.1).
  /// Optional [exampleSentence] / [pronunciation] / [hint] / [partOfSpeech] are
  /// trimmed and stored as `null` when blank. Does NOT reject duplicates — the
  /// duplicate soft-warning is a separate non-blocking check
  /// ([checkManualDuplicate]).
  Future<Result<Flashcard>> createFlashcard({
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
  });

  /// Update an existing flashcard's content, preserving deck ownership and
  /// `sort_order`.
  ///
  /// Trims; rejects empty-after-trim [front] or [back]; rejects a missing card
  /// ([NotFoundFailure]). Optional fields follow the same blank → `null` rule.
  Future<Result<Flashcard>> updateFlashcard({
    required FlashcardId id,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
  });

  /// Non-blocking duplicate check (WBS 2.20.1): is there an existing card in
  /// [deckId] whose trimmed, case-insensitive `front` + `back` matches
  /// [front] + [back]? [excludeId] skips the card itself on edit. Never
  /// rejects a save — returns a [FlashcardDuplicateCheckResult] for the editor
  /// "save anyway?" flow.
  Future<Result<FlashcardDuplicateCheckResult>> checkManualDuplicate({
    required DeckId deckId,
    required String front,
    required String back,
    FlashcardId? excludeId,
  });
}
