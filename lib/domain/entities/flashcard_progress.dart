import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'flashcard_progress.freezed.dart';

/// The SRS scheduling state for one flashcard (1:1 with `flashcards`).
///
/// A brand-new card starts in box 1 with `dueAt == null` (never scheduled — it
/// counts as NEW until first studied) and zeroed counters. `currentBox`,
/// `dueAt`, `reviewCount`, and `lapseCount` are only ever mutated by the study /
/// SRS finalization path, never by the flashcard editor. See
/// `docs/contracts/repository-contracts/flashcard-repository.md` §Constraints
/// and the `flashcard_progress` table in `docs/database/schema-contract.md`.
@freezed
sealed class FlashcardProgress with _$FlashcardProgress {
  const factory FlashcardProgress({
    required FlashcardId flashcardId,
    required int currentBox,
    DateTime? dueAt,
    required int reviewCount,
    required int lapseCount,
  }) = _FlashcardProgress;

  /// The fresh-card state written on create and by `resetProgress`: box 1,
  /// unscheduled, zero counters.
  factory FlashcardProgress.initial(FlashcardId flashcardId) =>
      FlashcardProgress(
        flashcardId: flashcardId,
        currentBox: 1,
        dueAt: null,
        reviewCount: 0,
        lapseCount: 0,
      );
}
