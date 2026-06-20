import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';

/// Records one self-grade answer for a session item (WBS 4.4.1).
///
/// Owns the `now` clock (epoch ms) for the attempt + activity timestamps, then
/// delegates the transactional insert to
/// [StudyRepository.recordStudySessionAnswer]. V1 records exactly one terminal
/// attempt per item and keeps `flashcard_progress` unchanged until finalization
/// (`docs/contracts/usecase-contracts/study.md` §RecordStudySessionAnswerUseCase).
/// The caller derives [result] from the mode's strategy (Got-it → `perfect`,
/// Forgot → `forgot`; Fill via its evaluator).
class RecordStudySessionAnswerUseCase {
  const RecordStudySessionAnswerUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
  }) => repository.recordStudySessionAnswer(
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    result: result,
    studyMode: studyMode,
    now: DateTime.now().millisecondsSinceEpoch,
  );
}
