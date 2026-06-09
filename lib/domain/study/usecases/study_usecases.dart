import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/attempt_result.dart';
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

/// Loads the persisted study-session result summary for the result screen.
///
/// Failure types: `NotFoundFailure`, `StorageFailure`.
class LoadStudySessionResultUseCase {
  const LoadStudySessionResultUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<StudySessionResult>> call({required SessionId sessionId}) =>
      _repository.loadStudySessionResult(sessionId: sessionId);
}

/// Records an in-session self-grade answer and marks the session item answered.
///
/// Failure types: `NotFoundFailure`, `UnsupportedActionFailure`,
/// `StorageFailure`.
class RecordStudySessionAnswerUseCase {
  const RecordStudySessionAnswerUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
  }) => _repository.recordStudySessionAnswer(
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    result: result,
    studyMode: studyMode,
  );
}

/// Loads the latest resumable session for the Dashboard resume card.
///
/// Failure types: `NotFoundFailure`, `StorageFailure`.
class LoadDashboardResumeSessionSummaryUseCase {
  const LoadDashboardResumeSessionSummaryUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<DashboardResumeSessionSummary?>> call() =>
      _repository.findLatestResumableSessionSummary();
}

/// Finalizes a persisted study session after every session item has an answer.
///
/// Failure types: `NotFoundFailure`, `FinalizationFailure`, `StorageFailure`.
class FinalizeStudySessionUseCase {
  const FinalizeStudySessionUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<void>> call({required SessionId sessionId}) =>
      _repository.finalizeStudySession(sessionId: sessionId);
}

/// Cancels a resumable study session.
///
/// Failure types: `StorageFailure`.
class CancelStudySessionUseCase {
  const CancelStudySessionUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<void>> call({required SessionId sessionId}) =>
      _repository.cancelStudySession(sessionId: sessionId);
}
