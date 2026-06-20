import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/repositories/study_entry_repository.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';
import 'package:memox/domain/usecases/study/resolve_study_entry_start_usecase.dart';

// Only `findResumable` is exercised; the rest of the large StudyRepository
// surface falls through to noSuchMethod (a test-only stub).
class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this._resumable);
  final StudySession? _resumable;

  @override
  Future<Result<StudySession?>> findResumable({
    required StudyScope scope,
    required int now,
  }) async => (failure: null, data: _resumable);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeStudyEntryRepository implements StudyEntryRepository {
  _FakeStudyEntryRepository(this._eligibility);
  final StudyEntryEligibility _eligibility;

  @override
  Future<Result<StudyEntryEligibility>> resolveEligibility({
    required StudyScope scope,
    required int now,
  }) async => (failure: null, data: _eligibility);
}

void main() {
  const scope = StudyScope(
    entryType: EntryType.deck,
    entryRefId: 'd1',
    studyType: StudyType.newCards,
  );

  StudySession session() => StudySession(
    id: 's1',
    scope: scope,
    status: SessionStatus.inProgress,
    startedAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  ResolveStudyEntryStartUseCase build({
    StudySession? resumable,
    StudyEntryEligibility eligibility = const StudyEntryEligibility(
      eligibleCount: 3,
    ),
  }) => ResolveStudyEntryStartUseCase(
    studyRepository: _FakeStudyRepository(resumable),
    entryRepository: _FakeStudyEntryRepository(eligibility),
  );

  test('a resumable session returns resumeRequired (S28)', () async {
    final result = await build(resumable: session()).call(scope: scope);
    expect(result.failure, isNull);
    expect(result.data, isA<StudyEntryResumeRequired>());
    expect((result.data! as StudyEntryResumeRequired).session.id, 's1');
  });

  test('no resumable + eligible scope returns canStart', () async {
    final result = await build(
      eligibility: const StudyEntryEligibility(eligibleCount: 5),
    ).call(scope: scope);
    expect(result.data, isA<StudyEntryCanStart>());
    expect((result.data! as StudyEntryCanStart).eligibility.eligibleCount, 5);
  });

  test('no resumable + empty scope returns blocked with the reason', () async {
    final result = await build(
      eligibility: const StudyEntryEligibility(
        emptyReason: StudyScopeEmptyReason.deckNoCards,
      ),
    ).call(scope: scope);
    expect(result.data, isA<StudyEntryBlocked>());
    expect(
      (result.data! as StudyEntryBlocked).reason,
      StudyScopeEmptyReason.deckNoCards,
    );
  });
}
