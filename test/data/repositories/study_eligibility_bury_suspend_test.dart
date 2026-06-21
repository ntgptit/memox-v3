import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_entry_dao.dart';
import 'package:memox/data/datasources/local/daos/study_scope_dao.dart';
import 'package:memox/data/repositories/study_entry_repository_impl.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

void main() {
  // StudyEntryRepositoryImpl.resolveEligibleCardIds (WBS 4.11.1): the ordered
  // eligible-card queue, excluding suspended and currently-buried cards, mirroring
  // the eligibility counts (docs/business/study-actions/bury-suspend.md;
  // docs/decision-tables/study-srs.md §Bury/Suspend). due → due_at order; new →
  // sort order.
  group('StudyEntryRepositoryImpl.resolveEligibleCardIds', () {
    late AppDatabase db;
    late StudyEntryRepositoryImpl repository;

    const int now = 1000 * 60 * 60 * 24 * 100; // day 100 in epoch ms
    const int past = now - 1;
    const int future = now + 1000;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repository = StudyEntryRepositoryImpl(
        dao: StudyEntryDao(db),
        scopeDao: StudyScopeDao(db),
      );
    });
    tearDown(() => db.close());

    Future<void> insertFolder(String id, {String? parentId}) => db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: id,
            name: id,
            contentMode: 'decks',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
            parentId: Value<String?>(parentId),
          ),
        );

    Future<void> insertDeck(String id, String folderId) => db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: id,
            folderId: folderId,
            name: id,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

    Future<void> insertCard(
      String id,
      String deckId, {
      int sortOrder = 0,
      bool withProgress = true,
      int? dueAt,
      bool suspended = false,
      int? buriedUntil,
    }) async {
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: id,
              deckId: deckId,
              front: id,
              back: id,
              sortOrder: sortOrder,
              createdAt: now,
              updatedAt: now,
            ),
          );
      if (!withProgress) return;
      await db
          .into(db.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: id,
              dueAt: Value<int?>(dueAt),
              isSuspended: Value<bool>(suspended),
              buriedUntil: Value<int?>(buriedUntil),
            ),
          );
    }

    StudyScope deckScope(StudyType type) => StudyScope(
      entryType: EntryType.deck,
      entryRefId: 'd1',
      studyType: type,
    );

    Future<List<String>> resolve(StudyScope scope) async {
      final result = await repository.resolveEligibleCardIds(
        scope: scope,
        now: now,
      );
      expect(result.failure, isNull, reason: 'expected success');
      return result.data!;
    }

    Future<void> seedDeck() async {
      await insertFolder('f1');
      await insertDeck('d1', 'f1');
    }

    test('deck/review returns only due cards, ordered by due_at', () async {
      await seedDeck();
      await insertCard('late', 'd1', sortOrder: 0, dueAt: now - 5000);
      await insertCard('early', 'd1', sortOrder: 1, dueAt: now - 100);
      await insertCard('notdue', 'd1', sortOrder: 2, dueAt: future);
      await insertCard('new', 'd1', sortOrder: 3); // due_at NULL → not "due"

      final ids = await resolve(deckScope(StudyType.srsReview));

      expect(ids, <String>[
        'late',
        'early',
      ], reason: 'due_at <= now only, ordered by due_at ASC');
    });

    test('deck/new returns every active card, ordered by sort_order', () async {
      await seedDeck();
      await insertCard('b', 'd1', sortOrder: 1, dueAt: now - 100);
      await insertCard('a', 'd1', sortOrder: 0); // new (no due)
      await insertCard('c', 'd1', sortOrder: 2, withProgress: false);

      final ids = await resolve(deckScope(StudyType.newCards));

      expect(ids, <String>[
        'a',
        'b',
        'c',
      ], reason: 'all active cards (due or not), ordered by sort_order');
    });

    test('suspended cards are excluded from both queues', () async {
      await seedDeck();
      await insertCard('ok', 'd1', sortOrder: 0, dueAt: past);
      await insertCard(
        'susp',
        'd1',
        sortOrder: 1,
        dueAt: past,
        suspended: true,
      );

      expect(await resolve(deckScope(StudyType.srsReview)), <String>['ok']);
      expect(await resolve(deckScope(StudyType.newCards)), <String>['ok']);
    });

    test(
      'currently-buried cards are excluded; expired bury re-enters',
      () async {
        await seedDeck();
        await insertCard('ok', 'd1', sortOrder: 0, dueAt: past);
        await insertCard(
          'buried',
          'd1',
          sortOrder: 1,
          dueAt: past,
          buriedUntil: future, // buried_until > now → hidden
        );
        await insertCard(
          'unburied',
          'd1',
          sortOrder: 2,
          dueAt: past,
          buriedUntil: past, // buried_until <= now → re-enters
        );

        expect(
          await resolve(deckScope(StudyType.srsReview)),
          <String>['ok', 'unburied'],
          reason: 'buried_until > now excluded, expired bury included',
        );
      },
    );

    test('folder/review collects due cards recursively', () async {
      await insertFolder('root');
      await insertFolder('child', parentId: 'root');
      await insertDeck('d1', 'root');
      await insertDeck('d2', 'child');
      await insertCard('r1', 'd1', sortOrder: 0, dueAt: now - 200);
      await insertCard('c1', 'd2', sortOrder: 0, dueAt: now - 100);
      await insertCard(
        'susp',
        'd2',
        sortOrder: 1,
        dueAt: past,
        suspended: true,
      );

      final result = await repository.resolveEligibleCardIds(
        scope: const StudyScope(
          entryType: EntryType.folder,
          entryRefId: 'root',
          studyType: StudyType.srsReview,
        ),
        now: now,
      );

      expect(result.failure, isNull);
      expect(result.data, <String>[
        'r1',
        'c1',
      ], reason: 'recursive, due order, suspended excluded');
    });

    test('today/review spans all decks excluding suspended/buried', () async {
      await seedDeck();
      await insertDeck('d2', 'f1');
      await insertCard('a', 'd1', sortOrder: 0, dueAt: now - 300);
      await insertCard('b', 'd2', sortOrder: 0, dueAt: now - 200);
      await insertCard(
        'susp',
        'd2',
        sortOrder: 1,
        dueAt: past,
        suspended: true,
      );
      // BS14: a currently-buried due card is excluded from today study too.
      await insertCard(
        'buried',
        'd2',
        sortOrder: 2,
        dueAt: past,
        buriedUntil: future,
      );

      final result = await repository.resolveEligibleCardIds(
        scope: const StudyScope(
          entryType: EntryType.today,
          entryRefId: null,
          studyType: StudyType.srsReview,
        ),
        now: now,
      );

      expect(result.failure, isNull);
      expect(
        result.data,
        <String>['a', 'b'],
        reason: 'suspended (BS13) and currently-buried (BS14) excluded',
      );
    });

    test('a deck scope with a null entry id is a ValidationFailure', () async {
      final result = await repository.resolveEligibleCardIds(
        scope: const StudyScope(
          entryType: EntryType.deck,
          entryRefId: null,
          studyType: StudyType.srsReview,
        ),
        now: now,
      );

      expect(result.data, isNull);
      expect(result.failure, isA<ValidationFailure>());
    });
  });
}
