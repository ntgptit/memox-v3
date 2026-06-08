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
  test('migrates study tables without losing library data', () async {
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

    await migratedDb.close();
    await tempDir.delete(recursive: true);
  });
}
