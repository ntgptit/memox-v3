import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.result);

  Result<StudySession> result;
  SessionId? lastPreviousSessionId;
  StudyScope? lastScope;
  StudyMode? lastMode;

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    lastPreviousSessionId = previousSessionId;
    lastScope = scope;
    lastMode = mode;
    return result;
  }

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
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
            startedAt: DateTime.utc(2026, 1, 1),
            updatedAt: DateTime.utc(2026, 1, 1),
          ),
        ),
      );
      final RestartStudySessionUseCase useCase = RestartStudySessionUseCase(
        repository,
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
    },
  );

  test('returns the repository failure unchanged', () async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudySession>.err(
        Failure.notFound(entity: 'study_session', id: 'missing'),
      ),
    );
    final RestartStudySessionUseCase useCase = RestartStudySessionUseCase(
      repository,
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
