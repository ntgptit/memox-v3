import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_match_evaluation.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/learning_settings.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/repositories/learning_settings_repository.dart';
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
  const StartStudySessionUseCase(this._repository, this._settingsRepository);

  final StudyRepository _repository;
  final LearningSettingsRepository _settingsRepository;

  Future<Result<StudyEntryStartResult>> call({
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    final Result<LearningSettings> settings = await _settingsRepository.load();
    return switch (settings) {
      Ok<LearningSettings>(:final value) => _repository.startStudySession(
        scope: scope,
        dailyNewLimit: value.dailyNewLimit,
        mode: mode,
      ),
      Err<LearningSettings>(:final failure) =>
        Result<StudyEntryStartResult>.err(failure),
    };
  }
}

/// Restarts a resumable study session by canceling the previous one and
/// creating a replacement in a single transactional operation.
///
/// Failure types: `NotFoundFailure`, `ValidationFailure`, `ConflictFailure`,
/// `StorageFailure`.
class RestartStudySessionUseCase {
  const RestartStudySessionUseCase(this._repository, this._settingsRepository);

  final StudyRepository _repository;
  final LearningSettingsRepository _settingsRepository;

  Future<Result<StudySession>> call({
    required SessionId previousSessionId,
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    final Result<LearningSettings> settings = await _settingsRepository.load();
    return switch (settings) {
      Ok<LearningSettings>(:final value) => _repository.restartStudySession(
        previousSessionId: previousSessionId,
        scope: scope,
        dailyNewLimit: value.dailyNewLimit,
        mode: mode,
      ),
      Err<LearningSettings>(:final failure) => Result<StudySession>.err(
        failure,
      ),
    };
  }
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

/// Loads the append-only Match evaluations for a persisted study session.
///
/// Failure types: `NotFoundFailure`, `StorageFailure`.
class LoadMatchEvaluationsUseCase {
  const LoadMatchEvaluationsUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<List<StudyMatchEvaluation>>> call({
    required SessionId sessionId,
  }) => _repository.loadMatchEvaluations(sessionId: sessionId);
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
    int? durationMs,
  }) => _repository.recordStudySessionAnswer(
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    result: result,
    studyMode: studyMode,
    durationMs: durationMs,
  );
}

/// Records an append-only Match evaluation without finalizing progress.
///
/// Failure types: `NotFoundFailure`, `UnsupportedActionFailure`,
/// `StorageFailure`.
class RecordMatchEvaluationUseCase {
  const RecordMatchEvaluationUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<void>> call({
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
    required StudyMode studyMode,
  }) => _repository.recordMatchEvaluation(
    sessionId: sessionId,
    sessionItemId: sessionItemId,
    flashcardId: flashcardId,
    boardIndex: boardIndex,
    pairId: pairId,
    selectedFrontCellId: selectedFrontCellId,
    selectedBackCellId: selectedBackCellId,
    expectedFrontFlashcardId: expectedFrontFlashcardId,
    expectedBackFlashcardId: expectedBackFlashcardId,
    isCorrect: isCorrect,
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

/// Buries the current in-session card until tomorrow local midnight + 1 second.
///
/// Failure types: `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.
class BuryStudySessionCardUseCase {
  const BuryStudySessionCardUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) => _repository.buryStudySessionCard(
    sessionId: sessionId,
    flashcardId: flashcardId,
  );
}

/// Suspends the current in-session card indefinitely.
///
/// Failure types: `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.
class SuspendStudySessionCardUseCase {
  const SuspendStudySessionCardUseCase(this._repository);

  final StudyRepository _repository;

  Future<Result<void>> call({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) => _repository.suspendStudySessionCard(
    sessionId: sessionId,
    flashcardId: flashcardId,
  );
}
