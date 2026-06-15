import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
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
import 'package:memox/domain/study/usecases/study_usecases.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_flow.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.result);

  Result<StudySession> result;
  SessionId? lastPreviousSessionId;
  StudyScope? lastScope;
  StudyMode? lastMode;
  int? lastDailyNewLimit;

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
    int dailyNewLimit = LearningSettings.defaultDailyNewLimit,
    StudyMode? mode,
  }) async {
    lastPreviousSessionId = previousSessionId;
    lastScope = scope;
    lastMode = mode;
    lastDailyNewLimit = dailyNewLimit;
    return result;
  }

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    int dailyNewLimit = LearningSettings.defaultDailyNewLimit,
    StudyMode? mode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> cancelStudySession({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> buryStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> suspendStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    int? durationMs,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> recordMatchEvaluation({
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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<StudyMatchEvaluation>>> loadMatchEvaluations({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySessionResult>> loadStudySessionResult({
    required SessionId sessionId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
    StudyFlow? studyFlow,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeLearningSettingsRepository implements LearningSettingsRepository {
  _FakeLearningSettingsRepository(this.result);

  Result<LearningSettings> result;

  @override
  Future<Result<LearningSettings>> load() async => result;

  @override
  Future<Result<void>> save(LearningSettings settings) async {
    throw UnimplementedError();
  }
}

void main() {
  test(
    'forwards previous session id, scope, and mode to the repository',
    () async {
      final _FakeStudyRepository repository = _FakeStudyRepository(
        Result<StudySession>.ok(
          StudySession(
            id: 'session-new',
            entryType: EntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newCards,
            status: SessionStatus.inProgress,
            studyFlow: StudyFlow.newFullCycle,
            currentMode: StudyMode.review,
            startedAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      );
      final _FakeLearningSettingsRepository settingsRepository =
          _FakeLearningSettingsRepository(
            const Result<LearningSettings>.ok(
              LearningSettings(dailyNewLimit: 30, goalDisabledSince: null),
            ),
          );
      final RestartStudySessionUseCase useCase = RestartStudySessionUseCase(
        repository,
        settingsRepository,
      );
      const StudyScope scope = StudyScope(
        entryType: EntryType.deck,
        entryRefId: 'deck-1',
        studyType: StudyType.newCards,
      );

      final Result<StudySession> result = await useCase(
        previousSessionId: 'session-old',
        scope: scope,
        mode: StudyMode.review,
      );

      expect(result.isOk, isTrue);
      expect(repository.lastPreviousSessionId, 'session-old');
      expect(repository.lastScope, scope);
      expect(repository.lastMode, StudyMode.review);
      expect(repository.lastDailyNewLimit, 30);
    },
  );

  test('returns the repository failure unchanged', () async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudySession>.err(
        Failure.notFound(entity: 'study_session', id: 'missing'),
      ),
    );
    final _FakeLearningSettingsRepository settingsRepository =
        _FakeLearningSettingsRepository(
          const Result<LearningSettings>.ok(LearningSettings.defaults),
        );
    final RestartStudySessionUseCase useCase = RestartStudySessionUseCase(
      repository,
      settingsRepository,
    );

    final Result<StudySession> result = await useCase(
      previousSessionId: 'session-old',
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: 'deck-1',
        studyType: StudyType.newCards,
      ),
    );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });
}
