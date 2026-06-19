import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'flashcard.freezed.dart';

/// A study card owned by exactly one deck.
///
/// Every flashcard is deck-owned: [deckId] is non-null and references a deck
/// (root-level / deckless flashcards are Rejected / Out of Scope — the
/// parent-child invariant in `docs/business/flashcard/flashcard-management.md`
/// §Rules and WBS 2.16.1). [front] and [back] are required content;
/// [exampleSentence], [pronunciation], [hint], and [partOfSpeech] are optional
/// detail text stored as `null` (never an empty string) when blank.
///
/// Timestamps are UTC epoch milliseconds (as persisted); the mapper converts to
/// [DateTime] at the data boundary. See the `flashcards` table in
/// `docs/database/schema-contract.md`.
@freezed
sealed class Flashcard with _$Flashcard {
  const factory Flashcard({
    required FlashcardId id,
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
    required bool isFlagged,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Flashcard;
}
