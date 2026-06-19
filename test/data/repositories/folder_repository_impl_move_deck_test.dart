import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/error/failure.dart';
import 'package:memox/core/error/result.dart';
import 'package:memox/core/util/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/deck_dao.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/mappers/folder_mapper.dart';
import 'package:memox/data/repositories/folder_repository_impl.dart';
import 'package:memox/domain/types/content_mode.dart';
import 'package:memox/domain/types/target_language.dart';

void main() {
  // Deck move contract: WBS 2.19.1. Decision rows D9, D10
  // (`docs/decision-tables/deck.md`).
  group('FolderRepositoryImpl moveDeck', () {
    late AppDatabase db;
    late FolderDao folderDao;
    late DeckDao deckDao;
    late FolderRepositoryImpl repo;
    late int clock;

    setUp(() {
      db = AppDatabase.forExecutor(NativeDatabase.memory());
      folderDao = FolderDao(db);
      deckDao = DeckDao(db);
      clock = 1000;
      repo = FolderRepositoryImpl(
        dao: folderDao,
        deckDao: deckDao,
        idGenerator: IdGenerator(Random(7)),
        nowMs: () => clock++,
      );
    });
    tearDown(() => db.close());

    Future<String> newFolder({ContentMode? mode}) async {
      final String id = (await repo.createRootFolder(
        name: 'F${clock++}',
      )).data!.id;
      if (mode != null && mode != ContentMode.unlocked) {
        await folderDao.updateFolderColumns(
          id,
          FoldersCompanion(
            contentMode: Value(FolderMapper.contentModeToStorage(mode)),
          ),
        );
      }
      return id;
    }

    Future<String> newDeck(String folderId, String name) async =>
        (await repo.createDeck(
          folderId: folderId,
          name: name,
          targetLanguage: TargetLanguage.korean,
        )).data!.id;

    Future<ContentMode> modeOf(String id) async {
      final FolderRow row = (await folderDao.findFolderById(id))!;
      return FolderMapper.contentModeFromStorage(row.contentMode);
    }

    test(
      'D9: moves a deck, locks the destination, reverts the source',
      () async {
        final String source = await newFolder();
        final String deckId = await newDeck(source, 'Only');
        final String dest = await newFolder(); // unlocked, empty

        final result = await repo.moveDeck(deckId: deckId, newFolderId: dest);

        expect(result.isSuccess, isTrue);
        expect(result.data!.folderId, dest);
        expect(result.data!.sortOrder, 0); // appended into empty destination
        expect(await modeOf(dest), ContentMode.decks);
        // Source lost its last deck → reverts to unlocked.
        expect(await modeOf(source), ContentMode.unlocked);
      },
    );

    test('D9: appends after existing decks in the destination', () async {
      final String source = await newFolder();
      final String deckId = await newDeck(source, 'Mover');
      final String dest = await newFolder();
      await newDeck(dest, 'Existing'); // sort_order 0 in dest

      final result = await repo.moveDeck(deckId: deckId, newFolderId: dest);

      expect(result.data!.sortOrder, 1);
    });

    test('D9: source keeps decks-mode when it still has decks', () async {
      final String source = await newFolder();
      final String stay = await newDeck(source, 'Stay');
      final String mover = await newDeck(source, 'Mover');
      final String dest = await newFolder();

      await repo.moveDeck(deckId: mover, newFolderId: dest);

      expect(await modeOf(source), ContentMode.decks);
      expect((await deckDao.findDeckById(stay))!.folderId, source);
    });

    test('D10: same folder is a no-op success', () async {
      final String source = await newFolder();
      final String deckId = await newDeck(source, 'Same');

      final result = await repo.moveDeck(deckId: deckId, newFolderId: source);

      expect(result.isSuccess, isTrue);
      expect(result.data!.folderId, source);
    });

    test('D10: rejects a missing destination', () async {
      final String source = await newFolder();
      final String deckId = await newDeck(source, 'D');

      final result = await repo.moveDeck(deckId: deckId, newFolderId: 'nope');

      expect(result.failure, isA<NotFoundFailure>());
    });

    test('D10: rejects a missing deck', () async {
      final String dest = await newFolder();
      final result = await repo.moveDeck(deckId: 'nope', newFolderId: dest);
      expect(result.failure, isA<NotFoundFailure>());
    });

    test(
      'D10: rejects a subfolders-locked destination (folder_contains_subfolders)',
      () async {
        final String source = await newFolder();
        final String deckId = await newDeck(source, 'D');
        final String dest = await newFolder(mode: ContentMode.subfolders);

        final result = await repo.moveDeck(deckId: deckId, newFolderId: dest);

        expect(
          result.failure,
          isA<UnsupportedActionFailure>().having(
            (UnsupportedActionFailure f) => f.message,
            'message',
            'folder_contains_subfolders',
          ),
        );
      },
    );

    test('D10: rejects a duplicate sibling name in the destination', () async {
      final String source = await newFolder();
      final String deckId = await newDeck(source, 'Dup');
      final String dest = await newFolder();
      await newDeck(dest, 'dup'); // case-insensitive clash

      final result = await repo.moveDeck(deckId: deckId, newFolderId: dest);

      expect(
        result.failure,
        isA<ValidationFailure>().having(
          (ValidationFailure f) => f.code,
          'code',
          ValidationCode.duplicate,
        ),
      );
    });
  });
}
