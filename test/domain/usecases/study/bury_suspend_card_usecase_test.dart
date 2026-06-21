import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/usecases/study/bury_study_session_card_usecase.dart';
import 'package:memox/domain/usecases/study/suspend_study_session_card_usecase.dart';

class _FakeStudyRepository implements StudyRepository {
  String? buriedSession;
  String? buriedCard;
  int? buriedNow;
  String? suspendedSession;
  String? suspendedCard;

  @override
  Future<Result<void>> buryStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
    required int now,
  }) async {
    buriedSession = sessionId;
    buriedCard = flashcardId;
    buriedNow = now;
    return (failure: null, data: null);
  }

  @override
  Future<Result<void>> suspendStudySessionCard({
    required SessionId sessionId,
    required FlashcardId flashcardId,
    required int now,
  }) async {
    suspendedSession = sessionId;
    suspendedCard = flashcardId;
    return (failure: null, data: null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

void main() {
  test('bury use case delegates with an injected clock', () async {
    final repo = _FakeStudyRepository();
    final useCase = BuryStudySessionCardUseCase(repository: repo);

    final before = DateTime.now().millisecondsSinceEpoch;
    final result = await useCase.call(sessionId: 's1', flashcardId: 'c1');
    final after = DateTime.now().millisecondsSinceEpoch;

    expect(result.failure, isNull);
    expect(repo.buriedSession, 's1');
    expect(repo.buriedCard, 'c1');
    expect(repo.buriedNow, inInclusiveRange(before, after));
  });

  test('suspend use case delegates the session + card', () async {
    final repo = _FakeStudyRepository();
    final useCase = SuspendStudySessionCardUseCase(repository: repo);

    final result = await useCase.call(sessionId: 's2', flashcardId: 'c2');

    expect(result.failure, isNull);
    expect(repo.suspendedSession, 's2');
    expect(repo.suspendedCard, 'c2');
  });
}
