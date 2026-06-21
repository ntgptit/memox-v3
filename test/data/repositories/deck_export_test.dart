import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/domain/models/deck_csv_export.dart';

void main() {
  // FlashcardRepositoryImpl.exportDeckCsv (WBS 8.7.1): read-only deck CSV export
  // (docs/business/export/export.md).
  group('FlashcardRepositoryImpl.exportDeckCsv', () {
    late AppDatabase db;
    late FlashcardRepositoryImpl repo;
    const int now = 1000 * 60 * 60 * 24 * 100;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      repo = FlashcardRepositoryImpl(
        dao: FlashcardDao(db),
        deckDao: DeckDao(db),
        folderDao: FolderDao(db),
      );
    });
    tearDown(() => db.close());

    Future<void> insertDeck(String id, String name) async {
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
              id: id,
              folderId: 'f1',
              name: name,
              sortOrder: 0,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    Future<void> insertCard(String id, String front, String back, int order) =>
        db
            .into(db.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: id,
                deckId: 'd1',
                front: front,
                back: back,
                sortOrder: order,
                createdAt: now,
                updatedAt: now,
              ),
            );

    test('exports cards in deck order with sanitized file name', () async {
      await insertDeck('d1', 'My Deck/01');
      await insertCard('c2', 'two', 'hai', 1);
      await insertCard('c1', 'one', 'một', 0);
      await insertCard('c3', 'a,b', 'c"d', 2);

      final result = await repo.exportDeckCsv(deckId: 'd1');

      expect(result.failure, isNull);
      final DeckCsvExport export = result.data!;
      expect(export.fileName, 'My Deck_01.csv');
      expect(export.exportedRowCount, 3);
      expect(
        export.csvText,
        'front,back\none,một\ntwo,hai\n"a,b","c""d"',
        reason: 'header + sort_order rows, escaped',
      );
    });

    test('an empty deck exports a valid header-only CSV', () async {
      await insertDeck('d1', 'Empty');

      final result = await repo.exportDeckCsv(deckId: 'd1');

      expect(result.failure, isNull);
      expect(result.data!.csvText, 'front,back');
      expect(result.data!.exportedRowCount, 0);
      expect(result.data!.fileName, 'Empty.csv');
    });

    test('a missing deck is a NotFoundFailure', () async {
      final result = await repo.exportDeckCsv(deckId: 'nope');
      expect(result.data, isNull);
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
