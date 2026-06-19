import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'flashcard_duplicate_check_result.freezed.dart';

/// Result of the manual duplicate **soft-warning** check (WBS 2.20.1).
///
/// The check is non-blocking: it never rejects a save. When [isDuplicate] is
/// true the editor surfaces a "save anyway?" confirm; the create/update still
/// proceeds either way. A card is a duplicate when its trimmed,
/// case-insensitive `front` + `back` matches an existing card in the **same
/// deck** (excluding the card itself on edit). See
/// `docs/business/flashcard/flashcard-management.md` §Rules and
/// `docs/contracts/usecase-contracts/flashcard.md`.
@freezed
sealed class FlashcardDuplicateCheckResult
    with _$FlashcardDuplicateCheckResult {
  const factory FlashcardDuplicateCheckResult({
    required bool isDuplicate,

    /// Ids of the existing cards in the deck that the candidate duplicates
    /// (empty when [isDuplicate] is false). Lets the editor link to / preview
    /// the clashing card.
    @Default(<FlashcardId>[]) List<FlashcardId> matchingFlashcardIds,
  }) = _FlashcardDuplicateCheckResult;
  const FlashcardDuplicateCheckResult._();

  /// The not-a-duplicate result.
  static FlashcardDuplicateCheckResult get unique =>
      const FlashcardDuplicateCheckResult(isDuplicate: false);
}
