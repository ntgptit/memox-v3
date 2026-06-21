import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';

/// Finishes a study session (WBS 4.6.1/4.6.2/4.6.4).
///
/// Owns the `now` clock (epoch ms) used for the SRS due-date computation, then
/// delegates the finalization transaction to
/// [StudyRepository.finalizeStudySession]: applies the Leitner box transition +
/// interval due-date + counters to `flashcard_progress` and marks the session
/// `completed`, atomically. A session with any unanswered card yields a
/// `FinalizationFailure` and stays open (`docs/contracts/usecase-contracts/study.md`
/// §FinalizeStudySessionUseCase).
class FinalizeStudySessionUseCase {
  const FinalizeStudySessionUseCase({required this.repository});

  final StudyRepository repository;

  Future<Result<void>> call({required SessionId sessionId}) =>
      repository.finalizeStudySession(
        sessionId: sessionId,
        now: DateTime.now().millisecondsSinceEpoch,
      );
}
