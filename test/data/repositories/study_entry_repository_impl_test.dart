import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/study_entry_dao.dart';
import 'package:memox/data/datasources/local/daos/study_scope_dao.dart';
import 'package:memox/data/repositories/study_entry_repository_impl.dart';
import 'package:memox/domain/models/study_entry_eligibility.dart';
import 'package:memox/domain/types/entry_type.dart';
import 'package:memox/domain/types/study_scope.dart';
import 'package:memox/domain/types/study_type.dart';

void main() {
  // StudyEntryRepositoryImpl (WBS 4.1.1): classifies a scope against the
  // empty-scope matrix (`docs/business/study/study-flow.md`; decision rows
  // S4/S4b/S4c/S4d/S4e/S4j/S4f/S4g, S22, S23). Each test seeds the minimum
  // content and asserts the resolved outcome.
  group('StudyEntryRepositoryImpl.resolveEligibility', () {
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

    // Inserts a flashcard; when [withProgress] also inserts a progress row with
    // the given state. A card with no progress row counts as a new active card.
    Future<void> insertCard(
      String id,
      String deckId, {
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
              sortOrder: 0,
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

    Future<StudyEntryEligibility> resolve(StudyScope scope) async {
      final result = await repository.resolveEligibility(
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

    test('deck/new with cards is eligible (S24)', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: future);
      await insertCard(
        'c2',
        'd1',
        withProgress: false,
      ); // new, no progress (S23)

      final e = await resolve(deckScope(StudyType.newCards));
      expect(e.hasEligible, isTrue);
      expect(e.eligibleCount, 2, reason: 'new study draws all active cards');
    });

    test('deck with zero cards → deckNoCards (S4)', () async {
      await seedDeck();
      final e = await resolve(deckScope(StudyType.newCards));
      expect(e.emptyReason, StudyScopeEmptyReason.deckNoCards);
    });

    test('deck/srs with due cards is eligible (count = due only)', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: past);
      await insertCard('c2', 'd1', dueAt: future);

      final e = await resolve(deckScope(StudyType.srsReview));
      expect(e.hasEligible, isTrue);
      expect(e.eligibleCount, 1, reason: 'only the due card');
    });

    test(
      'deck/srs with cards but none due → deckNoDueCards + nextDueAt (S4e)',
      () async {
        await seedDeck();
        await insertCard('c1', 'd1', dueAt: future);
        await insertCard('c2', 'd1', dueAt: future + 5000);

        final e = await resolve(deckScope(StudyType.srsReview));
        expect(e.emptyReason, StudyScopeEmptyReason.deckNoDueCards);
        expect(e.nextDueAt, future, reason: 'earliest future due');
      },
    );

    test('all cards suspended → allSuspended (S4g)', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: past, suspended: true);
      await insertCard('c2', 'd1', dueAt: past, suspended: true);

      final e = await resolve(deckScope(StudyType.srsReview));
      expect(e.emptyReason, StudyScopeEmptyReason.allSuspended);
    });

    test('non-suspended remainder all buried → allBuried (S4f)', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: past, suspended: true);
      await insertCard('c2', 'd1', dueAt: past, buriedUntil: future);

      final e = await resolve(deckScope(StudyType.newCards));
      expect(e.emptyReason, StudyScopeEmptyReason.allBuried);
    });

    test('new study excludes suspended and buried from the count', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: past); // active
      await insertCard('c2', 'd1', suspended: true);
      await insertCard('c3', 'd1', buriedUntil: future);

      final e = await resolve(deckScope(StudyType.newCards));
      expect(e.eligibleCount, 1);
    });

    test('folder/new recursive over the subtree is eligible (S25)', () async {
      await insertFolder('root');
      await insertFolder('child', parentId: 'root');
      await insertDeck('d1', 'root');
      await insertDeck('d2', 'child');
      await insertCard('c1', 'd1', withProgress: false);
      await insertCard('c2', 'd2', dueAt: future);

      final e = await resolve(
        const StudyScope(
          entryType: EntryType.folder,
          entryRefId: 'root',
          studyType: StudyType.newCards,
        ),
      );
      expect(e.eligibleCount, 2, reason: 'cards from both subtree decks');
    });

    test('folder with zero descendant cards → folderNoCards (S4b)', () async {
      await insertFolder('root');
      await insertDeck('d1', 'root');

      final e = await resolve(
        const StudyScope(
          entryType: EntryType.folder,
          entryRefId: 'root',
          studyType: StudyType.newCards,
        ),
      );
      expect(e.emptyReason, StudyScopeEmptyReason.folderNoCards);
    });

    test('folder/srs none due → folderNoDueCards (S4j)', () async {
      await insertFolder('root');
      await insertDeck('d1', 'root');
      await insertCard('c1', 'd1', dueAt: future);

      final e = await resolve(
        const StudyScope(
          entryType: EntryType.folder,
          entryRefId: 'root',
          studyType: StudyType.srsReview,
        ),
      );
      expect(e.emptyReason, StudyScopeEmptyReason.folderNoDueCards);
      expect(e.nextDueAt, future);
    });

    test('today/srs with due cards is eligible (S3)', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: past);

      final e = await resolve(
        const StudyScope(
          entryType: EntryType.today,
          entryRefId: null,
          studyType: StudyType.srsReview,
        ),
      );
      expect(e.hasEligible, isTrue);
      expect(e.eligibleCount, 1);
    });

    test('today/srs with cards but none due → todayAllDone (S4c)', () async {
      await seedDeck();
      await insertCard('c1', 'd1', dueAt: future);

      final e = await resolve(
        const StudyScope(
          entryType: EntryType.today,
          entryRefId: null,
          studyType: StudyType.srsReview,
        ),
      );
      expect(e.emptyReason, StudyScopeEmptyReason.todayAllDone);
    });

    test(
      'today/srs with zero cards in the database → todayNoContent (S4d)',
      () async {
        final e = await resolve(
          const StudyScope(
            entryType: EntryType.today,
            entryRefId: null,
            studyType: StudyType.srsReview,
          ),
        );
        expect(e.emptyReason, StudyScopeEmptyReason.todayNoContent);
      },
    );

    // `today`'s canonical study type is srs_review (study-flow.md §Entry to flow
    // resolution). The resolver still applies the study type generically, so a
    // defensive today+new scope counts every active non-buried card rather than
    // filtering by due — pinned here so the behavior is explicit.
    test(
      'today/new counts all active cards (defensive, not due-filtered)',
      () async {
        await seedDeck();
        await insertCard('c1', 'd1', dueAt: future); // not due, new-eligible

        final e = await resolve(
          const StudyScope(
            entryType: EntryType.today,
            entryRefId: null,
            studyType: StudyType.newCards,
          ),
        );
        expect(e.hasEligible, isTrue);
        expect(e.eligibleCount, 1);
      },
    );

    test(
      'deck scope with a missing entry id → ValidationFailure (S22)',
      () async {
        final result = await repository.resolveEligibility(
          scope: const StudyScope(
            entryType: EntryType.deck,
            entryRefId: null,
            studyType: StudyType.newCards,
          ),
          now: now,
        );
        expect(result.data, isNull);
        expect(result.failure, isA<ValidationFailure>());
      },
    );

    test(
      'folder scope with a missing entry id → ValidationFailure (S22)',
      () async {
        final result = await repository.resolveEligibility(
          scope: const StudyScope(
            entryType: EntryType.folder,
            entryRefId: null,
            studyType: StudyType.newCards,
          ),
          now: now,
        );
        expect(result.data, isNull);
        expect(result.failure, isA<ValidationFailure>());
      },
    );
  });
}
