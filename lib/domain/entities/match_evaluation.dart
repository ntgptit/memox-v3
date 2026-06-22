import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memox/domain/types/ids.dart';

part 'match_evaluation.freezed.dart';

/// One append-only Match-mode pair evaluation (WBS 4.5.4): a single pair-tap on a
/// board recording the two selected cells, the expected front/back cards of the
/// tapped pair, and whether they formed a valid pair ([isCorrect]).
///
/// Rows do NOT mark the session item answered — Match finalization (WP-SM2)
/// derives one terminal `study_attempts` row per item from the ordered stream of
/// these (`docs/contracts/repository-contracts/study-repository.md` §Match).
/// [flashcardId] denormalizes the front cell's card (= [expectedFrontFlashcardId])
/// for per-card grouping; [attemptOrder] is the per-session append sequence.
@freezed
sealed class MatchEvaluation with _$MatchEvaluation {
  const factory MatchEvaluation({
    required String id,
    required SessionId sessionId,
    required String sessionItemId,
    required FlashcardId flashcardId,
    required int boardIndex,
    required String pairId,
    required String selectedFrontCellId,
    required String selectedBackCellId,
    required FlashcardId expectedFrontFlashcardId,
    required FlashcardId expectedBackFlashcardId,
    required bool isCorrect,
    required int attemptOrder,
    required DateTime evaluatedAt,
    required DateTime createdAt,
  }) = _MatchEvaluation;
  const MatchEvaluation._();
}
