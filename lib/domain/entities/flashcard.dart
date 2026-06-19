import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'flashcard.freezed.dart';

/// A single flashcard belonging to exactly one deck.
///
/// [front] and [back] are the required content fields (non-empty after trim).
/// [exampleSentence], [pronunciation], and [hint] are optional notes, stored as
/// `null` (never an empty string) when blank after trim. [tags] are normalized
/// (lowercased, trimmed, deduped case-insensitively) and persisted separately in
/// `flashcard_tags`. See `docs/business/flashcard/flashcard-management.md` and
/// the `flashcards` table in `docs/database/schema-contract.md`.
///
/// Timestamps are UTC epoch milliseconds as persisted; the mapper converts to
/// [DateTime] at the data boundary. SRS state lives on [FlashcardProgress]
/// (1:1), never on this entity.
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
    @Default(<TagName>[]) List<TagName> tags,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Flashcard;
}
