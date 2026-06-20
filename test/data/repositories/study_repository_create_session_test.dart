import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/mappers/study_session_mapper.dart';
import 'package:memox/data/repositories/study_repository_impl.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/session_status.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

void main() {
  // StudyRepositoryImpl.createSession (WBS 4.2.1): the transactional
  // study_sessions + study_session_items insert (decision rows S1/S2/S3). V1
  // persists the session directly as in_progress
  // (docs/business/study/study-flow.md §Session lifecycle).
  group('StudyRepositoryImpl.createSession', () {
    late AppDatabase db;
    late StudyRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() async {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
      repository = StudyRepositoryImpl(
        dao: StudySessionDao(db),
        idGenerator: IdGenerator(),
      );
    });
    tearDown(() => db.close());

    Future<void> seedDeckWithCards(List<String> cardIds) async {
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'f1',
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'f1',
              name: 'd1',
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final String id in cardIds) {
        await db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: id,
                deckId: 'd1',
                front: id,
                back: id,
                sortOrder: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    }

    const deckScope = StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'd1',
      studyType: StudyType.newCards,
    );

    test('persists the session (in_progress) and ordered items (S1)', () async {
      await seedDeckWithCards(<String>['c1', 'c2', 'c3']);

      final result = await repository.createSession(
        scope: deckScope,
        flashcardIds: <String>['c2', 'c1', 'c3'],
        now: now,
      );

      expect(result.failure, isNull);
      final session = result.data!;
      expect(session.scope, deckScope);
      expect(session.status, SessionStatus.inProgress);

      final StudySessionRow row = await db.select(db.studySessions).getSingle();
      expect(row.status, 'in_progress');
      expect(row.entryType, 'deck');
      expect(row.entryRefId, 'd1');
      expect(row.studyType, 'new_cards');
      expect(row.startedAt, now);

      final List<StudySessionItemRow> items =
          await (db.select(db.studySessionItems)
                ..orderBy(<OrderClauseGenerator<StudySessionItems>>[
                  (t) => OrderingTerm(expression: t.sortOrder),
                ]))
              .get();
      expect(
        items.map((i) => i.flashcardId).toList(),
        <String>['c2', 'c1', 'c3'],
        reason: 'queue order preserved from the input list',
      );
      expect(items.every((i) => i.sessionId == session.id), isTrue);
    });

    test('folder scope persists its entry_ref_id + study type (S2)', () async {
      await seedDeckWithCards(<String>['c1', 'c2']);

      final result = await repository.createSession(
        scope: const StudyScope(
          entryType: EntryType.folder,
          entryRefId: 'f1',
          studyType: StudyType.srsReview,
        ),
        flashcardIds: <String>['c1', 'c2'],
        now: now,
      );

      expect(result.failure, isNull);
      final StudySessionRow row = await db.select(db.studySessions).getSingle();
      expect(row.entryType, 'folder');
      expect(row.entryRefId, 'f1');
      expect(row.studyType, 'srs_review');
      expect(await db.select(db.studySessionItems).get(), hasLength(2));
    });

    test('today scope persists a NULL entry_ref_id (S3)', () async {
      await seedDeckWithCards(<String>['c1']);

      final result = await repository.createSession(
        scope: const StudyScope(
          entryType: EntryType.today,
          entryRefId: null,
          studyType: StudyType.srsReview,
        ),
        flashcardIds: <String>['c1'],
        now: now,
      );

      expect(result.failure, isNull);
      final StudySessionRow row = await db.select(db.studySessions).getSingle();
      expect(row.entryType, 'today');
      expect(row.entryRefId, isNull);
      expect(row.studyType, 'srs_review');
    });

    test(
      'an empty card list is a ValidationFailure (no rows written)',
      () async {
        final result = await repository.createSession(
          scope: deckScope,
          flashcardIds: const <String>[],
          now: now,
        );

        expect(result.data, isNull);
        expect(result.failure, isA<ValidationFailure>());
        expect(await db.select(db.studySessions).get(), isEmpty);
        expect(await db.select(db.studySessionItems).get(), isEmpty);
      },
    );

    test(
      'rolls back the session when an item insert fails (transaction)',
      () async {
        // Seed only c1, then ask for a card that violates the FK → the whole
        // transaction (session + items) must roll back, leaving no rows.
        await seedDeckWithCards(<String>['c1']);

        final result = await repository.createSession(
          scope: deckScope,
          flashcardIds: <String>['c1', 'missing-card'],
          now: now,
        );

        expect(result.failure, isA<StorageFailure>());
        expect(
          await db.select(db.studySessions).get(),
          isEmpty,
          reason: 'session row rolled back with the failed item batch',
        );
        expect(await db.select(db.studySessionItems).get(), isEmpty);
      },
    );

    test('the storage mapper round-trips the persisted row', () async {
      await seedDeckWithCards(<String>['c1']);
      await repository.createSession(
        scope: deckScope,
        flashcardIds: <String>['c1'],
        now: now,
      );

      const mapper = StudySessionMapper();
      final StudySessionRow row = await db.select(db.studySessions).getSingle();
      final entity = mapper.toEntity(row);
      expect(entity.scope, deckScope);
      expect(entity.status, SessionStatus.inProgress);
      expect(entity.startedAt.millisecondsSinceEpoch, now);
    });
  });
}
