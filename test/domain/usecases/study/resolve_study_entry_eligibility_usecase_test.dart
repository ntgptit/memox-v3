import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/resolve_study_entry_eligibility_usecase.dart';

class _FakeStudyEntryRepository implements StudyEntryRepository {
  StudyScope? scope;
  int? now;

  @override
  Future<Result<StudyEntryEligibility>> resolveEligibility({
    required StudyScope scope,
    required int now,
  }) async {
    this.scope = scope;
    this.now = now;
    return (failure: null, data: const StudyEntryEligibility(eligibleCount: 3));
  }
}

void main() {
  test('passes the scope through and injects a current clock', () async {
    final repo = _FakeStudyEntryRepository();
    final useCase = ResolveStudyEntryEligibilityUseCase(repository: repo);
    const scope = StudyScope(
      entryType: EntryType.today,
      entryRefId: null,
      studyType: StudyType.srsReview,
    );

    final before = DateTime.now().millisecondsSinceEpoch;
    final result = await useCase.call(scope: scope);
    final after = DateTime.now().millisecondsSinceEpoch;

    expect(result.data?.eligibleCount, 3);
    expect(repo.scope, scope);
    expect(repo.now, inInclusiveRange(before, after));
  });
}
