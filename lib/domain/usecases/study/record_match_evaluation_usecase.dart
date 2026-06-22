import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Records one Match-mode pair evaluation in the active session (WBS 4.5.4).
///
/// Owns the `now` clock and the `match` study mode, delegating to
/// [StudyRepository.recordMatchEvaluation]: the tapped pair (the two selected
/// cells + the expected front/back cards + [isCorrect]) is appended to the
/// append-only `study_match_evaluations` stream and the session's `updated_at`
/// is touched. The row does NOT mark the item answered — Match finalization
/// derives the terminal attempt (WP-SM2). A non-`in_progress` session fails with
/// `UnsupportedActionFailure` (`docs/contracts/repository-contracts/study-repository.md`
/// §Match).
class RecordMatchEvaluationUseCase {
  const RecordMatchEvaluationUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required String sessionItemId,
    required int boardIndex,
    required String pairId,
    required String selectedFrontCellId,
    required String selectedBackCellId,
    required FlashcardId expectedFrontFlashcardId,
    required FlashcardId expectedBackFlashcardId,
    required bool isCorrect,
  }) => repository.recordMatchEvaluation(
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    boardIndex: boardIndex,
    pairId: pairId,
    selectedFrontCellId: selectedFrontCellId,
    selectedBackCellId: selectedBackCellId,
    expectedFrontFlashcardId: expectedFrontFlashcardId,
    expectedBackFlashcardId: expectedBackFlashcardId,
    isCorrect: isCorrect,
    studyMode: StudyMode.match,
    now: DateTime.now().millisecondsSinceEpoch,
  );
}
