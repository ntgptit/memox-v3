import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';

/// Starts a study session from the entry gate.
///
/// Failure types: `StorageFailure`.
class StartStudySessionUseCase {
  const StartStudySessionUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<StudyEntryStartResult>> call({
    required StudyScope scope,
    StudyMode? mode,
  }) => _repository.startStudySession(scope: scope, mode: mode);
}

/// Loads a persisted study session for the review screen.
///
/// Failure types: `NotFoundFailure`, `StorageFailure`.
class LoadStudySessionReviewUseCase {
  const LoadStudySessionReviewUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<StudySessionReview>> call({required SessionId sessionId}) =>
      _repository.loadStudySessionReview(sessionId: sessionId);
}
