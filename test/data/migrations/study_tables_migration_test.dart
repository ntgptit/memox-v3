import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/data/datasources/local/app_database.dart';

class _LegacyAppDatabase extends AppDatabase {
  _LegacyAppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createTable(folders);
      await m.createTable(decks);
      await m.createTable(flashcards);
      await m.createTable(flashcardTags);
      await m.createTable(flashcardProgress);
      await m.createIndex(idxFlashcardTagsTag);
      await m.createIndex(idxFlashcardProgressEligibility);
    },
    beforeOpen: (OpeningDetails details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

void main() {
  test(
    'migrates study tables and match evaluations without losing library data',
    () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'memox_study_tables_',
      );
      final File dbFile = File(
        '${tempDir.path}${Platform.pathSeparator}memox.sqlite',
      );

      final _LegacyAppDatabase legacyDb = _LegacyAppDatabase(
        NativeDatabase(dbFile),
      );
      await legacyDb.customStatement('PRAGMA foreign_keys = ON');
      await legacyDb
          .into(legacyDb.folders)
          .insert(
            FoldersCompanion.insert(
              id: 'folder-1',
              name: 'Folder 1',
              contentMode: const Value<String>('decks'),
              sortOrder: const Value<int>(0),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await legacyDb
          .into(legacyDb.decks)
          .insert(
            DecksCompanion.insert(
              id: 'deck-1',
              folderId: 'folder-1',
              name: 'Deck 1',
              targetLanguage: const Value<String>('korean'),
              sortOrder: const Value<int>(0),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await legacyDb
          .into(legacyDb.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: 'card-1',
              deckId: 'deck-1',
              front: 'Front',
              back: 'Back',
              sortOrder: const Value<int>(0),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await legacyDb
          .into(legacyDb.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: 'card-1',
              dueAt: const Value<int?>(1),
            ),
          );
      await legacyDb.close();

      final AppDatabase migratedDb = AppDatabase(NativeDatabase(dbFile));
      final List<FolderRow> foldersRows = await migratedDb
          .select(migratedDb.folders)
          .get();
      final List<DeckRow> deckRows = await migratedDb
          .select(migratedDb.decks)
          .get();
      final List<FlashcardRow> flashcardRows = await migratedDb
          .select(migratedDb.flashcards)
          .get();

      expect(foldersRows, hasLength(1));
      expect(deckRows, hasLength(1));
      expect(flashcardRows, hasLength(1));
      expect(await migratedDb.select(migratedDb.studySessions).get(), isEmpty);
      expect(
        await migratedDb.select(migratedDb.studySessionItems).get(),
        isEmpty,
      );
      expect(await migratedDb.select(migratedDb.studyAttempts).get(), isEmpty);
      expect(
        await migratedDb.select(migratedDb.studyMatchEvaluations).get(),
        isEmpty,
      );

      await migratedDb
          .into(migratedDb.studySessions)
          .insert(
            StudySessionsCompanion.insert(
              id: 'session-1',
              entryType: 'deck',
              entryRefId: const Value<String?>('deck-1'),
              studyType: 'new_cards',
              status: 'in_progress',
              startedAt: 1,
              updatedAt: 1,
            ),
          );
      await migratedDb
          .into(migratedDb.studySessionItems)
          .insert(
            StudySessionItemsCompanion.insert(
              id: 'item-1',
              sessionId: 'session-1',
              flashcardId: 'card-1',
              sortOrder: 0,
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await migratedDb
          .into(migratedDb.studyMatchEvaluations)
          .insert(
            StudyMatchEvaluationsCompanion.insert(
              id: 'match-eval-1',
              sessionId: 'session-1',
              sessionItemId: 'item-1',
              flashcardId: 'card-1',
              boardIndex: 0,
              pairId: 'pair-1',
              selectedFrontCellId: 'front-1',
              selectedBackCellId: 'back-1',
              expectedFrontFlashcardId: 'card-1',
              expectedBackFlashcardId: 'card-1',
              isCorrect: const Value<bool>(true),
              attemptOrder: 0,
              evaluatedAt: 1,
              createdAt: 1,
            ),
          );
      expect(
        await migratedDb.select(migratedDb.studyMatchEvaluations).get(),
        hasLength(1),
      );

      await migratedDb.close();
      await tempDir.delete(recursive: true);
    },
  );

  test('onCreate creates the match evaluations table', () async {
    final AppDatabase db = AppDatabase(NativeDatabase.memory());

    await db
        .into(db.folders)
        .insert(
          FoldersCompanion.insert(
            id: 'folder-1',
            name: 'Folder 1',
            contentMode: const Value<String>('decks'),
            sortOrder: const Value<int>(0),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: 'deck-1',
            folderId: 'folder-1',
            name: 'Deck 1',
            targetLanguage: const Value<String>('korean'),
            sortOrder: const Value<int>(0),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: 'card-1',
            deckId: 'deck-1',
            front: 'Front',
            back: 'Back',
            sortOrder: const Value<int>(0),
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.studySessions)
        .insert(
          StudySessionsCompanion.insert(
            id: 'session-create-1',
            entryType: 'deck',
            entryRefId: const Value<String?>('deck-1'),
            studyType: 'new_cards',
            status: 'in_progress',
            startedAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.studySessionItems)
        .insert(
          StudySessionItemsCompanion.insert(
            id: 'item-create-1',
            sessionId: 'session-create-1',
            flashcardId: 'card-1',
            sortOrder: 0,
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db
        .into(db.studyMatchEvaluations)
        .insert(
          StudyMatchEvaluationsCompanion.insert(
            id: 'match-create-1',
            sessionId: 'session-create-1',
            sessionItemId: 'item-create-1',
            flashcardId: 'card-1',
            boardIndex: 0,
            pairId: 'pair-1',
            selectedFrontCellId: 'front-1',
            selectedBackCellId: 'back-1',
            expectedFrontFlashcardId: 'card-1',
            expectedBackFlashcardId: 'card-1',
            isCorrect: const Value<bool>(false),
            attemptOrder: 0,
            evaluatedAt: 1,
            createdAt: 1,
          ),
        );

    expect(await db.select(db.studyMatchEvaluations).get(), hasLength(1));

    await db.close();
  });
}
