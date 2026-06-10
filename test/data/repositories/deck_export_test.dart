import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/entities/deck.dart';
import 'package:memox/domain/entities/folder.dart';
import 'package:memox/domain/models/deck_csv_export.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  late AppDatabase db;
  late FolderDao folderDao;
  late FlashcardRepositoryImpl repo;
  late FolderRepositoryImpl folderRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    folderDao = FolderDao(db);
    repo = FlashcardRepositoryImpl(FlashcardDao(db), folderDao);
    folderRepo = FolderRepositoryImpl(folderDao);
  });

  tearDown(() async {
    await db.close();
  });

  Future<Deck> createDeck(String name) async {
    final Folder folder =
        (await folderRepo.createRootFolder(name: 'Korean') as Ok<Folder>).value;
    return (await folderRepo.createDeck(
              parentFolderId: folder.id,
              name: name,
              targetLanguage: TargetLanguage.korean,
            )
            as Ok<Deck>)
        .value;
  }

  Future<void> insertCard({
    required String id,
    required String deckId,
    required String front,
    required String back,
    required int sortOrder,
    int? createdAt,
    int? updatedAt,
  }) async {
    final int nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    await db
        .into(db.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: front,
            back: back,
            sortOrder: Value<int>(sortOrder),
            createdAt: createdAt ?? nowMs,
            updatedAt: updatedAt ?? nowMs,
          ),
        );
  }

  group('exportDeckCsv', () {
    test('EX2 returns NotFoundFailure for a missing deck id', () async {
      final Result<DeckCsvExport> result = await repo.exportDeckCsv(
        deckId: 'missing',
      );

      expect(result, isA<Err<DeckCsvExport>>());
      expect((result as Err<DeckCsvExport>).failure, isA<NotFoundFailure>());
      expect(await db.select(db.flashcards).get(), isEmpty);
    });

    test('EX2 exports an empty deck as a valid header-only CSV', () async {
      final Deck deck = await createDeck('N5');

      final Result<DeckCsvExport> result = await repo.exportDeckCsv(
        deckId: deck.id,
      );

      expect(result, isA<Ok<DeckCsvExport>>());
      final DeckCsvExport export = (result as Ok<DeckCsvExport>).value;
      expect(export.deckId, deck.id);
      expect(export.deckName, 'N5');
      expect(export.fileName, 'N5.csv');
      expect(export.csvText, 'front,back');
      expect(export.exportedRowCount, 0);
    });

    test('EX2 exports one flashcard as expected CSV', () async {
      final Deck deck = await createDeck('N5');
      await insertCard(
        id: 'c1',
        deckId: deck.id,
        front: 'Hello',
        back: 'World',
        sortOrder: 0,
      );

      final Result<DeckCsvExport> result = await repo.exportDeckCsv(
        deckId: deck.id,
      );

      final DeckCsvExport export = (result as Ok<DeckCsvExport>).value;
      expect(export.csvText, 'front,back\nHello,World');
      expect(export.exportedRowCount, 1);
    });

    test('EX2 exports cards in deterministic deck order', () async {
      final Deck deck = await createDeck('N5');
      await insertCard(
        id: 'c3',
        deckId: deck.id,
        front: 'Third',
        back: '3',
        sortOrder: 2,
      );
      await insertCard(
        id: 'c1',
        deckId: deck.id,
        front: 'First',
        back: '1',
        sortOrder: 0,
      );
      await insertCard(
        id: 'c2',
        deckId: deck.id,
        front: 'Second',
        back: '2',
        sortOrder: 1,
      );

      final Result<DeckCsvExport> result = await repo.exportDeckCsv(
        deckId: deck.id,
      );

      final DeckCsvExport export = (result as Ok<DeckCsvExport>).value;
      expect(export.csvText, 'front,back\nFirst,1\nSecond,2\nThird,3');
    });

    test(
      'EX2 is read-only and leaves deck, flashcard, progress, and tag counts unchanged',
      () async {
        final Deck deck = await createDeck('Korean / N5: vocab?');
        await repo.createFlashcard(
          deckId: deck.id,
          front: 'Hello',
          back: 'World',
          exampleSentence: 'Example',
          pronunciation: 'annyeonghaseyo',
          hint: 'Greeting',
          tags: <String>['noun', 'greeting'],
        );

        final int deckCountBefore = (await db.select(db.decks).get()).length;
        final int flashcardCountBefore =
            (await db.select(db.flashcards).get()).length;
        final int progressCountBefore =
            (await db.select(db.flashcardProgress).get()).length;
        final int tagCountBefore =
            (await db.select(db.flashcardTags).get()).length;

        final Result<DeckCsvExport> result = await repo.exportDeckCsv(
          deckId: deck.id,
        );

        expect(result, isA<Ok<DeckCsvExport>>());
        expect((await db.select(db.decks).get()).length, deckCountBefore);
        expect(
          (await db.select(db.flashcards).get()).length,
          flashcardCountBefore,
        );
        expect(
          (await db.select(db.flashcardProgress).get()).length,
          progressCountBefore,
        );
        expect(
          (await db.select(db.flashcardTags).get()).length,
          tagCountBefore,
        );
      },
    );

    test('EX7 sanitizes the export file name from the deck title', () async {
      final Deck deck = await createDeck('  Korean / N5: vocab?  ');

      final Result<DeckCsvExport> result = await repo.exportDeckCsv(
        deckId: deck.id,
      );

      expect(
        (result as Ok<DeckCsvExport>).value.fileName,
        'Korean_N5_vocab.csv',
      );
    });

    test(
      'EX7 falls back to the deck id when the deck name sanitizes to blank',
      () async {
        final Deck deck = await createDeck(' /\\?* ');

        final Result<DeckCsvExport> result = await repo.exportDeckCsv(
          deckId: deck.id,
        );

        expect(
          (result as Ok<DeckCsvExport>).value.fileName,
          'deck_export_${deck.id}.csv',
        );
      },
    );
  });
}
