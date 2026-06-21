import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/entities/study_session_review.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/attempt_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/create_study_session_usecase.dart';

class _FakeStudyRepository implements StudyRepository {
  int createCalls = 0;
  int? now;
  List<FlashcardId>? lastFlashcardIds;

  @override
  Future<Result<StudySession>> createSession({
    required StudyScope scope,
    required List<FlashcardId> flashcardIds,
    required int now,
  }) async {
    createCalls++;
    this.now = now;
    lastFlashcardIds = flashcardIds;
    return (
      failure: null,
      data: StudySession(
        id: 's1',
        scope: scope,
        status: SessionStatus.inProgress,
        startedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(now, isUtc: true),
      ),
    );
  }

  @override
  Future<Result<int>> expireOldSessions({required int now}) async =>
      (failure: null, data: 0);

  @override
  Future<Result<void>> cancelSession({required SessionId id}) async =>
      (failure: null, data: null);

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

  @override
  Future<Result<void>> finalizeStudySession({
    required SessionId sessionId,
    required int now,
  }) async => throw UnimplementedError();
}

void main() {
  const scope = StudyScope(
    entryType: EntryType.deck,
    entryRefId: 'd1',
    studyType: StudyType.newCards,
  );

  test('rejects an empty card list before touching the repository', () async {
    final repo = _FakeStudyRepository();
    final useCase = CreateStudySessionUseCase(repository: repo);

    final result = await useCase.call(
      scope: scope,
      flashcardIds: const <String>[],
    );

    expect(result.data, isNull);
    expect(result.failure, isA<ValidationFailure>());
    expect(repo.createCalls, 0, reason: 'use case validates before delegating');
  });

  test('delegates a non-empty list and injects a current clock', () async {
    final repo = _FakeStudyRepository();
    final useCase = CreateStudySessionUseCase(repository: repo);

    final before = DateTime.now().millisecondsSinceEpoch;
    final result = await useCase.call(
      scope: scope,
      flashcardIds: <String>['c1'],
    );
    final after = DateTime.now().millisecondsSinceEpoch;

    expect(result.data?.id, 's1');
    expect(repo.createCalls, 1);
    expect(repo.now, inInclusiveRange(before, after));
  });

  test(
    'caps the batch at maxSessionItems, keeping the first N in order (S1)',
    () async {
      final repo = _FakeStudyRepository();
      final useCase = CreateStudySessionUseCase(repository: repo);
      final ids = <String>[
        for (int i = 0; i < CreateStudySessionUseCase.maxSessionItems + 5; i++)
          'c$i',
      ];

      await useCase.call(scope: scope, flashcardIds: ids);

      expect(
        repo.lastFlashcardIds,
        hasLength(CreateStudySessionUseCase.maxSessionItems),
      );
      expect(
        repo.lastFlashcardIds,
        ids.sublist(0, CreateStudySessionUseCase.maxSessionItems),
        reason: 'first N in resolved order',
      );
    },
  );

  test('passes a list at the cap through unchanged', () async {
    final repo = _FakeStudyRepository();
    final useCase = CreateStudySessionUseCase(repository: repo);
    final ids = <String>[
      for (int i = 0; i < CreateStudySessionUseCase.maxSessionItems; i++) 'c$i',
    ];

    await useCase.call(scope: scope, flashcardIds: ids);

    expect(repo.lastFlashcardIds, ids, reason: 'at-cap list passes unchanged');
  });
}
