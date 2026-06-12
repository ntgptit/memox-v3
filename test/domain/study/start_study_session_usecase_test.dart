import 'package:flutter_test/flutter_test.dart';
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
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.result);

  Result<StudyEntryStartResult> result;
  StudyScope? lastScope;
  StudyMode? lastMode;
  int? lastDailyNewLimit;

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    int dailyNewLimit = LearningSettings.defaultDailyNewLimit,
    StudyMode? mode,
  }) async {
    lastScope = scope;
    lastMode = mode;
    lastDailyNewLimit = dailyNewLimit;
    return result;
  }

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
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
  test('forwards scope and mode to the repository', () async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.deckNoCards,
          ),
        ),
      ),
    );
    final _FakeLearningSettingsRepository settingsRepository =
        _FakeLearningSettingsRepository(
          const Result<LearningSettings>.ok(
            LearningSettings(dailyNewLimit: 35, goalDisabledSince: null),
          ),
        );
    final StartStudySessionUseCase useCase = StartStudySessionUseCase(
      repository,
      settingsRepository,
    );
    const StudyScope scope = StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.newCards,
    );

    final Result<StudyEntryStartResult> result = await useCase(
      scope: scope,
      mode: StudyMode.review,
    );

    expect(result, isA<Ok<StudyEntryStartResult>>());
    expect(repository.lastScope, scope);
    expect(repository.lastMode, StudyMode.review);
    expect(repository.lastDailyNewLimit, 35);
  });

  test('returns an empty outcome unchanged', () async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.todayAllDone,
          ),
        ),
      ),
    );
    final _FakeLearningSettingsRepository settingsRepository =
        _FakeLearningSettingsRepository(
          const Result<LearningSettings>.ok(LearningSettings.defaults),
        );
    final StartStudySessionUseCase useCase = StartStudySessionUseCase(
      repository,
      settingsRepository,
    );

    final Result<StudyEntryStartResult> result = await useCase(
      scope: const StudyScope(
        entryType: EntryType.today,
        entryRefId: null,
        studyType: StudyType.srsReview,
      ),
    );

    expect(result.valueOrNull, isA<StudyEntryStartEmpty>());
  });
}
