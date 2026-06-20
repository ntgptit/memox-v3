import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/repositories/study_repository.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

void main() {
  // StudyRepositoryImpl.findResumable (WBS 4.2.2): the most recent resumable
  // session matching a scope within the 30-day window
  // (docs/contracts/repository-contracts/study-repository.md §Resumable matching).
  group('StudyRepositoryImpl.findResumable', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;
    final int window = StudyRepository.resumeWindow.inMilliseconds;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyRepositoryImpl(dao: StudySessionDao(db));
    });
    tearDown(() => db.close());

    Future<void> insertSession({
      required String id,
      String entryType = 'deck',
      String? entryRefId = 'd1',
      String status = 'in_progress',
      required int updatedAt,
    }) => db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: id,
            entryType: entryType,
            studyType: 'new_cards',
            status: status,
            startedAt: updatedAt,
            updatedAt: updatedAt,
            entryRefId: Value<String?>(entryRefId),
          ),
        );

    const deckScope = StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'd1',
      studyType: StudyType.newCards,
    );

    test('returns the most recent matching resumable session', () async {
      await insertSession(id: 'older', updatedAt: now - 2000);
      await insertSession(id: 'newer', updatedAt: now - 1000);

      final result = await repository.findResumable(scope: deckScope, now: now);

      expect(result.failure, isNull);
      expect(result.data?.id, 'newer', reason: 'ordered by updated_at DESC');
    });

    test('returns null when none match the scope', () async {
      await insertSession(id: 's', entryRefId: 'OTHER', updatedAt: now);
      final result = await repository.findResumable(scope: deckScope, now: now);
      expect(result.data, isNull);
    });

    test('excludes terminal sessions', () async {
      await insertSession(id: 'done', status: 'completed', updatedAt: now);
      await insertSession(id: 'gone', status: 'cancelled', updatedAt: now);
      final result = await repository.findResumable(scope: deckScope, now: now);
      expect(result.data, isNull);
    });

    test('excludes sessions older than the 30-day window', () async {
      await insertSession(id: 'stale', updatedAt: now - window - 1);
      final result = await repository.findResumable(scope: deckScope, now: now);
      expect(result.data, isNull);
    });

    test(
      'excludes a session exactly at the window boundary (strict >)',
      () async {
        await insertSession(id: 'edge', updatedAt: now - window);
        final result = await repository.findResumable(
          scope: deckScope,
          now: now,
        );
        expect(result.data, isNull, reason: 'updated_at == cutoff is excluded');
      },
    );

    test(
      'the scope match ignores study_type (conflict key is scope only)',
      () async {
        // A paused srs_review session blocks a new-cards start on the same scope:
        // study_type is NOT part of the resume conflict key.
        await insertSession(id: 'srs', updatedAt: now);
        final result = await repository.findResumable(
          scope: const StudyScope(
            entryType: EntryType.deck,
            entryRefId: 'd1',
            studyType: StudyType.srsReview,
          ),
          now: now,
        );
        expect(result.data?.id, 'srs');
      },
    );

    test('matches a today scope with a NULL entry_ref_id', () async {
      await insertSession(id: 'deck-one', updatedAt: now);
      await insertSession(
        id: 'today-one',
        entryType: 'today',
        entryRefId: null,
        updatedAt: now,
      );

      final result = await repository.findResumable(
        scope: const StudyScope(
          entryType: EntryType.today,
          entryRefId: null,
          studyType: StudyType.srsReview,
        ),
        now: now,
      );
      expect(result.data?.id, 'today-one', reason: 'NULL-safe ref match');
    });
  });
}
