import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';
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

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    StudyMode? mode,
  }) async {
    lastScope = scope;
    lastMode = mode;
    return result;
  }

  @override
  Future<Result<StudySession?>> findResumableSession({
    required StudyScope scope,
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
    final StartStudySessionUseCase useCase = StartStudySessionUseCase(
      repository,
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
    final StartStudySessionUseCase useCase = StartStudySessionUseCase(
      repository,
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
