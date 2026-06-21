import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/resolve_eligible_study_cards_usecase.dart';

class _FakeStudyEntryRepository implements StudyEntryRepository {
  StudyScope? scope;
  int? now;

  @override
  Future<Result<List<FlashcardId>>> resolveEligibleCardIds({
    required StudyScope scope,
    required int now,
  }) async {
    this.scope = scope;
    this.now = now;
    return (failure: null, data: const <FlashcardId>['c1', 'c2']);
  }

  @override
  Future<Result<StudyEntryEligibility>> resolveEligibility({
    required StudyScope scope,
    required int now,
  }) async => throw UnimplementedError();
}

void main() {
  test('passes the scope through and injects a current clock', () async {
    final repo = _FakeStudyEntryRepository();
    final useCase = ResolveEligibleStudyCardsUseCase(repository: repo);
    const scope = StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'd1',
      studyType: StudyType.srsReview,
    );

    final before = DateTime.now().millisecondsSinceEpoch;
    final result = await useCase.call(scope: scope);
    final after = DateTime.now().millisecondsSinceEpoch;

    expect(result.failure, isNull);
    expect(result.data, <FlashcardId>['c1', 'c2']);
    expect(repo.scope, scope);
    expect(repo.now, inInclusiveRange(before, after));
  });
}
