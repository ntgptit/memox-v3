import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/domain/entities/study_session.dart';
import 'package:memox/domain/models/dashboard_resume_session_summary.dart';
import 'package:memox/domain/models/study_session_review.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/study_entry_start_result.dart';
import 'package:memox/domain/types/ids.dart';
import 'package:memox/domain/types/study_mode.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:riverpod/misc.dart';

class _FakeStudyRepository implements StudyRepository {
  _FakeStudyRepository(this.result);

  Result<StudyEntryStartResult> result;

  @override
  Future<Result<StudyEntryStartResult>> startStudySession({
    required StudyScope scope,
    StudyMode? mode,
  }) async => result;

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
  Future<Result<StudySessionReview>> loadStudySessionReview({
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
  test('invalid entryType throws a format exception', () async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final provider = studyEntryProvider((
      entryType: 'bogus',
      entryRefId: 'deck-1',
      studyTypeQuery: null,
      modeQuery: null,
    ));
    final Completer<Object?> completer = Completer<Object?>();
    final ProviderSubscription<AsyncValue<StudyEntryStartResult>> subscription =
        container.listen<AsyncValue<StudyEntryStartResult>>(
      provider,
      (_, AsyncValue<StudyEntryStartResult> next) {
        if (next.hasError && !completer.isCompleted) {
          completer.complete(next.error);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await expectLater(completer.future, completion(isA<FormatException>()));
  });

  test('returns empty study-entry results unchanged', () async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.empty(
          emptyState: StudyEntryEmptyState(
            variant: StudyEntryEmptyVariant.deckNoCards,
          ),
        ),
      ),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        studyRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final StudyEntryStartResult result = await container.read(
      studyEntryProvider((
        entryType: 'deck',
        entryRefId: 'deck-1',
        studyTypeQuery: null,
        modeQuery: null,
      )).future,
    );

    expect(result, isA<StudyEntryStartEmpty>());
    expect(
      (result as StudyEntryStartEmpty).emptyState.variant,
      StudyEntryEmptyVariant.deckNoCards,
    );
  });

  test('returns started study-entry results unchanged', () async {
    final _FakeStudyRepository repository = _FakeStudyRepository(
      const Result<StudyEntryStartResult>.ok(
        StudyEntryStartResult.started(sessionId: 'session-1'),
      ),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        studyRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final StudyEntryStartResult result = await container.read(
      studyEntryProvider((
        entryType: 'folder',
        entryRefId: 'folder-1',
        studyTypeQuery: null,
        modeQuery: 'review',
      )).future,
    );

    expect(result, isA<StudyEntryStartStarted>());
    expect((result as StudyEntryStartStarted).sessionId, 'session-1');
  });
}
