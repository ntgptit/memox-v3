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
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.recordResult);

  Result<void> recordResult;
  int recordCalls = 0;

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
  }) async {
    recordCalls++;
    return recordResult;
  }

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    StudyMode? mode,
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
  Future<Result<DashboardResumeSessionSummary?>>
  findLatestResumableSessionSummary() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<StudySession>> restartStudySession({
    required SessionId previousSessionId,
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> cancelStudySession({
    required SessionId sessionId,
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
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late _FakeStudyRepository repository;
  late RecordStudySessionAnswerUseCase useCase;

  setUp(() {
    repository = _FakeStudyRepository(const Result<void>.ok(null));
    useCase = RecordStudySessionAnswerUseCase(repository);
  });

  test(
    'GA1: returns success after recording a perfect self-grade answer',
    () async {
      final Result<void> result = await useCase.call(
        sessionId: 'session-1',
        sessionItemId: 'item-1',
        result: AttemptResult.perfect,
        studyMode: StudyMode.recall,
      );

      expect(result.isOk, isTrue);
      expect(repository.recordCalls, 1);
    },
  );

  test('GA2: forwards NotFoundFailure from the repository', () async {
    repository = _FakeStudyRepository(
      const Result<void>.err(
        Failure.notFound(entity: 'study_session_item', id: 'missing'),
      ),
    );
    useCase = RecordStudySessionAnswerUseCase(repository);

    final Result<void> result = await useCase.call(
      sessionId: 'session-1',
      sessionItemId: 'missing',
      result: AttemptResult.forgot,
      studyMode: StudyMode.recall,
    );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('GA3: forwards UnsupportedActionFailure from the repository', () async {
    repository = _FakeStudyRepository(
      const Result<void>.err(
        Failure.unsupportedAction(action: 'recordStudySessionAnswer'),
      ),
    );
    useCase = RecordStudySessionAnswerUseCase(repository);

    final Result<void> result = await useCase.call(
      sessionId: 'session-1',
      sessionItemId: 'item-1',
      result: AttemptResult.forgot,
      studyMode: StudyMode.recall,
    );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<UnsupportedActionFailure>());
  });

  test('GA4: forwards StorageFailure from the repository', () async {
    repository = _FakeStudyRepository(
      const Result<void>.err(
        Failure.storage(
          operation: StorageOp.transaction,
          cause: 'boom',
          table: 'study_attempts',
        ),
      ),
    );
    useCase = RecordStudySessionAnswerUseCase(repository);

    final Result<void> result = await useCase.call(
      sessionId: 'session-1',
      sessionItemId: 'item-1',
      result: AttemptResult.perfect,
      studyMode: StudyMode.recall,
    );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull, isA<StorageFailure>());
  });
}
