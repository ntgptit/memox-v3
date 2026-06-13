import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'flashcard.freezed.dart';

/// A single flashcard belonging to exactly one deck
/// (`docs/business/flashcard/flashcard-management.md`).
///
/// SRS scheduling lives in the sibling `flashcard_progress` row and is not part
/// of this content entity. [exampleSentence], [pronunciation], and [hint] are
/// optional. [sortOrder] drives the manual (user-controlled) ordering surfaced
/// by the Flashcard List reorder mode.
@freezed
abstract class Flashcard with _$Flashcard {
  const factory Flashcard({
    required FlashcardId id,
    required DeckId deckId,
    required String front,
    required String back,
    String? exampleSentence,
    String? pronunciation,
    String? hint,
    String? partOfSpeech,
    @Default(false) bool isFlagged,
    required int sortOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Flashcard;
}
