import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/usecases/study/cancel_study_session_usecase.dart';

class _FakeStudyRepository implements StudyRepository {
  SessionId? cancelledId;

  @override
  Future<Result<void>> cancelSession({required SessionId id}) async {
    cancelledId = id;
    return (failure: null, data: null);
  }

  @override
  Future<Result<int>> expireOldSessions({required int now}) async =>
      (failure: null, data: 0);

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
    required int now,
  }) async => throw UnimplementedError();

  @override
  Future<Result<StudySessionReview>> loadStudySessionReview({
    required SessionId id,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> recordStudySessionAnswer({
    required SessionId sessionId,
    required String sessionItemId,
    required AttemptResult result,
    required StudyMode studyMode,
    required int now,
  }) async => throw UnimplementedError();

  @override
  Future<Result<StudySession?>> findResumable({
    required StudyScope scope,
    required int now,
  }) async => throw UnimplementedError();
}

void main() {
  test('delegates the cancel to the repository with the session id', () async {
    final repo = _FakeStudyRepository();
    final useCase = CancelStudySessionUseCase(repository: repo);

    final result = await useCase.call(id: 's1');

    expect(result.failure, isNull);
    expect(repo.cancelledId, 's1');
  });
}
