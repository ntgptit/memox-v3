import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_session_result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/load_study_session_result_usecase.dart';

class _FakeStudyRepository implements StudyRepository {
  SessionId? requestedId;

  @override
  Future<Result<StudySessionResult>> loadStudySessionResult({
    required SessionId id,
  }) async {
    requestedId = id;
    final session = StudySession(
      id: id,
      scope: const StudyScope(
        entryType: EntryType.deck,
        entryRefId: 'd1',
        studyType: StudyType.srsReview,
      ),
      status: SessionStatus.completed,
      startedAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    return (
      failure: null,
      data: StudySessionResult(
        session: session,
        items: const <StudySessionResultItem>[
          StudySessionResultItem(
            sessionItemId: 'i1',
            flashcardId: 'c1',
            front: 'f',
            back: 'b',
            sortOrder: 0,
            result: AttemptResult.perfect,
          ),
        ],
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  test('delegates to the repository with the session id', () async {
    final repo = _FakeStudyRepository();
    final useCase = LoadStudySessionResultUseCase(repository: repo);

    final result = await useCase.call(sessionId: 's1');

    expect(result.failure, isNull);
    expect(repo.requestedId, 's1');
    expect(result.data!.total, 1);
    expect(result.data!.passedCount, 1);
  });
}
