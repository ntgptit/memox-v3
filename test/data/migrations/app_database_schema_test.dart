import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

void main() {
  group('AppDatabase schema (v7)', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forExecutor(NativeDatabase.memory()));
    tearDown(() => db.close());

    int now() => DateTime.now().toUtc().millisecondsSinceEpoch;

    Future<void> insertFolderRow(String id) async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: id,
              name: id,
              contentMode: 'decks',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
    }

    test('reports the current schema version', () {
      expect(AppDatabase.currentSchemaVersion, 8);
      expect(db.schemaVersion, 8);
    });

    Future<void> insertDeckRow(String id, String folderId) async {
      final int ts = now();
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: id,
              folderId: folderId,
              name: id,
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
    }

    Future<void> insertFlashcardRow(String id, String deckId) async {
      final int ts = now();
      await db
          .into(db.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: id,
              deckId: deckId,
              front: 'front',
              back: 'back',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );
    }

    test('creates the flashcards table and round-trips a card', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');

      final List<FlashcardRow> rows = await db.select(db.flashcards).get();
      expect(rows, hasLength(1));
      expect(rows.single.front, 'front');
      expect(rows.single.exampleSentence, isNull);
    });

    test('flashcard_progress 1:1 cascades when its card is deleted', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardProgress)
          .insert(FlashcardProgressCompanion.insert(flashcardId: 'c1'));

      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();

      expect(await db.select(db.flashcardProgress).get(), isEmpty);
    });

    test('flashcard_progress defaults to not-suspended / not-buried', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardProgress)
          .insert(FlashcardProgressCompanion.insert(flashcardId: 'c1'));

      final FlashcardProgressRow row = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(row.isSuspended, isFalse, reason: 'v4 default: not suspended');
      expect(row.buriedUntil, isNull, reason: 'v4 default: not buried');
    });

    test('flashcard_tags cascade when their card is deleted', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardTags)
          .insert(
            FlashcardTagsCompanion.insert(flashcardId: 'c1', tag: 'noun'),
          );

      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();

      expect(await db.select(db.flashcardTags).get(), isEmpty);
    });

    test('deleting a deck cascades its flashcards', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');

      await (db.delete(db.decks)..where((t) => t.id.equals('d1'))).go();

      expect(await db.select(db.flashcards).get(), isEmpty);
    });

    test('rejects a flashcard with a missing deck (FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      final int ts = now();
      expect(
        () => db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: 'orphan',
                deckId: 'does-not-exist',
                front: 'f',
                back: 'b',
                sortOrder: 0,
                createdAt: ts,
                updatedAt: ts,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('creates the decks table and round-trips a deck', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      final int ts = now();
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final List<DeckRow> rows = await db.select(db.decks).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Verbs');
      expect(rows.single.folderId, 'folder');
      // target_language defaults to 'korean'.
      expect(rows.single.targetLanguage, 'korean');
    });

    test('cascades deck delete when its folder is removed', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      final int ts = now();
      await db
          .into(db.decks)
          .insert(
            DecksCompanion.insert(
              id: 'd1',
              folderId: 'folder',
              name: 'Verbs',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      await (db.delete(db.folders)..where((t) => t.id.equals('folder'))).go();

      expect(await db.select(db.decks).get(), isEmpty);
    });

    test('rejects a deck with a missing folder (FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      final int ts = now();
      expect(
        () => db
            .into(db.decks)
            .insert(
              DecksCompanion.insert(
                id: 'orphan',
                folderId: 'does-not-exist',
                name: 'Orphan',
                sortOrder: 0,
                createdAt: ts,
                updatedAt: ts,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('creates the folders table and round-trips a root folder', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'f1',
              name: 'Root',
              contentMode: 'empty',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final List<FolderRow> rows = await db.select(db.folders).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'Root');
      expect(rows.single.parentId, isNull);
      // color/icon default to NULL when not supplied (WBS 2.22.1).
      expect(rows.single.color, isNull);
      expect(rows.single.icon, isNull);
    });

    test('round-trips the optional folder color + icon tokens', () async {
      final int ts = now();
      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'styled',
              name: 'Styled',
              contentMode: 'unlocked',
              color: const Value('coral'),
              icon: const Value('book'),
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
            ),
          );

      final FolderRow row = await db.select(db.folders).getSingle();
      expect(row.color, 'coral');
      expect(row.icon, 'book');
    });

    test('persists a subfolder self-reference', () async {
      final int ts = now();
      Future<void> insertFolder(String id, {String? parentId}) => db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              id: id,
              name: id,
              contentMode: 'empty',
              sortOrder: 0,
              createdAt: ts,
              updatedAt: ts,
              parentId: Value<String?>(parentId),
            ),
          );

      await insertFolder('root');
      await insertFolder('child', parentId: 'root');

      final FolderRow child = await (db.select(
        db.folders,
      )..where((t) => t.id.equals('child'))).getSingle();
      expect(child.parentId, 'root');
    });

    test(
      'enforces the parent foreign key (RESTRICT on missing parent)',
      () async {
        await db.customStatement('PRAGMA foreign_keys = ON');
        final int ts = now();

        expect(
          () => db
              .into(db.folders)
              .insert(
                FoldersCompanion.insert(
                  id: 'orphan',
                  name: 'orphan',
                  contentMode: 'empty',
                  sortOrder: 0,
                  createdAt: ts,
                  updatedAt: ts,
                  parentId: const Value<String?>('does-not-exist'),
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );

    // --- Study persistence tables (v6, WBS 4.0.1) ---

    Future<void> insertSessionRow(
      String id, {
      String entryType = 'deck',
      String? entryRefId = 'd1',
      String status = 'draft',
    }) async {
      final int ts = now();
      await db
          .into(db.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: id,
              entryType: entryType,
              studyType: 'srs_review',
              status: status,
              startedAt: ts,
              updatedAt: ts,
              entryRefId: Value<String?>(entryRefId),
            ),
          );
    }

    Future<void> insertItemRow(String id, String sessionId, String cardId) => db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: id,
            sessionId: sessionId,
            flashcardId: cardId,
            sortOrder: 0,
            createdAt: now(),
            updatedAt: now(),
          ),
        );

    test('creates the study tables and round-trips the FK chain', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await insertSessionRow('s1');
      await insertItemRow('i1', 's1', 'c1');
      await db
          .into(db.studyAttempts)
          .insert(
            StudyAttemptsCompanion.insert(
              id: 'a1',
              sessionItemId: 'i1',
              result: 'perfect',
              studyMode: 'review',
              attemptedAt: now(),
            ),
          );

      final StudySessionRow session = await db
          .select(db.studySessions)
          .getSingle();
      expect(session.entryRefId, 'd1');
      expect(session.status, 'draft');
      // box_before / box_after default to 0 (unknown); user_input NULL.
      final StudyAttemptRow attempt = await db
          .select(db.studyAttempts)
          .getSingle();
      expect(attempt.boxBefore, 0);
      expect(attempt.boxAfter, 0);
      expect(attempt.userInput, isNull);
    });

    test('allows a NULL entry_ref_id for a today-scope session', () async {
      await insertSessionRow('s-today', entryType: 'today', entryRefId: null);
      final StudySessionRow row = await db.select(db.studySessions).getSingle();
      expect(row.entryRefId, isNull);
    });

    test('cancelling a session cascades its items and attempts', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await insertSessionRow('s1');
      await insertItemRow('i1', 's1', 'c1');
      await db
          .into(db.studyAttempts)
          .insert(
            StudyAttemptsCompanion.insert(
              id: 'a1',
              sessionItemId: 'i1',
              result: 'perfect',
              studyMode: 'review',
              attemptedAt: now(),
            ),
          );

      await (db.delete(db.studySessions)..where((t) => t.id.equals('s1'))).go();

      expect(await db.select(db.studySessionItems).get(), isEmpty);
      expect(await db.select(db.studyAttempts).get(), isEmpty);
    });

    test('deleting a flashcard cascades its session items', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await insertSessionRow('s1');
      await insertItemRow('i1', 's1', 'c1');

      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();

      expect(await db.select(db.studySessionItems).get(), isEmpty);
    });

    test('rejects a session item with a missing session (FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      expect(
        () => insertItemRow('orphan', 'no-session', 'c1'),
        throwsA(isA<Exception>()),
      );
    });

    // --- Card-history enabler (v7, WBS 7.0.1) ---

    test(
      'study_attempts.duration_ms defaults to NULL and round-trips',
      () async {
        await db.customStatement('PRAGMA foreign_keys = ON');
        await insertFolderRow('folder');
        await insertDeckRow('d1', 'folder');
        await insertFlashcardRow('c1', 'd1');
        await insertSessionRow('s1');
        await insertItemRow('i1', 's1', 'c1');
        await db
            .into(db.studyAttempts)
            .insert(
              StudyAttemptsCompanion.insert(
                id: 'a1',
                sessionItemId: 'i1',
                result: 'perfect',
                studyMode: 'review',
                attemptedAt: now(),
              ),
            );

        final StudyAttemptRow attempt = await db
            .select(db.studyAttempts)
            .getSingle();
        expect(attempt.durationMs, isNull, reason: 'v7 default: not measured');
      },
    );

    test('flashcard_progress.last_reset_at defaults to NULL', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.flashcardProgress)
          .insert(FlashcardProgressCompanion.insert(flashcardId: 'c1'));

      final FlashcardProgressRow row = await db
          .select(db.flashcardProgress)
          .getSingle();
      expect(row.lastResetAt, isNull, reason: 'v7 default: never reset');
    });

    test('card_events round-trips and cascades on card delete', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await insertFolderRow('folder');
      await insertDeckRow('d1', 'folder');
      await insertFlashcardRow('c1', 'd1');
      await db
          .into(db.cardEvents)
          .insert(
            CardEventsCompanion.insert(
              id: 'e1',
              flashcardId: 'c1',
              type: 'reset',
              occurredAt: now(),
              detail: const Value<String?>('box reset to 1'),
            ),
          );

      final CardEventRow event = await db.select(db.cardEvents).getSingle();
      expect(event.type, 'reset');
      expect(event.detail, 'box reset to 1');

      await (db.delete(db.flashcards)..where((t) => t.id.equals('c1'))).go();
      expect(await db.select(db.cardEvents).get(), isEmpty);
    });

    test('rejects a card event with a missing flashcard (FK)', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      await expectLater(
        db
            .into(db.cardEvents)
            .insert(
              CardEventsCompanion.insert(
                id: 'orphan',
                flashcardId: 'does-not-exist',
                type: 'created',
                occurredAt: now(),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
