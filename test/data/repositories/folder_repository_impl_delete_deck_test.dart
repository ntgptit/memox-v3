import 'dart:math';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/flashcard_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/data/repositories/flashcard_repository_impl.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // Deck delete contract: WBS 2.9.1. Decision row D3
  // (`docs/decision-tables/deck.md`).
  group('FolderRepositoryImpl.deleteDeck', () {
    late AppDatabase db;
    late FolderDao folderDao;
    late DeckDao deckDao;
    late FlashcardDao flashcardDao;
    late FolderRepositoryImpl repo;
    late FlashcardRepositoryImpl flashcardRepo;
    late int clock;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      folderDao = FolderDao(db);
      deckDao = DeckDao(db);
      flashcardDao = FlashcardDao(db);
      clock = 1000;
      repo = FolderRepositoryImpl(
        dao: folderDao,
        deckDao: deckDao,
        idGenerator: IdGenerator(Random(42)),
        nowMs: () => clock++,
      );
      flashcardRepo = FlashcardRepositoryImpl(
        dao: flashcardDao,
        deckDao: deckDao,
        folderDao: folderDao,
        idGenerator: IdGenerator(Random(7)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    Future<String> newDeckInFolder(String folderId, String name) async {
      final result = await repo.createDeck(
        folderId: folderId,
        name: name,
        targetLanguage: TargetLanguage.korean,
      );
      return result.data!.id;
    }

    Future<ContentMode> modeOf(String id) async {
      final FolderRow row = (await folderDao.findFolderById(id))!;
      return FolderMapper.contentModeFromStorage(row.contentMode);
    }

    test('D3: deletes the deck and reverts the folder to unlocked when it '
        'was the last deck', () async {
      final String folderId = (await repo.createRootFolder(
        name: 'F${clock++}',
      )).data!.id;
      final String deckId = await newDeckInFolder(folderId, 'Verbs');
      expect(await modeOf(folderId), ContentMode.decks);

      final result = await repo.deleteDeck(deckId: deckId);

      expect(result.isSuccess, isTrue);
      expect(await deckDao.findDeckById(deckId), isNull);
      expect(await modeOf(folderId), ContentMode.unlocked);
    });

    test(
      'D3: keeps the folder locked to decks when another deck remains',
      () async {
        final String folderId = (await repo.createRootFolder(
          name: 'F${clock++}',
        )).data!.id;
        final String deckA = await newDeckInFolder(folderId, 'A');
        await newDeckInFolder(folderId, 'B');

        final result = await repo.deleteDeck(deckId: deckA);

        expect(result.isSuccess, isTrue);
        expect(await deckDao.findDeckById(deckA), isNull);
        expect(await modeOf(folderId), ContentMode.decks);
      },
    );

    test('D3: cascades to the deck flashcards, progress and tags', () async {
      final String folderId = (await repo.createRootFolder(
        name: 'F${clock++}',
      )).data!.id;
      final String deckId = await newDeckInFolder(folderId, 'Vocab');
      final card = await flashcardRepo.createFlashcard(
        deckId: deckId,
        front: 'Hello',
        back: 'Xin chao',
        tags: const <String>['greeting'],
      );
      final String cardId = card.data!.id;
      expect(await flashcardDao.findFlashcardById(cardId), isNotNull);

      final result = await repo.deleteDeck(deckId: deckId);

      expect(result.isSuccess, isTrue);
      expect(await flashcardDao.findFlashcardById(cardId), isNull);
      final progress = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM flashcard_progress '
            'WHERE flashcard_id = ?',
            variables: <Variable<Object>>[Variable<String>(cardId)],
          )
          .getSingle();
      expect(progress.read<int>('c'), 0);
      final tags = await db
          .customSelect(
            'SELECT COUNT(*) AS c FROM flashcard_tags WHERE flashcard_id = ?',
            variables: <Variable<Object>>[Variable<String>(cardId)],
          )
          .getSingle();
      expect(tags.read<int>('c'), 0);
    });

    test('D3: rejects a missing deck with NotFoundFailure', () async {
      final result = await repo.deleteDeck(deckId: 'nope');

      expect(result.isSuccess, isFalse);
      expect(result.failure, isA<NotFoundFailure>());
    });
  });
}
